# Organizing, Exploring, and Iterating on a Research Topic

> The tool lists below are inferred from the current [Flywheel MCP tool map](../references/flywheel-mcp-tool-map.md). They are likely tool sequences for each step, not verbatim execution logs.

## Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [9:23 pm · 12 Mar 2026](https://x.com/tensorqt/status/2032190671281332280)

now, let's talk about how a lich uses Flywheel. let's start with an experiment i've tried last week

### Quote

### Image Description

```text
A tiny square black avatar with a centered white wireframe cube logo. The cube is drawn with thin clean lines and appears slightly tilted in perspective, like a minimalist 3D box icon floating on a solid black background.
```

Paradigma · @paradigmainc · 12 Mar

Replying to @paradigmainc

Flywheel views Directed Acyclic Graphs as the underlying data structure for research: nodes can be observations or experiments. When they're experiments, they contain an hypothesis and the artifact of the experiments that may reject it. In Flywheel, researchers can focus on

### Image Description

```text
A clean Flywheel graph screenshot on a white canvas. Near the upper-right is a black root node labeled `scheduled muon`, connected to a branching network of pale beige and faint pink circular nodes linked by thin gray lines. Over the center sits a floating card labeled `Branch C1: fixed-alpha sw...` with an `EMPIRICAL` badge. The card text says it executed fixed-alpha sweeps on Shakespeare-char, including finer granularity below 0.5 and broad ranges crossing 0.5. Inside the card is a small plot preview titled `ALPHA_REFINE_BELOW_0.5`, showing a downward-sloping blue line with several marked points and a dashed reference line. More graph branches trail down the left side and into the lower-right corner, giving the impression of a research tree with many experiment offshoots.
```

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_commit_new_node` to create the root `scheduled muon` graph.
- `mcp__flywheel__flywheel_commit_node` to describe the overall research question and first branch.
- `mcp__flywheel__flywheel_branch_node` to split the root into experiment branches.
- `mcp__flywheel__flywheel_get_node_tree` to inspect the DAG as it starts to fill out.
- `mcp__flywheel__flywheel_commit_node` to persist the initial structure.

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032191049431499130)

as you all know, liches are known for obsessing over muon. i make no exception. one thing that always bothered me was how muon was performing this drastic (USV^T )^0 intervention, effectively flattening all singular values.

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to open an insight branch for the core muon observation.
- `mcp__flywheel__flywheel_commit_node` to record the singular-value flattening concern as an explicit insight or hypothesis.
- `mcp__flywheel__flywheel_commit_node` to preserve that observation as a traceable node.

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032191420103110717)

in my mind, there must have been a "softer" way to interpolate between nesterov momentum sgd and muon, in a way that muon would be the "maximum entropy" version of preconditioning

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to fork a new hypothesis branch from the original muon observation.
- `mcp__flywheel__flywheel_commit_node` to capture the "softer interpolation" idea between SGD and muon.
- `mcp__flywheel__flywheel_commit_node` to save the refined hypothesis before experimenting.

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032191844122075385)

so, i decided to spin up my MCP host and do a bunch of experiments. as usual, it quickly became a mess of a trillion wandb runs noone could trace anymore.

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_commit_new_node` or `mcp__flywheel__flywheel_branch_node` to turn scattered runs into explicit branches instead of an untracked run log.
- `mcp__flywheel__flywheel_list_nodes` to enumerate existing branches and runs.
- `mcp__flywheel__flywheel_get_node_tree` to inspect the structure of the experiment graph.
- `mcp__flywheel__flywheel_commit_node` to keep the graph auditable as new work is added.

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032192005883773428)

