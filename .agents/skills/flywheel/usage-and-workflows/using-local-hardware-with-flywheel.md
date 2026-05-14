# Using Local Hardware with Flywheel

Yes, you can use Flywheel with your local hardware.

Flywheel does **not** require managed cloud compute for every workflow. If you want to run experiments on your own machine, you can tell your MCP host that you want to use local hardware instead of provisioning managed compute.

This guide is based on direct team clarification:

- local hardware use is supported
- you should tell your MCP host explicitly that you want to use your local machine
- if the host refuses or insists on remote provisioning, that is something worth flagging

## What to tell your MCP host

Be explicit. For example:

```text
Use my local hardware for this experiment.
Do not provision managed compute.
Run this on my local GPU / local machine instead.
```

If you want Flywheel to track the work but not spin up remote machines, say so directly.

## Typical workflow

1. Ask your MCP host to create or use a Flywheel node for the experiment.
2. State clearly that the experiment should run on your local hardware.
3. Let the host organize the work in Flywheel while executing locally.
4. Review the results and attached artifacts in Flywheel as usual.

## When the MCP feels ambiguous

If the contract or tool behavior feels ambiguous, use more explicit wording such as:

```text
Create a node for this experiment, but keep execution local.
Do not request budget approval.
Do not acquire managed compute.
Use my local machine only.
```

## If it refuses

If your MCP host refuses to use local hardware, tries to provision remote compute anyway, or acts as if managed compute is mandatory:

- restate the request more explicitly
- tell it not to request budget approval
- tell it not to acquire managed compute
- report the behavior, since the Flywheel team has already said they want to make this contract clearer

## Practical takeaway

- Flywheel can use managed compute
- Flywheel can also be used with local hardware
- if you want local execution, say it explicitly
- if the host refuses, that is likely a tooling or contract clarity problem, not a sign that local hardware is unsupported
