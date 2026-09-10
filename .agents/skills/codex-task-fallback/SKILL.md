---
name: codex-task-fallback
description: Create a real user-owned Codex Desktop task or send an authorized follow-up when native create_thread or send_message_to_thread is missing, especially on SSH-backed projects. Uses the installed CLI and running App Server on the intended host.
---

# Codex Task Fallback

Search for the native task tools first and prefer them when available. Missing
`create_thread` does not establish that task creation is impossible: Desktop's
remote tool exposure can fail while its App Server still supports creation.
This fallback restores the workflow, not the missing native tool registration.

Use only for a user-requested new task or authorized follow-up. A subagent is
not a substitute for a separate user-owned Desktop task.

## Create on the intended host

1. Use `list_projects` to resolve the requested project, host, and exact cwd.
   Run the CLI on that host. `unix://` always means the executing host's server;
   it does not select a destination on another machine. For an SSH destination,
   run there through its existing SSH connection. If the user requests a
   worktree, prepare the isolated checkout first and use its exact cwd.
2. Run `codex app-server daemon version`. Confirm the existing daemon is running.
   Keep the real runtime `CODEX_HOME`; do not start a replacement daemon, restart
   active work, or edit runtime databases to make a task appear in Desktop.
3. Start the installed interactive CLI in a PTY, with the user's actual prompt:

   ```sh
   TERM=xterm-256color codex --remote unix:// --no-alt-screen \
     -C /absolute/project/path -s read-only -a never 'The requested task prompt'
   ```

   The example is for read-only work. Use the already-authorized sandbox for
   implementation work. Preserve the configured model unless the user specifies
   another. Quote the prompt safely; never interpolate arbitrary text as shell
   code. Follow any actual hook-trust or permission prompts without bypass flags.
4. Use Desktop `list_threads` to find the new task by its prompt/title and cwd.
   Verify its **hostId, projectId, cwd, and thread ID** before reporting success.
   If creation has an uncertain outcome, inspect the existing task list before
   retrying. Do not launch duplicates just because the CLI is still starting.
5. Use `wait_threads` to verify progress or completion. Once the initial turn is
   idle, close the CLI with Ctrl-D. This leaves the persisted task available in
   Desktop. Use `set_thread_title` when a requested title needs to be applied.

Do not replace this with `codex exec` and assume equivalent Desktop indexing.
The interactive CLI connected to the existing server was verified on
`paradevbox`, Codex 0.153.3: the resulting task appeared under the saved dotfiles
project and was readable through Desktop's task tools.

## Follow up

Prefer native `send_message_to_thread`. When it is absent, resolve the exact
existing task and its host, confirm it is idle, and run on that same host:

```sh
codex queue --remote unix:// --thread THREAD_UUID \
  --message 'The authorized follow-up prompt'
```

Check the destination through `wait_threads` or `read_thread` to distinguish a
queued message from a started or completed turn. Keep returned identifiers and
do not resend after an uncertain response without inspecting the destination.
On the same 0.153.3 server, this was verified after closing the creating CLI:
the idle task automatically started the queued follow-up and answered in Desktop.

## References

- [Desktop tool-exposure regression](https://github.com/openai/codex/issues/40852)
- [App Server transport](https://learn.chatgpt.com/docs/app-server#protocol)
