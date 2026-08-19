---
name: dev-projectless-chat
description: Create an app-indexed projectless Codex chat on the dev SSH remote under /home/giulio/Documents/Codex. Use when the user asks to make, start, or give them another/new projectless chat or thread on dev, especially when the normal create_thread projectless target would create it locally instead of on dev.
---

# Dev Projectless Chat

Create the remote chat through the interactive Codex CLI over SSH. Do not use `create_thread` for this: projectless targets have no host selector and land locally. Do not use `codex exec`: it writes a session file but the app may not index it as a sidebar thread.

## Workflow

1. Pick the remote directory.
   - Use the remote date: `ssh dev 'date +%F'`.
   - Base path: `/home/giulio/Documents/Codex/<date>/dev-projectless`.
   - If that exists, use the next free suffix: `dev-projectless-2`, `dev-projectless-3`, etc.
   - Quick check:

```bash
ssh dev 'find /home/giulio/Documents/Codex/$(date +%F) -maxdepth 1 -mindepth 1 -type d -name "dev-projectless*" -printf "%f\n" 2>/dev/null | sort'
```

2. Start the remote interactive session.

```bash
ssh -tt dev 'TERM=xterm-256color bash -lc '\''mkdir -p /home/giulio/Documents/Codex/<date>/<dir> && codex --no-alt-screen -C /home/giulio/Documents/Codex/<date>/<dir> -s danger-full-access "Projectless dev chat requested by the user. Please wait for the user next instruction."'\'''
```

3. Drive the prompts minimally.
   - Directory trust prompt for the just-created empty Codex folder: press Enter.
   - Hook review prompt: choose `3` then Enter to continue without trusting new hooks.
   - Wait for `Ready.`.

4. Confirm app indexing.
   - Use `codex_app.list_threads` with query `<dir>` or `Projectless dev chat requested by the user`.
   - Confirm `hostId` is `remote-ssh-discovered:dev`.
   - Confirm `cwd` is exactly `/home/giulio/Documents/Codex/<date>/<dir>`.
   - If the cwd is the dated parent directory, close that TUI and retry with the exact `-C` path.

5. Rename and close.
   - Use `codex_app.set_thread_title` to rename it, usually `Dev projectless N` unless the user gave a better title.
   - Close the SSH TUI with Ctrl-C then Ctrl-D if plain Ctrl-D does not exit.
   - Do not leave the exec session running.

6. Final response.
   - Report the thread title, id, and cwd.
   - Mention hooks were not trusted.
