#!/usr/bin/env python3
"""Fetch Flywheel tree via MCP tools and render terminal tree text.

This wrapper avoids model-side JSON marshalling by keeping fetch+render inside
one process:
1) resolve selector via `flywheel_resolve_node_slug` when needed
2) fetch topology via `flywheel_get_node_tree`
3) render tree text via local deterministic renderer
"""

from __future__ import annotations

import argparse
import asyncio
import builtins
import json
import os
import re
import sys
import tomllib
from pathlib import Path
from typing import Any, Iterable

from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client

from render_tree import render_tree_text

UUID_PATTERN = re.compile(
    r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
)
DEFAULT_CODEX_MCP_SERVER = "flywheel"
CODEX_CONFIG_FILENAME = "config.toml"
CODEX_CONFIG_DIRNAME = ".codex"
CLAUDE_PROJECT_CONFIG_FILENAME = ".mcp.json"
CLAUDE_GLOBAL_CONFIG_FILENAME = ".claude.json"
EXCEPTION_GROUP_TYPE = getattr(builtins, "BaseExceptionGroup", None)


def _normalize_auth_header_value(token_or_header: str) -> str:
    token = token_or_header.strip()
    if token.lower().startswith("bearer "):
        return token
    return f"Bearer {token}"


def _candidate_mcp_config_paths() -> list[Path]:
    candidates: list[Path] = []
    seen: set[Path] = set()

    def add(candidate: Path | None) -> None:
        if candidate is None:
            return
        resolved = candidate.expanduser().resolve()
        if resolved in seen:
            return
        seen.add(resolved)
        candidates.append(resolved)

    env_codex_config = os.environ.get("CODEX_CONFIG", "").strip()
    if env_codex_config:
        add(Path(env_codex_config))

    env_codex_home = os.environ.get("CODEX_HOME", "").strip()
    if env_codex_home:
        add(Path(env_codex_home) / CODEX_CONFIG_FILENAME)

    # Project-scoped Codex config in current working tree (nearest ancestor first).
    cwd = Path.cwd().resolve()
    for current in (cwd, *cwd.parents):
        add(current / CODEX_CONFIG_DIRNAME / CODEX_CONFIG_FILENAME)

    add(Path.home() / CODEX_CONFIG_DIRNAME / CODEX_CONFIG_FILENAME)

    user_profile = os.environ.get("USERPROFILE", "").strip()
    if user_profile:
        add(Path(user_profile) / CODEX_CONFIG_DIRNAME / CODEX_CONFIG_FILENAME)

    # Claude project-scoped config in current working tree (nearest ancestor first).
    for current in (cwd, *cwd.parents):
        add(current / CLAUDE_PROJECT_CONFIG_FILENAME)

    # Claude global config.
    add(Path.home() / CLAUDE_GLOBAL_CONFIG_FILENAME)
    if user_profile:
        add(Path(user_profile) / CLAUDE_GLOBAL_CONFIG_FILENAME)

    return candidates


def _resolve_mcp_config_path(explicit_path: str | None) -> Path:
    if isinstance(explicit_path, str) and explicit_path.strip():
        config_path = Path(explicit_path).expanduser().resolve()
        if not config_path.exists():
            raise RuntimeError(
                f"MCP config not found at '{config_path}'. "
                "Pass a valid --codex-config/--mcp-config path."
            )
        return config_path

    candidates = _candidate_mcp_config_paths()
    for candidate in candidates:
        if candidate.exists():
            return candidate

    searched = "\n".join(f"- {path}" for path in candidates)
    raise RuntimeError(
        "No supported MCP config file was found in auto-discovery paths.\n"
        f"Searched:\n{searched}\n"
        "Pass --codex-config/--mcp-config explicitly."
    )


def _load_target_from_discovered_configs(
    *,
    server_name: str,
) -> tuple[str, dict[str, str], Path]:
    candidates = _candidate_mcp_config_paths()
    errors: list[str] = []

    for candidate in candidates:
        if not candidate.exists():
            continue
        try:
            url, headers = _load_codex_http_mcp_target(
                codex_config_path=candidate,
                server_name=server_name,
            )
            return url, headers, candidate
        except Exception as exc:  # noqa: BLE001
            errors.append(f"{candidate}: {type(exc).__name__}: {exc}")

    searched = "\n".join(f"- {path}" for path in candidates)
    details = (
        "\n".join(f"- {error}" for error in errors)
        if errors
        else "- no readable config files found"
    )
    raise RuntimeError(
        "Unable to resolve MCP target from auto-discovered configs.\n"
        f"Searched:\n{searched}\n"
        f"Failures:\n{details}\n"
        "Pass --codex-config/--mcp-config or --mcp-url explicitly."
    )


