# Managed Compute

Flywheel can provision managed GPU instances for you from providers like Lambda Labs, Modal, Vast.ai, Prime Intellect, Nebius, and RunPod — directly from your agent conversation. You don't need to leave your workflow to spin up machines.

## How it works

1. **Ask your agent for compute.** When you need a GPU for an experiment, just say so:

   ```console
   $ <your-mcp-host> "I need a GPU to train a small transformer on this dataset"

   I'll provision a GPU for this node. First, I need you to approve a budget.
   Opening the approval page now...
   ```

2. **Approve a budget.** Flywheel opens an approval page in your browser where you set a spending cap for managed compute acquisition.
3. **Review and choose a GPU.** The agent lists current offers, recommends one option with rationale, presents alternatives, and waits for your explicit confirmation before acquiring.
4. **The agent acquires and connects.** After explicit confirmation, the agent acquires a machine, waits for it to become ready, and gets SSH access automatically. Provisioning typically takes a few minutes — the agent polls for readiness in the background.
5. **Release when done.** When you're finished, the agent releases the lease. You can also release leases from the WebUI at any time.

For autonomous runs, agents should default to releasing only known leases
(leases acquired in the current run or explicitly selected by the user). If
unknown active leases are detected, agents should report and skip those leases
by default. Use account-wide release only when the user explicitly requests it.

## Managing machines in the WebUI

In **Settings > Machines**, you can see all GPU leases across your account — including the provider, state, hourly rate, total spend, and the acquire context that originally launched each lease. You can release individual leases or all at once.

