---
name: cineca
description: Set up, renew, diagnose, and use Giulio's CINECA Leonardo SSH access for the IsB33_INSIGHT project on personal macOS machines or Paradevbox. Use for CINECA, Leonardo, the cineca SSH alias, Smallstep SSH certificates, IsB33_INSIGHT or IscrB_INSIGHT, and Leonardo host-key rotation.
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
  Never commit or print its email, password, TOTP seed/code, or recovery codes.
  If the browser asks for credentials, keep entry in a user-controlled
  1Password autofill or reveal surface; do not copy secret values through model
  or tool context.
- Do not send email or initiate account recovery. If authentication cannot
  proceed, report the exact blocker.
- Certificates belong to each machine's SSH agent, last about 12 hours, and may
  be lost on reboot or agent restart. Never copy a certificate or its private
  key between machines.
- Prefer the in-app Browser for CINECA web authentication. Use Chrome only when
  the user explicitly requests it or approves a switch.
- Treat the OpenSSH post-quantum warning as a CINECA server capability warning;
  do not weaken or globally silence SSH configuration.
