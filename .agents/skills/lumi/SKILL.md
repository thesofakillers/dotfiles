---
name: lumi
description: Set up, renew, diagnose, and use Giulio's LUMI (EuroHPC, CSC Finland) SSH access for project_465003762 on his personal Mac. Use only when the request explicitly concerns LUMI, LUMI-G, EuroHPC or the EuroHPC Federation Platform (EFP), the lumi or eurohpc SSH alias, sshca.my-eurohpc.eu certificates, or project_465003762. Do not use for CINECA Leonardo, Kyoto, Nebius, or generic Slurm work.
---

# LUMI access

LUMI-G is the AMD GPU partition of the LUMI supercomputer. Access came
through the EuroHPC AI Factory grant `EHPC-AIF-2026PG01-1771` led by Emanuele
Rodolà. The Slack thread says the project ends on 2026-12-26.

## Known setup (this Mac only)

- User `staraceg`; Slurm account `project_465003762`.
- Login host `efp.lumi.csc.fi` (not `lumi.csc.fi`). Alias: `ssh lumi` or
  `ssh eurohpc` in `~/.ssh/config`.
- Key `~/.ssh/id_EFP` (ed25519, no passphrase). Certificate
  `~/.ssh/id_efp.lumi.csc.fi-cert.pub`. The certificate authority's host key for
  `sshca.my-eurohpc.eu` is in `~/.ssh/known_hosts`.
- The alias reuses one connection (`ControlMaster auto`, `ControlPersist yes`,
  socket `~/.ssh/cm-%C`). A master connection opened while the certificate is
  valid keeps working after the certificate expires.
- Run all of this on the Mac. Do not set it up on paradevbox unless asked.

## Check status

- `ssh -O check lumi`: is a master connection running?
- `ssh-keygen -L -f ~/.ssh/id_efp.lumi.csc.fi-cert.pub | grep Valid`: when does
  the certificate expire?
- `ssh -o BatchMode=yes lumi lumi-allocations`: does login work, and how much
  of the budget is used?

If a master connection is running, nothing else is needed. If none is running
and the certificate has expired, renew it.

## Renew the certificate (every 10 hours)

Renewal needs Giulio's SPID login. An agent cannot do it alone.

1. In the Claude in Chrome browser **on this Mac**, open
   `https://sshca.my-eurohpc.eu`. Several Chromes may be connected; check with
   `list_connected_browsers` and use the one marked `onThisComputer`.
2. Click "Login to EuroHPC Federation Platform", then the eIDAS
   (SwedenConnect) entry, then Italy, then "Entra con SPID", then PosteID.
3. Ask Giulio to scan the PosteID QR code. It expires after 120 seconds.
4. After login, the portal lists LUMI with an `ssh ... token <TOKEN> >
   ~/.ssh/id_efp.lumi.csc.fi-cert.pub` command. Copy the command shown on the
   page each time and run it locally. Do not reuse an old token.
5. Open a master connection right away with `ssh lumi true`, so later calls
   keep working while that connection stays up.

## Running work

- GPU nodes: 4x AMD MI250X per node. Slurm shows each card as 2 GPUs, so
  there are 8 GPUs per node with 64 GB each. The stack is ROCm, not CUDA.
- Partitions: `dev-g` (30 min max, for debugging), `small-g` (part of a
  node), `standard-g` (full nodes).
- Always pass `--account=project_465003762`.
- Allocation on 2026-11-25: 5000 GPU-hours, 1000 CPU core-hours, 20000
  TB-hours. Check `lumi-allocations` before large jobs.

## Boundaries

- Do not copy the key or certificate to another machine.
- Do not ask Giulio to type SPID credentials into chat. He logs in himself.
- Docs: https://docs.lumi-supercomputer.eu/ and
  https://docs.my-eurohpc.eu/direct-ssh/
