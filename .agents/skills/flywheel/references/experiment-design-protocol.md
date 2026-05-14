# Experiment Design Protocol

Use this when the user needs help turning research intent into a well-formed experiment or exploration before spending compute.

## Goal

Help the user clarify what they are trying to learn, shape the work around that question, and avoid wasting compute before the design is solid.

## Operating rules

- Treat design and execution as separate phases.
- Optimize for clarity of experimental purpose, not speed to a first run.
- Adapt depth to the user's experience and the clarity already present in the conversation.
- Apply epistemic discipline: separate what is known from what is assumed, and name uncertainty instead of smoothing it over.
- Support both hypothesis-driven and exploratory work.
- Support simple runs and complex shapes such as multi-stage pipelines, sweep-then-deep-dive, multi-arm comparisons, and custom structures.
- Keep all 10 brief fields, but allow exploratory fields to be marked `exploratory` or `TBD` rather than fabricated.
- Use quick Socratic questioning to surface assumptions, confidence, and what would change the user's mind. Keep it to 1-2 short questions per turn.
- Propose defaults for structural choices such as experiment shape, stop condition, or artifact plan. Use questions rather than defaults for epistemic choices such as beliefs, assumptions, and what evidence would matter.
- When a reasoning or design gap is visible, raise it as a question rather than an assertion.
- If the core gate is satisfied and the user wants to proceed, stop asking more design questions.
- Use Flywheel `insight` nodes to preserve design context when it will help across turns or sessions.

## Phase 1: Clarify what the user is trying to learn

Start with:

1. What are you trying to learn or decide?
2. Is this mainly hypothesis-driven or exploratory right now?

Keep this phase quick. Ask 1-2 short questions per turn, and use light Socratic questioning as an epistemic check after the user states the learning goal: briefly surface what seems known versus assumed before moving on.

If the work is hypothesis-driven, ask:

- What is the hypothesis?
- Compared to what baseline or alternative?
- What result would matter?

If the work is exploratory, ask:

- What is the big question?
- What would you need to learn first before tackling it?
- What is the cheapest or cleanest way to learn that first piece?
- What signal or pattern are you looking for?

If the user is still fuzzy after this phase, stay in planning mode. If needed, create or update an `insight` node rather than an `empirical` node.

## Phase 2: Shape the work

Choose or define the experiment shape through quick Socratic questioning:

- single focused run
- multi-stage pipeline
- sweep then deep-dive
- multi-arm comparison
- custom shape

If the user is unsure about structure, propose a default shape, stop condition, or artifact plan instead of extending the question loop.

Then fill the experiment brief:

- `question`: the decision or learning goal
- `hypothesis`: the claim being tested
- `comparator`: the baseline or alternative
- `unit_of_work`: what one run, branch, or stage actually changes
- `primary_metric`: the main number or observable to inspect
- `artifact_plan`: which artifact will help interpret the result
- `budget_cap`: max spend or runtime for the current stage
- `stop_condition`: when to stop rather than letting the run expand
- `interpretation`: what would count as signal, no signal, or ambiguity
- `next_branch_if_inconclusive`: the follow-up branch if the result is unclear

For exploratory work, `hypothesis` or `comparator` may be marked `exploratory` or `TBD`, but the learning goal still needs to be explicit.

## Phase 3: Run the adaptive design gate

Frame the gate as preventing waste, not enforcing bureaucracy.

Always check:

- the question or goal is explicit
- at least one metric or observable is defined
- a budget cap or stop condition exists

For hypothesis-driven work, also check:

- there is a falsifiable hypothesis
- there is a comparator or baseline

For exploratory work, instead check:

- the user can say what they are looking for
- the first learning step is scoped well enough to run

Additional checks when relevant:

- an artifact plan exists, or the node content states why the run is intentionally artifact-free
- the run shape matches the question and is not changing too many important things without purpose
- an interpretation rule or next branch is defined

If the core gate passes and the user wants to proceed, let them run even if some non-core details are still `TBD`.