def _load_mcp_servers_from_toml(config_path: Path) -> dict[str, Any]:
    with config_path.open("rb") as handle:
        config = tomllib.load(handle)
    mcp_servers = config.get("mcp_servers")
    if not isinstance(mcp_servers, dict):
        raise RuntimeError(
            f"MCP config '{config_path}' is TOML but has no [mcp_servers] section."
        )
    return mcp_servers


def _load_mcp_servers_from_json(config_path: Path) -> dict[str, Any]:
    with config_path.open("r", encoding="utf-8-sig") as handle:
        config = json.load(handle)
    mcp_servers = config.get("mcpServers")
    if not isinstance(mcp_servers, dict):
        raise RuntimeError(
            f"MCP config '{config_path}' is JSON but has no mcpServers object."
        )
    return mcp_servers


def _load_mcp_servers_from_config(config_path: Path) -> dict[str, Any]:
    suffix = config_path.suffix.lower()
    if suffix == ".toml":
        return _load_mcp_servers_from_toml(config_path)
    if suffix == ".json":
        return _load_mcp_servers_from_json(config_path)

    # Fallback for unusual file extensions.
    try:
        return _load_mcp_servers_from_toml(config_path)
    except Exception:
        return _load_mcp_servers_from_json(config_path)


def _valid_http_mcp_aliases(mcp_servers: dict[str, Any]) -> list[str]:
    aliases: list[str] = []
    for key, value in mcp_servers.items():
        if not isinstance(key, str) or not isinstance(value, dict):
            continue
        url = value.get("url")
        if isinstance(url, str) and url.strip():
            aliases.append(key)
    return aliases


def _alias_rank(alias: str, server_url: str) -> tuple[int, str]:
    normalized_alias = alias.lower()
    normalized_url = server_url.lower()
    score = 0

    if normalized_alias == "flywheel-prod":
        score += 100
    if normalized_alias == "flywheel-production":
        score += 90
    if normalized_alias.endswith("-prod") or "prod" in normalized_alias:
        score += 75
    if "://flywheel." in normalized_url and "/mcp-server" in normalized_url:
        score += 65
    if normalized_alias.startswith("flywheel-"):
        score += 25

    return score, alias


def _resolve_server_alias(
    *,
    mcp_servers: dict[str, Any],
    requested_server_name: str,
) -> str:
    if requested_server_name in mcp_servers:
        return requested_server_name

    if requested_server_name != DEFAULT_CODEX_MCP_SERVER:
        available = ", ".join(sorted(str(key) for key in mcp_servers.keys()))
        raise RuntimeError(
            f"MCP server '{requested_server_name}' not found in Codex config. "
            f"Available: {available or 'none'}"
        )

    env_server = os.environ.get("FLYWHEEL_MCP_SERVER", "").strip()
    if env_server and env_server in mcp_servers:
        return env_server

    compatible_aliases = [
        alias
        for alias in _valid_http_mcp_aliases(mcp_servers)
        if alias.startswith(DEFAULT_CODEX_MCP_SERVER)
    ]
    if not compatible_aliases:
        available = ", ".join(sorted(str(key) for key in mcp_servers.keys()))
        raise RuntimeError(
            f"MCP server '{requested_server_name}' not found in Codex config. "
            f"Available: {available or 'none'}"
        )

    if len(compatible_aliases) == 1:
        return compatible_aliases[0]

    ranked: list[tuple[int, str]] = []
    for alias in compatible_aliases:
        server = mcp_servers.get(alias)
        if not isinstance(server, dict):
            continue
        server_url = server.get("url")
        if not isinstance(server_url, str):
            continue
        ranked.append(_alias_rank(alias, server_url))

    if ranked:
        ranked.sort(reverse=True)
        best_score = ranked[0][0]
        best_aliases = [alias for score, alias in ranked if score == best_score]
        if len(best_aliases) == 1:
            return best_aliases[0]

    available = ", ".join(sorted(compatible_aliases))
    raise RuntimeError(
        "Multiple flywheel-prefixed MCP aliases were found and no deterministic "
        "default could be selected. "
        f"Provide --codex-mcp-server explicitly. Candidates: {available}"
    )


