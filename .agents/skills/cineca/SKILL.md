---
name: cineca
description: Set up, renew, diagnose, and use Giulio's CINECA Leonardo SSH access for the IsB33_INSIGHT project on personal macOS machines or Paradevbox. Use only when the request explicitly concerns CINECA, Leonardo, the cineca SSH alias, Smallstep SSH certificates, IsB33_INSIGHT or IscrB_INSIGHT, or Leonardo host-key rotation. Do not use for generic Slurm or HPC work, or for Nebius or Soperator cluster incidents.
---

# CINECA Leonardo access

Use the existing short-lived Smallstep certificate and `cineca` launcher when
they are healthy. Do not rediscover the account, project, endpoints, or browser
flow from Slack or Notion unless the user explicitly asks for source history.

## Route the task

- For status or diagnosis, run `scripts/doctor.sh` from this skill. Add `--live`
  only when an actual Leonardo connection is needed.
- For an ordinary connection, run `cineca` or pass a remote command to it.
- For initial setup, certificate renewal, host-key repair, or a headless browser
  callback, read [references/runbook.md](references/runbook.md) first.
- Install the version-controlled launcher from `scripts/cineca`; do not recreate
  it from memory.

## Boundaries

- The intended account is `gstarace`; the allocation is `IsB33_INSIGHT`, shown
  by `saldo` as `IscrB_INSIGHT`. Do not substitute another CINECA project.
- Credentials live in the `CINECA HPC` item in the 1Password `Employee` vault.
  Authentication is agent-operated by default. Use the 1Password CLI through
  one no-output credentialed child-process boundary and ask the user only to
  unlock or approve 1Password when it is locked. Do not ask the user to reveal,
  copy, paste, or type the email, password, TOTP seed/code, or recovery codes.
  Never place those values in chat, tool inputs or outputs, command arguments,
  logs, the clipboard, or tracked files. If the active browser surface cannot
  receive a credential without crossing one of those boundaries, report that
  capability blocker instead of falling back to manual entry.
- Do not send email or initiate account recovery. If authentication cannot
  proceed, report the exact blocker.
- Certificates belong to each machine's SSH agent, last about 12 hours, and may
  be lost on reboot or agent restart. Never copy a certificate or its private
  key between machines.
- Prefer the in-app Browser for CINECA web authentication. Request that exact
  browser binding rather than allowing URL-based selection to choose another
  browser. If it is unavailable, report that exact blocker. Use Chrome only
  when the user explicitly requests it or approves a switch.
- Treat the OpenSSH post-quantum warning as a CINECA server capability warning;
  do not weaken or globally silence SSH configuration.
