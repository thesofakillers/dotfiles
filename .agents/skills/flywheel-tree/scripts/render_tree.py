#!/usr/bin/env python3
"""Render a Flywheel get_node_tree response into terminal-ready tree text.

Input:
- Raw JSON from flywheel_get_node_tree (stdin or file).

Output:
- Text suitable for direct terminal printing, including ANSI colors and summary:
  - root: <anchor title>
  - node_count: <anchor-rooted descendant node count>
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, Iterator, List, NamedTuple, Set, Tuple

DEFAULT_COLORS = [
    "\u001b[94m",
    "\u001b[96m",
    "\u001b[95m",
    "\u001b[92m",
    "\u001b[38;5;45m",
    "\u001b[38;5;39m",
    "\u001b[38;5;51m",
    "\u001b[38;5;75m",
    "\u001b[38;5;81m",
    "\u001b[38;5;87m",
    "\u001b[38;5;69m",
    "\u001b[38;5;63m",
    "\u001b[38;5;57m",
    "\u001b[38;5;99m",
    "\u001b[38;5;105m",
    "\u001b[38;5;111m",
    "\u001b[38;5;117m",
    "\u001b[38;5;123m",
    "\u001b[38;5;159m",
    "\u001b[38;5;195m",
]
DEFAULT_RESET = "\u001b[0m"
GRAY = "\u001b[38;5;245m"

BOX_MID = "├── "
BOX_LAST = "└── "
BOX_PIPE = "│   "
BOX_SPACE = "    "


class Node(NamedTuple):
    title: str
    slug_name: str
    parent_ids: Tuple[str, ...]
    child_ids: Tuple[str, ...]


def _normalize_ansi(value: str) -> str:
    if "\\u001b" in value or "\\x1b" in value:
        try:
            return value.encode("utf-8").decode("unicode_escape")
        except Exception:  # noqa: BLE001
            return value
    return value


def _extract_tree_payload(payload: Any) -> dict:
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
    raise ValueError(
        "Input JSON is not a flywheel_get_node_tree response (missing nodes/anchor_node_id)."
    )


def _read_json_from_path(path: str) -> dict:
    if path == "-":
        raw = sys.stdin.buffer.read().decode("utf-8-sig")
        payload = json.loads(raw)
    else:
        with Path(path).open("r", encoding="utf-8-sig") as handle:
            payload = json.load(handle)
    return _extract_tree_payload(payload)


def _load_palette(asset_path: Path) -> tuple[List[str], str]:
    if not asset_path.exists():
        return DEFAULT_COLORS, DEFAULT_RESET

    with asset_path.open("r", encoding="utf-8-sig") as handle:
        data = json.load(handle)

    colors = data.get("colors") if isinstance(data, dict) else None
    reset = (
        data.get("reset", DEFAULT_RESET) if isinstance(data, dict) else DEFAULT_RESET
    )

    if not isinstance(colors, list) or not colors:
        return DEFAULT_COLORS, DEFAULT_RESET

    safe_colors = [
        _normalize_ansi(color) for color in colors if isinstance(color, str) and color
    ]
    if not safe_colors:
        return DEFAULT_COLORS, DEFAULT_RESET

    if not isinstance(reset, str) or not reset:
        reset = DEFAULT_RESET

    return safe_colors, _normalize_ansi(reset)


def _clean_text(value: Any) -> str:
    return value.strip() if isinstance(value, str) else ""


def _build_node_map(nodes_payload: Iterable[dict]) -> Dict[str, Node]:
    node_map: Dict[str, Node] = {}

    for raw in nodes_payload:
        if not isinstance(raw, dict):
            continue

        node_id = _clean_text(raw.get("node_id"))
        if not node_id:
            continue

        title = _clean_text(raw.get("title")) or node_id
        slug_name_raw = raw.get("slug_name", raw.get("slug"))
        slug_name = _clean_text(slug_name_raw)

        parent_raw = raw.get("parent_ids")
        if not isinstance(parent_raw, list):
            parent_raw = raw.get("incoming_ids", [])
        child_raw = raw.get("child_ids")
        if not isinstance(child_raw, list):
            child_raw = raw.get("outgoing_ids", [])

        parent_ids = tuple(str(p) for p in parent_raw if isinstance(p, str))
        child_ids = tuple(str(c) for c in child_raw if isinstance(c, str))

        node_map[node_id] = Node(
            title=title,
            slug_name=slug_name,
            parent_ids=parent_ids,
            child_ids=child_ids,
        )

    return node_map


def _collect_descendants(
    anchor_node_id: str, node_map: Dict[str, Node]
) -> tuple[Set[str], List[str]]:
    descendants: Set[str] = set()
    order: List[str] = []
    stack: List[str] = [anchor_node_id]

    while stack:
        current = stack.pop()
        if current in descendants:
            continue

        node = node_map.get(current)
        if node is None:
            continue

        descendants.add(current)
        order.append(current)
        for child_id in reversed(node.child_ids):
            stack.append(child_id)

    return descendants, order


def render_tree_text(
    tree_payload: dict,
    anchor_override: str | None = None,
    use_color: bool = True,
    palette_path: Path | None = None,
) -> str:
    return "\n".join(
        _iter_render_lines(
            tree_payload=tree_payload,
            anchor_override=anchor_override,
            use_color=use_color,
            palette_path=palette_path,
        )
    )


def _iter_render_lines(
    tree_payload: dict,
    anchor_override: str | None = None,
    use_color: bool = True,
    palette_path: Path | None = None,
) -> Iterator[str]:
    node_map = _build_node_map(tree_payload.get("nodes", []))

    anchor = _clean_text(anchor_override) or _clean_text(
        tree_payload.get("anchor_node_id")
    )
    if not anchor:
        raise ValueError("Missing anchor node id.")
    if anchor not in node_map:
        raise ValueError(f"Anchor node '{anchor}' is not present in nodes payload.")

    descendants, ordered_descendants = _collect_descendants(anchor, node_map)
    if anchor not in descendants:
        raise ValueError(f"Could not build descendant subgraph for anchor '{anchor}'.")

    retained_children: Dict[str, Tuple[str, ...]] = {}
    multi_parent_nodes: List[str] = []

    for node_id in ordered_descendants:
        node = node_map[node_id]

        retained = tuple(child for child in node.child_ids if child in descendants)
        retained_children[node_id] = retained

        parent_count = 0
        for parent_id in node.parent_ids:
            if parent_id in descendants:
                parent_count += 1
                if parent_count > 1:
                    multi_parent_nodes.append(node_id)
                    break

    colors, reset = (
        _load_palette(palette_path) if palette_path else (DEFAULT_COLORS, DEFAULT_RESET)
    )

    multi_parent_color: Dict[str, str] = {}
    for idx, node_id in enumerate(multi_parent_nodes):
        multi_parent_color[node_id] = colors[idx % len(colors)]

    seen_multi_parent: Dict[str, int] = {node_id: 0 for node_id in multi_parent_nodes}
    ancestry: Set[str] = set()
    expanded_nodes: Set[str] = set()

    def line_for(node_id: str) -> str:
        node = node_map[node_id]
        seen_count = seen_multi_parent.get(node_id)
        has_multi_parent = seen_count is not None
        mp_color = multi_parent_color[node_id] if has_multi_parent else ""

        if has_multi_parent:
            suffix = " (multi-parent)" if seen_count == 0 else " (duplicate view)"
            seen_multi_parent[node_id] = seen_count + 1
        else:
            suffix = ""

        if not use_color:
            rendered = node.title
            if node.slug_name:
                rendered += f" | {node.slug_name}"
            rendered += suffix
            return rendered

        rendered = f"{mp_color}{node.title}{reset}" if has_multi_parent else node.title
        if node.slug_name:
            rendered += f" {GRAY}| {node.slug_name}{reset}"
        if suffix:
            rendered += f" {mp_color}{suffix}{reset}" if has_multi_parent else suffix
        return rendered

    # Iterative DFS avoids RecursionError on very deep trees.
    stack: List[Tuple[Any, ...]] = [("enter", anchor, "", True, True)]

    while stack:
        frame = stack.pop()
        tag = frame[0]

        if tag == "exit":
            _, node_id = frame
            ancestry.remove(node_id)
            continue

        _, node_id, prefix, is_last, is_root = frame
        if node_id in ancestry:
            connector = "" if is_root else (BOX_LAST if is_last else BOX_MID)
            yield f"{prefix}{connector}[cycle] {node_id}"
            continue

        if is_root:
            yield line_for(node_id)
            child_prefix = ""
        else:
            connector = BOX_LAST if is_last else BOX_MID
            yield f"{prefix}{connector}{line_for(node_id)}"
            child_prefix = prefix + (BOX_SPACE if is_last else BOX_PIPE)

        # Dense DAGs can have many parent-paths to the same node.
        # Expand each node subtree once, then show duplicate views without
        # re-expanding descendants to prevent combinatorial memory/runtime blowups.
        if node_id in expanded_nodes:
            continue
        expanded_nodes.add(node_id)

        ancestry.add(node_id)
        children = retained_children.get(node_id, ())
        stack.append(("exit", node_id))

        # Reverse push order to preserve original left-to-right DFS output.
        for idx in range(len(children) - 1, -1, -1):
            child_id = children[idx]
            child_is_last = idx == (len(children) - 1)
            stack.append(("enter", child_id, child_prefix, child_is_last, False))

    yield ""
    yield f"root: {node_map[anchor].title}"
    yield f"node_count: {len(descendants)}"


def _build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Render Flywheel get_node_tree JSON into terminal-ready tree text."
    )
    parser.add_argument(
        "--input",
        required=True,
        help="Path to JSON input file, or '-' to read from stdin.",
    )
    parser.add_argument(
        "--root-node",
        default=None,
        help="Optional anchor node id override. Defaults to anchor_node_id from input.",
    )
    parser.add_argument(
        "--no-color",
        action="store_true",
        help="Disable ANSI color output.",
    )
    parser.add_argument(
        "--palette",
        default=None,
        help="Optional path to palette JSON file with fields: colors (list), reset (string).",
    )
    return parser


def main() -> int:
    parser = _build_arg_parser()
    args = parser.parse_args()

    try:
        payload = _read_json_from_path(args.input)
        palette = Path(args.palette) if args.palette else None
        rendered_lines = _iter_render_lines(
            tree_payload=payload,
            anchor_override=args.root_node,
            use_color=not args.no_color,
            palette_path=palette,
        )
    except Exception as exc:  # noqa: BLE001
        print(f"render_tree.py error: {exc}", file=sys.stderr)
        return 1

    try:
        sys.stdout.reconfigure(encoding="utf-8")  # type: ignore[attr-defined]
    except Exception:  # noqa: BLE001
        pass

    wrote_any = False
    for line in rendered_lines:
        if wrote_any:
            sys.stdout.write("\n")
        sys.stdout.write(line)
        wrote_any = True
    if wrote_any:
        sys.stdout.write("\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