def _load_codex_http_mcp_target(
    *,
    codex_config_path: Path,
    server_name: str,
) -> tuple[str, dict[str, str]]:
    if not codex_config_path.exists():
        raise RuntimeError(
            f"Codex config not found at '{codex_config_path}'. "
            "Pass --mcp-url/--access-token explicitly or provide --codex-config."
        )

    mcp_servers = _load_mcp_servers_from_config(codex_config_path)

    resolved_server_name = _resolve_server_alias(
        mcp_servers=mcp_servers,
        requested_server_name=server_name,
    )
    server_config = mcp_servers.get(resolved_server_name)
    if not isinstance(server_config, dict):
        raise RuntimeError(
            f"MCP server '{resolved_server_name}' is not a valid MCP object in Codex config."
        )

    server_url = server_config.get("url")
    if not isinstance(server_url, str) or not server_url.strip():
        raise RuntimeError(
            f"MCP server '{resolved_server_name}' has no HTTP url in Codex config."
        )
    server_url = server_url.strip()

    headers: dict[str, str] = {}

    # Generic headers key used by JSON host configs (for example Claude).
    raw_headers = server_config.get("headers")
    if isinstance(raw_headers, dict):
        for key, value in raw_headers.items():
            if isinstance(key, str) and isinstance(value, str) and key and value:
                headers[key] = value

    # Inline headers from TOML host configs (for example Codex).
    raw_http_headers = server_config.get("http_headers")
    if isinstance(raw_http_headers, dict):
        for key, value in raw_http_headers.items():
            if isinstance(key, str) and isinstance(value, str) and key and value:
                headers[key] = value

    # Environment-backed header mapping in Codex config.
    raw_env_http_headers = server_config.get("env_http_headers")
    if isinstance(raw_env_http_headers, dict):
        for header_name, env_var in raw_env_http_headers.items():
            if not (isinstance(header_name, str) and isinstance(env_var, str)):
                continue
            env_value = os.environ.get(env_var, "").strip()
            if env_value:
                headers[header_name] = env_value

    # Optional bearer token env var field used by Codex config.
    bearer_token_env_var = server_config.get("bearer_token_env_var")
    if isinstance(bearer_token_env_var, str) and bearer_token_env_var.strip():
        env_value = os.environ.get(bearer_token_env_var.strip(), "").strip()
        if env_value:
            headers["Authorization"] = _normalize_auth_header_value(env_value)

    return server_url, headers


def _iter_text_content(content_items: Iterable[Any]) -> Iterable[str]:
    for item in content_items:
        text = getattr(item, "text", None)
        if isinstance(text, str):
            yield text
            continue
        if isinstance(item, dict):
            maybe_text = item.get("text")
            if isinstance(maybe_text, str):
                yield maybe_text


def _summarize_call_result_text(content_items: Iterable[Any]) -> str:
    parts = [text.strip() for text in _iter_text_content(content_items) if text.strip()]
    if not parts:
        return "no error details returned"
    return " | ".join(parts)


def _extract_payload_from_call_result(result: Any, *, tool_name: str) -> dict[str, Any]:
    is_error = bool(getattr(result, "isError", False))
    content_items = getattr(result, "content", [])
    if is_error:
        detail = _summarize_call_result_text(content_items)
        raise RuntimeError(f"{tool_name} failed: {detail}")

    structured = getattr(result, "structuredContent", None)
    if isinstance(structured, dict):
        return structured

    for text in _iter_text_content(content_items):
        stripped = text.strip()
        if not stripped:
            continue
        try:
            parsed = json.loads(stripped)
        except json.JSONDecodeError:
            continue
        if isinstance(parsed, dict):
            return parsed

    detail = _summarize_call_result_text(content_items)
    raise RuntimeError(
        f"{tool_name} returned no structured JSON payload (detail: {detail})"
    )


def _extract_tree_payload(payload: Any) -> dict[str, Any]:
    if isinstance(payload, dict) and "nodes" in payload and "anchor_node_id" in payload:
        return payload
    if isinstance(payload, dict):
        for key in ("result", "data", "response"):
            nested = payload.get(key)
            if (
                isinstance(nested, dict)
                and "nodes" in nested
                and "anchor_node_id" in nested
            ):
                return nested
    raise RuntimeError(
        "flywheel_get_node_tree did not return expected nodes/anchor_node_id payload."
    )