![settings machines view](https://flywheel.paradigma.inc/assets/settings_machines-CJd5Iw8W.png)

Inside a node, the node view focuses on compute policy and budget tracking (spent vs. hard cap). Active machines themselves are managed from the account level **Settings > Machines** view.

## Credits and billing

Compute is billed against your Flywheel credits balance, which is separate from your subscription.

- The **Pro subscription** ($20/month or $204/year) includes $10 in non-rollover credits each Pro cycle. Those credits refresh when the plan renews, while separately purchased credits do not expire.
- During beta, **Pro (Beta)** users receive the same Pro-cycle credit allowance without billing while beta access remains active.
- You can check your balance in **Settings > Credits**.
- Before any compute is provisioned, you approve a spending cap — no surprises.
- **User budgets** fund your own managed compute usage. Campaign organizers can also fund participant compute through root-backed campaign budgets (more on this in the next section).

For a focused reference, see `compute/credits-and-billing.md`.

## Recommendation procedure

### Step 1 - Filter to allowed options

- Input: `options` from `flywheel_compute_list_options`.
- Keep only entries where `allowed == true`.
- If empty, return "empty option list" failure mode and stop.

### Step 2 - Extract task signals from node text

- Read `node.content` and `node.summary`.
- Extract:
  - `weight_class` in `{light, medium, heavy, unknown}`
  - `expected_runtime_hours`
  - `min_vram_gb`
- Defaults:
  - `expected_runtime_hours`: `1` for light, `3` for medium, `8` for heavy, `unknown` when weight is unknown.
  - `min_vram_gb`: `0` for light, `24` for medium, `40` for heavy.
- If any signal is `unknown`, ask exactly one clarifying question:
  - "Roughly what size model and how long do you expect to run?"
- LLM judgment is allowed only in this step.

### Step 3 - Apply affordability filter

- Compute `runway_hours = budget_remaining_cents / price_cents_per_hour` for each option.
- Drop options where `runway_hours < expected_runtime_hours * 1.25`.
- `1.25` is fixed in this issue; do not change it.
- If empty, return "all options over cap" failure mode and stop.

### Step 4 - Apply minimum VRAM filter

- Drop options where `gpu_memory_gb < min_vram_gb`.
- If this would empty the set, keep the Step 3 set and mark `VRAM-constrained fallback`.
- Use the Step 4-qualified set for subsequent ranking, alternatives, and retries.
- Use the Step 3 survivors for those later decisions only when `VRAM-constrained fallback` is active.

### Step 5 - Rank and pick recommendation

Evaluate buckets in this order and stop at the first non-empty bucket:

1. Preferred + affordable + VRAM-met (`offer_id` in `preferred_offer_ids`)
2. Affordable + VRAM-met
3. Affordable fallback (when `VRAM-constrained fallback` is active)

Sorting rules:

- Buckets 1 and 2 primary sort: cheapest `price_cents_per_hour`.
- Bucket 3 primary sort: largest `gpu_memory_gb`, then cheapest on tie.

Tie-breakers (only when primary sort values are exactly equal):

1. `availability_mode == live_capacity` before `allocation_time`
2. `price_kind == provider_reported` before `estimate`
3. more `regions` entries first
4. lexicographic `offer_id`

### Step 6 - Build recommendation rationale

Include:

- GPU identity: `{gpu_model} ({gpu_memory_gb}GB)`
- Hourly rate in dollars per hour
- Estimate suffix when `price_kind == estimate`
- Runway statement using `budget_remaining_cents`
- Weight-class match statement
- Availability note only when non-default
- Provenance tag for preferred-list pick or VRAM fallback

### Step 7 - Select up to two alternatives

From the active candidate set (Step 4-qualified set by default; Step 3 survivors only when `VRAM-constrained fallback` is active), fill at most two slots in this order:

1. Reliability alternative (only if recommendation is `allocation_time`): cheapest `live_capacity`
2. Cheaper alternative: strictly cheaper than recommendation
3. Headroom alternative: strictly higher `gpu_memory_gb` than recommendation

Display order:

1. recommendation first
2. filled alternatives in slot order

Never display more than three total options.

### Step 8 - Require confirmation and handle acquire failure

- Wait for explicit user confirmation (or explicit user override offer id) before `flywheel_compute_acquire`.
- When acquiring, `requested_sku` must equal the exact selected `options[].offer_id` from `flywheel_compute_list_options` (copy verbatim, including provider prefixes like `nebius::...`; never use display names).
- On acquire failure due to capacity:
  1. pick next-best candidate from the active candidate set (excluding failed offer),
  2. same provider -> retry immediately without re-confirmation,
  3. different provider -> ask user to re-confirm before retry,
  4. cap retries at 3 total acquire attempts per user confirmation,
  5. for `flywheel-auto` with `k > 1`, apply retry cap and confirmation boundary per worker.

Fixed numeric defaults for this flow:

- `1`, `3`, `8` runtime defaults
- affordability multiplier `1.25`
- acquire retry cap `3`

## Presenting the options

- Always show the recommended offer first with rationale.
- Then show up to two alternatives.
- Always wait for explicit user confirmation before calling `flywheel_compute_acquire`.
- If the user provides an explicit offer-id override, treat it as first-class only if it exactly matches one of the current `options[].offer_id` values; then proceed after confirmation.

For persistent preference, set `preferred_offer_ids` in the node compute policy.

## Tips

- Provisioning takes a few minutes — the agent polls automatically, so you don't need to babysit it.
- You can walk away; Flywheel continues while the machine spins up.
- Release leases when you're done to save credits.

## Provider Setup (Operators)

Managed compute providers are enabled by backend environment variables. For Nebius, configure:

- `NEBIUS_SERVICE_ACCOUNT_ID`
- `NEBIUS_SERVICE_ACCOUNT_PUBLIC_KEY_ID`
- `NEBIUS_SERVICE_ACCOUNT_PRIVATE_KEY_PEM`
- `NEBIUS_PARENT_ID`
- `NEBIUS_SUBNET_ID`
- one of `NEBIUS_BOOT_IMAGE_ID` or `NEBIUS_BOOT_IMAGE_FAMILY`
- optional: `NEBIUS_BOOT_IMAGE_FAMILY_PARENT_ID`, `NEBIUS_SECURITY_GROUP_IDS`

Deploy preflight treats Nebius as a valid standalone provider bundle when all required Nebius keys are present.

NEBIUS_BOOT_IMAGE_FAMILY_PARENT_ID and NEBIUS_SECURITY_GROUP_IDS are optional runtime defaults and are not validated by deploy preflight.

These secrets must be injected via your deployment secret manager (for Fly.io backend apps, use `flyctl secrets set`). Do not commit provider secrets in repository files.
