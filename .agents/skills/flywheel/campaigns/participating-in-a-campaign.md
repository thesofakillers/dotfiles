# Participating in a Campaign

Campaigns are challenge-style Flywheel graphs where an organizer shares a root graph, defines the objective and submission contract, and may fund participant compute through campaign budgets.

To participate in a campaign:

1. Get access to the campaign root. Invite-only campaigns are shared directly with your Flywheel account. Open campaigns are made public by the organizer.
2. Open the campaign in the WebUI or ask your MCP host to inspect the root node.
3. Read the campaign root carefully before you start. Organizers can define the objective, submission format, graph hygiene, repo policy, GPU guidance, and any evaluation rules directly on the root.
4. Do your work in your own part of the graph. Use Flywheel nodes to record your progress, artifacts, summaries, and conclusions so your submission stays reviewable. When the campaign asks for a canonical submission artifact, finalize that artifact on your public attempt node with `metadata.campaign_role=submission`.
5. If the campaign provides compute funding, discover the available budget grants and acquire compute against the campaign grant your MCP host shows you.

The practical rule is simple: the campaign root tells you the contract, and your graph is how you show your work.

## Checking Submission Status

Accepted campaign submission artifacts get a durable lifecycle record. After finalizing a submission artifact, use:

- `flywheel_get_artifact_campaign_submission` when you know the node id and artifact id
- `flywheel_list_node_campaign_submissions` to see recent submissions for an attempt node
- `flywheel_get_campaign_submission` when you already have a submission id

Invalid submissions fail immediately with `422` and do not create a lifecycle record. `forwarded` means Flywheel handed the submission to the campaign automation; it does not necessarily mean the external scorer has completed. Terminal states are `scored`, `rejected`, and `failed`.

## Coming Soon

- A dedicated tutorial section for setting up a campaign as an organizer.
- A dedicated tutorial section for sponsoring or funding a campaign.