def _candidate_node_id(candidate: Any) -> str:
    if not isinstance(candidate, dict):
        return ""
    node = candidate.get("node")
    if isinstance(node, dict):
        node_id = node.get("node_id")
        if isinstance(node_id, str) and node_id.strip():
            return node_id.strip()
    node_id = candidate.get("node_id")
    if isinstance(node_id, str) and node_id.strip():
        return node_id.strip()
    return ""


async def _resolve_selector_to_node_id(
    *,
    session: ClientSession,
    selector: str,
    context_node_id: str | None,
) -> str:
    cleaned = selector.strip()
    if UUID_PATTERN.fullmatch(cleaned):
        return cleaned

    args: dict[str, Any] = {"slug_name": cleaned}
    if context_node_id:
        args["context_node_id"] = context_node_id

    resolve_result = await session.call_tool(
        "flywheel_resolve_node_slug", arguments=args
    )
    payload = _extract_payload_from_call_result(
        resolve_result, tool_name="flywheel_resolve_node_slug"
    )

    status = str(payload.get("status", "")).strip().lower()
    if status in {"unique", "context_resolved"}:
        node = payload.get("node")
        if isinstance(node, dict):
            node_id = node.get("node_id")
            if isinstance(node_id, str) and node_id.strip():
                return node_id.strip()
        raise RuntimeError(
            "Slug resolved but no node_id returned by flywheel_resolve_node_slug."
        )

    if status == "not_found":
        raise RuntimeError(f"Slug '{cleaned}' was not found.")

    if status == "ambiguous":
        candidates = payload.get("candidates")
        candidate_ids: list[str] = []
        if isinstance(candidates, list):
            for candidate in candidates:
                node_id = _candidate_node_id(candidate)
                if node_id:
                    candidate_ids.append(node_id)
        suffix = (
            f" Candidate node_ids: {', '.join(candidate_ids)}" if candidate_ids else ""
        )
        raise RuntimeError(f"Slug '{cleaned}' is ambiguous.{suffix}")

    # Fallback for unexpected response shape.
    node = payload.get("node")
    if isinstance(node, dict):
        node_id = node.get("node_id")
        if isinstance(node_id, str) and node_id.strip():
            return node_id.strip()

    raise RuntimeError(
        f"Unexpected flywheel_resolve_node_slug response status: {status or 'missing'}."
    )


async def _fetch_tree_payload(
    *,
    session: ClientSession,
    node_id: str,
    max_nodes: int,
    projection: str,
) -> dict[str, Any]:
    tree_result = await session.call_tool(
        "flywheel_get_node_tree",
        arguments={
            "node_id": node_id,
            "max_nodes": max_nodes,
            "projection": projection,
        },
    )
    payload = _extract_payload_from_call_result(
        tree_result, tool_name="flywheel_get_node_tree"
    )
    return _extract_tree_payload(payload)


