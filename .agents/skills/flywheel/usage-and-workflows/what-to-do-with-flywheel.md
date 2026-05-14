# What to do with Flywheel?

In our experience the best way to get an answer to this question is to ask it to your MCP host:

```console
$ <your-mcp-host> "tell me about flywheel, what can i do with it?"

In this workspace, Flywheel is a node-based system for organizing and executing
work (especially research/experiments) with reproducibility and auditability
built in.

What you can do with it:

- Create work nodes for thinking, analysis, and empirical experiments.
- Build a graph of work with branching/merging, not just a linear log.
- Commit outcomes as Markdown content, optional summaries, artifacts, tags, and executions so results stay consistent.
- Launch managed compute for a node with budget controls and track execution state.
- Attach artifacts to nodes (text, tables, JSON, images, HTML/plots, checkpoints, diffs).
- Configure hooks that call external HTTP endpoints when events occur.
- Collaborate with others by sharing nodes/graphs.
- Tag nodes, audit changes, and export summaries/PDFs/subgraphs.

Typical use cases:

- Experiment tracking with hypotheses + evidence.
- Decision logs and technical investigations.
- Team-shared research graphs with reproducible outputs.
- Converting a messy exploration into a reviewable, auditable record.

If you want, I can walk you through creating your first node and a minimal workflow for your current project.
```

Francesco is documenting some example workflows on his [X profile](https://x.com/tensorqt), like [organizing, exploring and iterating on a research topic](https://x.com/tensorqt/status/2032190671281332280?s=20) or [reproducing papers on a budget](https://x.com/tensorqt/status/2032555892399305171).

We'll be sharing more example workflows there and also through our [Discord](https://discord.gg/aFg4zskefj), where we do weekly office hours. You should join!

## Configure Hooks (Node Automations)

Hooks are event-driven automations:

- **Event**: a durable "something happened" record. Supported hook events are
  `artifact.finalized` and `node.published`.
- **Hook**: a durable rule configured on a node (trigger + scope + action).
- **Run**: one execution record when a hook reacts to an event.
- Hooks are dispatched by `worker-hooks` and executed by ephemeral Fly Machines runners.
- Each hook run launches `python -m server.run_hook_runner` in the same Fly app (`FLYWHEEL_HOOK_RUNNER_FLY_APP`).
- Deployments roll out `worker-hooks` before `worker-projection`; runner launches require `FLYWHEEL_HOOK_RUNNER_FLY_API_TOKEN` and `FLYWHEEL_HOOK_RUNNER_FLY_APP`.

Typical setup:

1. Create secrets for endpoint credentials:
   `flywheel_create_hook_secret`.
2. Create the hook:
   `flywheel_create_hook` (declare `workflow_yaml.on`, choose scope, define
   HTTP action).
3. Turn it on:
   `flywheel_set_hook_enabled`.
4. Verify behavior:
   `flywheel_list_hook_runs`.

WebUI path: open a node and use the **Hooks** panel in the right-side node
panel area.