then, [@thelokasiffers](https://x.com/thelokasiffers) released an early version of our MCP integration for the first time. in a few minutes, this is what my experiments looked like:

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_commit_new_node` to create the root node if it did not already exist.
- `mcp__flywheel__flywheel_branch_node` to fan the work into separate experiment branches.
- `mcp__flywheel__flywheel_get_node_tree` to inspect the resulting DAG layout.
- `mcp__flywheel__flywheel_summarize_node_tree` to quickly understand branch progress and outcomes.
- `mcp__flywheel__flywheel_commit_node` to preserve the graph state.

### Image Description

```text
A tall, narrow node-link graph on a white background. At the upper-left is a solid black node labeled `scheduled muon`, from which a thin gray edge leads into a descending chain of pale beige and soft pink circular nodes. The graph branches intermittently as it moves downward, creating clusters of small leaves around intermediate nodes. The overall structure resembles a research tree or execution DAG, with the black root on the left and the rest of the experiment branches cascading diagonally downward toward the lower-left and middle portions of the image.
```

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032193065595584916)

what i did was pretty simple: i started discussing with the models my intuition: NS in muon is about approximating G(G^TG)^(-1/2). what if we could do it so that we could take a fraction power our matrices instead of just the zeroth? so something looking like US^pV^T

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to create an insight branch for the `US^pV^T` intuition.
- `mcp__flywheel__flywheel_commit_node` to store the proposed fractional-power formulation.
- `mcp__flywheel__flywheel_commit_node` to save the idea before turning it into experiments.

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032195027829477780)

then i realized: if we use NS to have an iteration that approximates powers of -1/2, we could design offline some polinomials that approximated the power of -p

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to open a follow-up hypothesis branch around polynomial approximations.
- `mcp__flywheel__flywheel_commit_node` to record the new approximation strategy.
- `mcp__flywheel__flywheel_commit_node` to preserve the new line of attack.

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032195494437347721)

at this point i started testing this out, would i get really the right spectra? that's when flywheel kicked in: i asked my MCP host to spin up some instances and train some models. in one of the nodes, we can see us sanity checking, and saving plots as artifacts, that we are indeed interpolating between regular SV distribution and zeroth power

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to create the empirical branch for the spectra sanity check.
- `mcp__flywheel__flywheel_commit_node` to record the hypothesis and evaluation criteria.
- `mcp__flywheel__flywheel_request_compute_grant_approval`, `mcp__flywheel__flywheel_compute_acquire`, `mcp__flywheel__flywheel_compute_status`, and `mcp__flywheel__flywheel_compute_connection` to run the experiments on managed compute.
- `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, and `mcp__flywheel__flywheel_finalize_artifact_uploads` to attach the singular-value plot as an artifact.
- `mcp__flywheel__flywheel_commit_node` to mark the empirical step as completed.

### Image Description

```text
A wide screenshot of a Flywheel branch details page titled `Branch A2: polynomial alpha sweeps`, with status pills such as `EMPIRICAL`, `COMMITTED`, `COMPLETED`, and `PRIVATE` across the top. In the main content area, a `SUMMARY` section says the run compared practical approximation behavior against exact-SVD references across the same alpha ranges, and notes `Hypothesis verdict: partially confirmed.` Below that is an `ARTIFACTS` panel containing a chart image. The chart title reads approximately `Singular values after polynomial approx (deg 3) of (G^T G)^(-alpha)`. The x-axis is an index over sorted singular values, the y-axis is logarithmic, and many slanted curves stack from dark blue at the top to yellow near the bottom, accompanied by a vertical color bar labeled `Alpha`. On the far right of the screenshot, a miniature map of the experiment tree appears as a vertical chain of diamond-like markers.
```

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032196071741395160)

at this point, quite a few things were in question, what would happen if i trained a model to interpolate between sgd and muon with this technique, as if "scheduling" muon?

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to fork a new investigation around schedule design.
- `mcp__flywheel__flywheel_commit_node` to record the competing schedule hypotheses.
- `mcp__flywheel__flywheel_commit_node` to preserve the question before launching more runs.

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032197957705994659)