When blocked, ask only the next necessary question instead of reopening the whole brief.

## Phase 4: Confirm the plan

Before any compute request or training launch, restate:

- what we are trying to learn
- the experiment shape
- the metric or observable
- the artifact plan
- the budget or stop condition
- what result would change the next step

If the run is expensive or high-risk, ask for explicit confirmation.

## Phase 5: Drive Flywheel

Use Flywheel in layers when possible.

Before execution, load `references/flywheel-mcp-tool-map.md` and verify the
exact tool surface exposed by the current MCP host before critical flows.

### Design layer

Use an `insight` node to capture rationale, open questions, experiment shape, and any decomposition needed for exploratory or multi-stage work.

Typical flow:

1. `mcp__flywheel__flywheel_commit_new_node`
2. `mcp__flywheel__flywheel_acquire_stage_lease` when refining an existing design node
3. `mcp__flywheel__flywheel_commit_node` once the design brief is coherent

### Execution layer

Only after the design gate passes, create or branch the node for the runnable part of the work.

Typical flow:

1. `mcp__flywheel__flywheel_branch_node` or `mcp__flywheel__flywheel_commit_new_node`
2. `mcp__flywheel__flywheel_acquire_stage_lease` + `mcp__flywheel__flywheel_commit_node` with the explicit run summary and the local question or hypothesis for that branch
3. `mcp__flywheel__flywheel_request_compute_grant_approval` only after the user accepts the design
4. `mcp__flywheel__flywheel_list_compute_grants(status=active, approval_session_id=<session_id>)` when you need to resolve the approved `compute_grant_id`
5. `mcp__flywheel__flywheel_compute_acquire` and related compute tools only when execution is actually needed
6. `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, then `mcp__flywheel__flywheel_finalize_artifact_uploads`
7. Do a brief epistemic check before commit: verify what the evidence actually shows, whether it matches the interpretation rule from the brief, and whether any gap between the data and the hoped-for story needs to be named explicitly in the node summary.
8. `mcp__flywheel__flywheel_commit_node`

Important notes:

- Exploratory work can stay as planning content until a specific empirical probe is ready.
- Record each runnable exploratory probe as a concrete local question or hypothesis in the branch content.
- For multi-stage or multi-arm work, use branches to represent stages or arms and keep summaries clear about how each branch feeds the next.
- Attach artifacts when empirical work produces evidence; when it is intentionally artifact-free, state that rationale in node content.

## Adaptive question flow

Ask in short batches of 1-2 questions per turn. Keep the flow light, Socratic, and epistemic rather than exhaustive.

1. What are you trying to learn or decide?
2. Is this hypothesis-driven or exploratory?
3. Briefly separate what the user seems to know from what they seem to be assuming before locking the design.
4. If hypothesis-driven: what is the hypothesis and compared to what?
5. If exploratory: what is the first thing you need to learn and what is the cheapest way to learn it?
6. What experiment shape fits this work?
7. What metric or observable and artifact will you inspect?
8. What budget or stop condition keeps this from wasting compute?
9. What interpretation rule will distinguish evidence from expectation?
10. If the result is ambiguous, what is the next branch?

## Output template

Use this shape when turning a vague request into an executable plan:

```md
Experiment brief

- Question:
- Hypothesis:
- Comparator:
- Unit of work:
- Primary metric or observable:
- Artifact plan:
- Budget/time cap:
- Stop condition:
- Interpretation rule:
- Next branch if inconclusive:

Experiment type: hypothesis-driven | exploratory
Design gate: ready | blocked
Remaining gap:
Recommended next action:
```

## Generalization rule

Reuse the same protocol across domains by changing the unit of work and artifact type:

- model training -> metrics tables, loss curves, checkpoints
- benchmark comparisons -> score tables, latency plots, error slices
- prompt evaluations -> rubric tables, failure examples, sampled outputs
- product experiments -> funnels, event tables, user-segment slices
- scientific workflows -> figures, logs, result tables, notebooks
