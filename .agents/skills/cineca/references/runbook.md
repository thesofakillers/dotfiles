# CINECA Leonardo runbook

Use this runbook for setup, renewal, browser callbacks, and recovery. The
official source of truth is CINECA's current
[access documentation](https://docs.hpc.cineca.it/general/access.html).

## Stable account facts

| Item | Value |
| --- | --- |
| Cluster | Leonardo |
| SSH endpoint | `login.leonardo.cineca.it` |
| SSH username / certificate principal | `gstarace` |
| UserDB project | `IsB33_INSIGHT` |
| `saldo` allocation label | `IscrB_INSIGHT` |
| Smallstep CA | `https://sshproxy.hpc.cineca.it` |
| Smallstep provisioner | `cineca-hpc` |
| 1Password item | `Employee` vault, `CINECA HPC` item |
| Certificate lifetime | About 12 hours; lost on reboot or SSH-agent restart |

The UserDB email, password, TOTP seed/codes, recovery codes, certificate private
key, and browser state are machine/user secrets. Keep them out of Git, prompts,
tool output, shell arguments, and temporary files. The email identity file is
`~/.step/cineca-email`, mode `0600`; inspect its existence and mode, not its
contents.

## Diagnose first

From this skill directory:

```bash
scripts/doctor.sh
scripts/doctor.sh --live  # only when an end-to-end connection is needed
```

The normal command is:

```bash
cineca
cineca '<remote command>'
```

The launcher reuses a valid certificate and starts CINECA's browser login only
when renewal is required.

## One-time macOS setup

Mutate only the requested machine. Back up existing SSH files before changing
them, preserve unrelated configuration, and verify each target immediately
before replacement.

1. Install `step`, `jq`, and OpenSSH. Prefer an already installed `step`.
   Software installation requires the user's approval. On a Homebrew Mac,
   `brew install step` is the normal path. Paradevbox is a Standard macOS
   account; install a verified official arm64 release under `~/.local/bin`
   rather than using `sudo` or writing into a shared prefix.

2. Bootstrap CINECA's CA using the fingerprint published in the current CINECA
   access documentation:

   ```bash
   step ca bootstrap \
     --ca-url=https://sshproxy.hpc.cineca.it \
     --fingerprint=2ae1543202304d3f434bdc1a2c92eff2cd2b02110206ef06317e70c1c1735ecd
   step ca health
   ```

3. Put the registered UserDB email in `~/.step/cineca-email` with mode `0600`.
   Obtain it through a user-controlled 1Password surface. Do not print or copy
   it through model/tool context.

4. Add this narrow block to `~/.ssh/config`:

   ```sshconfig
   # CINECA Leonardo (authentication uses a 12-hour Smallstep SSH certificate).
   Host cineca leonardo
     HostName login.leonardo.cineca.it
     User gstarace
   ```

5. Refresh Leonardo's rotating login-node keys using the current command in
   CINECA's access documentation. Do not commit a snapshot of host keys. The
   current documented nodes are `login01-ext`, `login02-ext`, `login05-ext`,
   and `login07-ext`, generalized to `login*.leonardo.cineca.it`. Back up
   `~/.ssh/known_hosts` first, remove only CINECA/Leonardo entries, then run the
   documented `ssh-keyscan` loop.

6. Install the version-controlled launcher:

   ```bash
   install -d -m 0755 ~/.local/bin
   install -m 0755 scripts/cineca ~/.local/bin/cineca
   ```

   Resolve `scripts/cineca` relative to this skill directory, not the caller's
   repository. Ensure `~/.local/bin` is on PATH.

7. Request a machine-local certificate and validate:

   ```bash
   cineca 'id -un; hostname'
   scripts/doctor.sh --live
   ```

## Browser authentication and Paradevbox

CINECA's `step-ca` OIDC client does not permit the device-authorization grant,
so `step ssh login --console` fails. Use the normal loopback browser flow.

On a graphical Mac, this is sufficient:

```bash
step ssh login "$(tr -d '\r\n' < ~/.step/cineca-email)" \
  --provisioner cineca-hpc
```

For a login running on Paradevbox while the browser runs on the controlling
Mac:

1. Start an SSH tunnel from the controlling Mac:

   ```bash
   ssh -N -o ExitOnForwardFailure=yes \
     -L 10000:127.0.0.1:10000 paradevbox
   ```

2. In a separate Paradevbox SSH session, recover the persistent macOS agent
   socket, then start the browser flow without trying to open a remote browser:

   ```bash
   agent_socket=$(
     launchctl print "gui/$(id -u)/com.openssh.ssh-agent" |
       awk '$1 == "SSH_AUTH_SOCK" && $2 == "=>" { print $3; exit }'
   )
   export SSH_AUTH_SOCK="$agent_socket"
   STEP_OPEN_BROWSER=0 step ssh login \
     "$(tr -d '\r\n' < ~/.step/cineca-email)" \
     --provisioner cineca-hpc
   ```

3. Open the printed one-time URL in the in-app Browser. The callback to
   `127.0.0.1:10000` crosses the SSH tunnel to Paradevbox. Reuse an authenticated
   CINECA session when available.

4. If CINECA asks for username, password, or OTP, keep entry in 1Password's own
   autofill/reveal UI under user control. Do not retrieve or paste secret values
   through agent or browser-tool context. Never send email or start account
   recovery.

5. Wait for `CA: https://sshproxy.hpc.cineca.it` and `SSH Agent: yes`, stop the
   temporary tunnel, then run the live doctor.

## Recovery

- **Certificate missing or expired:** run the normal browser login. Do not copy
  a certificate from the other Mac.
- **No SSH agent in a Paradevbox SSH shell:** use the launchd socket discovery
  above. The version-controlled launcher already does this automatically.
- **Host identification changed:** use CINECA's current documented Leonardo
  host-key refresh procedure, not `StrictHostKeyChecking=no` and not a blanket
  known-hosts deletion.
- **Post-quantum warning:** this is emitted by modern OpenSSH because CINECA's
  server did not negotiate a post-quantum key exchange. It does not block the
  connection; do not weaken global SSH settings.
- **Unexpected project/account:** stop. The expected project is
  `IsB33_INSIGHT`, shown by `saldo` as `IscrB_INSIGHT`.