but which way should we schedule? not clear. is it sgd first or muon first? how do we schedule? do we change the lr? this usually gets me quickly tangled in a mess of repos / untrackable experiments and lazy search for a gpu to run my stuff on. with flywheel, i simply desxcribe the experiments and my hypotheses as i wanted them, approved a budget, and then watched the model provision the compute, juggle the experiments, and update the graph in real time with the results, while i was thinking of the ideas

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to split the root into separate schedule and learning-rate branches.
- `mcp__flywheel__flywheel_commit_node` to encode the hypotheses and sweep definitions.
- `mcp__flywheel__flywheel_request_compute_grant_approval` and `mcp__flywheel__flywheel_list_compute_grants` to secure spend before launch.
- `mcp__flywheel__flywheel_compute_acquire`, `mcp__flywheel__flywheel_compute_status`, and `mcp__flywheel__flywheel_compute_connection` to provision GPUs and keep them available to the agent.
- `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, and `mcp__flywheel__flywheel_finalize_artifact_uploads` to attach result plots and cards as branches finish.
- `mcp__flywheel__flywheel_get_node_tree` or `mcp__flywheel__flywheel_list_executions` to monitor the graph as the runs progress.
- `mcp__flywheel__flywheel_commit_node` to finalize each completed empirical branch.

### Image Description

```text
A very wide Flywheel canvas view on a bright white background. In the top-left corner is the `Flywheel` wordmark, and just below it are pill-like controls labeled `Free 1` and `Timeline 2`. Near the upper-middle is a black node labeled `scheduled muon`, connected to a diagonal branching graph of pale beige and pink nodes. Floating over the graph is a card titled `Branch C3: entropy-thres...` with an `EMPIRICAL` badge and descriptive text about sweeping entropy-threshold schedule configurations on Shakespeare-char, including follow-up high-threshold variants. Inside the card is a preview bar chart with several vertical bars shaded from greenish teal to light blue. On the far right side of the canvas is another black node labeled `Attention Sink Hypothe...`, implying a separate connected branch or neighboring graph. The interface also includes small icons in the top-right and a large circular `+` button near the bottom-right corner.
```

### Image Description

```text
A dark-mode chat screenshot rather than a scientific plot. The interface shows previous conversation sections separated by thin horizontal dividers and labels like `4 previous messages` and `1 previous message`. The visible assistant text says budget approval is required before MCP can allocate compute, asks the user to approve a Flywheel compute budget with a suggested cap of `$5`, and includes a blue link labeled `Approve Flywheel compute budget`. To the right, a rounded dark chat bubble reads `go with a 10$`. Lower in the screenshot, another message asks the user to approve an updated `$10` budget request and shows another blue link labeled `Approve $10 Flywheel compute budget`. A second rounded user bubble near the bottom-right says `good`. The whole image uses a black background with white text and muted gray separators.
```

---

### Image Description

```text
A square, dark fantasy avatar showing the head and upper chest of a shadowy armored figure. The armor is black-blue with sharp ridges and an ominous, icy sheen, and two bright cyan-blue eyes glow from beneath the helmet. The overall palette is cold and spectral, giving the image a lich-like, menacing look.
```

## [tensorqt](https://x.com/tensorqt) · [@tensorqt](https://x.com/tensorqt) · [12 Mar](https://x.com/tensorqt/status/2032198847376630125)

i won't spoil for you how this ends. because this will soon be a public graph in Flywheel. In Flywheel, you can share your graphs with your co-authors and even the public, and anyone can contribute their idea, reproduce the experiment or show that it was all luck

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_get_node_sharing` to inspect the current sharing state before changing it.
- `mcp__flywheel__flywheel_set_sharing_for_node` or `mcp__flywheel__flywheel_set_sharing_for_nodes` to share the graph with co-authors or make it public.
- `mcp__flywheel__flywheel_get_node_sharing` again to verify that the sharing settings are correct.
- `mcp__flywheel__flywheel_export_summary` or `mcp__flywheel__flywheel_export_subgraph` to package the graph for outside review or reuse.