async def _run(args: argparse.Namespace) -> str:
    configured_url = ""
    configured_headers: dict[str, str] = {}

    if not args.mcp_url or args.use_codex_credentials:
        if isinstance(args.codex_config, str) and args.codex_config.strip():
            resolved_codex_config = _resolve_mcp_config_path(args.codex_config)
            configured_url, configured_headers = _load_codex_http_mcp_target(
                codex_config_path=resolved_codex_config,
                server_name=args.codex_mcp_server,
            )
        else:
            configured_url, configured_headers, _resolved_config = (
                _load_target_from_discovered_configs(
                    server_name=args.codex_mcp_server,
                )
            )

    mcp_url = (
        args.mcp_url.strip()
        if isinstance(args.mcp_url, str) and args.mcp_url.strip()
        else configured_url
    )
    if not mcp_url:
        raise RuntimeError(
            "Unable to resolve MCP url. Pass --mcp-url or configure Codex MCP server."
        )

    headers = dict(configured_headers)
    if args.access_token:
        headers["Authorization"] = _normalize_auth_header_value(args.access_token)

    async with streamablehttp_client(
        mcp_url,
        headers=headers or None,
        timeout=float(args.timeout_seconds),
        sse_read_timeout=float(args.timeout_seconds),
    ) as (read_stream, write_stream, _get_session_id):
        async with ClientSession(read_stream, write_stream) as session:
            await session.initialize()
            node_id = await _resolve_selector_to_node_id(
                session=session,
                selector=args.selector,
                context_node_id=args.context_node_id,
            )
            tree_payload = await _fetch_tree_payload(
                session=session,
                node_id=node_id,
                max_nodes=args.max_nodes,
                projection=args.projection,
            )

    palette_path = Path(args.palette).resolve()
    return render_tree_text(
        tree_payload=tree_payload,
        use_color=not args.no_color,
        palette_path=palette_path,
    )


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Resolve a Flywheel selector via MCP, fetch node tree via "
            "flywheel_get_node_tree, and render terminal tree text."
        )
    )
    parser.add_argument(
        "--selector",
        required=True,
        help="Root selector (node id UUID or slug).",
    )
    parser.add_argument(
        "--context-node-id",
        default=None,
        help="Optional context node id for flywheel_resolve_node_slug.",
    )
    parser.add_argument(
        "--codex-mcp-server",
        default=DEFAULT_CODEX_MCP_SERVER,
        help=(
            "Codex MCP server alias (default: flywheel). "
            "If flywheel is missing, the wrapper auto-resolves a flywheel* alias."
        ),
    )
    parser.add_argument(
        "--codex-config",
        "--mcp-config",
        dest="codex_config",
        default=None,
        help=(
            "Optional MCP config path (Codex TOML or Claude JSON). "
            "If omitted, auto-discovery checks CODEX_CONFIG, CODEX_HOME/config.toml, "
            "nearest ./.codex/config.toml, ~/.codex/config.toml, nearest ./.mcp.json, "
            "then ~/.claude.json."
        ),
    )
    parser.add_argument(
        "--mcp-url",
        default=None,
        help=("Optional MCP URL override. If omitted, use URL from Codex MCP config."),
    )
    parser.add_argument(
        "--access-token",
        default=None,
        help=(
            "Optional bearer token override. By default, use Codex-configured "
            "HTTP headers/credentials."
        ),
    )
    parser.add_argument(
        "--use-codex-credentials",
        action="store_true",
        help=(
            "Always load credentials from Codex MCP config even when --mcp-url is set."
        ),
    )
    parser.add_argument(
        "--max-nodes",
        type=int,
        default=1000,
        help="Maximum nodes passed to flywheel_get_node_tree (default: 1000).",
    )
    parser.add_argument(
        "--projection",
        choices=["core", "topology", "full"],
        default="topology",
        help="Projection passed to flywheel_get_node_tree (default: topology).",
    )
    parser.add_argument(
        "--palette",
        default=str(
            Path(__file__).resolve().parent.parent / "assets" / "ansi_palette.json"
        ),
        help="Path to ANSI palette JSON used by renderer.",
    )
    parser.add_argument(
        "--no-color",
        action="store_true",
        help="Disable ANSI color output.",
    )
    parser.add_argument(
        "--timeout-seconds",
        type=float,
        default=30.0,
        help="MCP transport timeout (default: 30s).",
    )
    return parser


def _flatten_exception_messages(exc: BaseException) -> str:
    stack: list[BaseException] = [exc]
    leaves: list[str] = []

    while stack:
        current = stack.pop()
        if EXCEPTION_GROUP_TYPE and isinstance(current, EXCEPTION_GROUP_TYPE):
            stack.extend(current.exceptions)
            continue
        message = str(current).strip()
        if message:
            leaves.append(f"{type(current).__name__}: {message}")
        else:
            leaves.append(type(current).__name__)

    if not leaves:
        return str(exc).strip() or type(exc).__name__
    return " | ".join(leaves)


def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()

    if args.max_nodes <= 0:
        print("render_tree_via_mcp.py error: --max-nodes must be > 0", file=sys.stderr)
        return 2

    try:
        rendered = asyncio.run(_run(args))
    except Exception as exc:  # noqa: BLE001
        detail = _flatten_exception_messages(exc)
        print(f"render_tree_via_mcp.py error: {detail}", file=sys.stderr)
        return 1

    try:
        sys.stdout.reconfigure(encoding="utf-8")  # type: ignore[attr-defined]
    except Exception:  # noqa: BLE001
        pass

    sys.stdout.write(rendered)
    if not rendered.endswith("\n"):
        sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
