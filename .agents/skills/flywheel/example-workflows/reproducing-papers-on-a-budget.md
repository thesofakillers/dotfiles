# Reproducing Papers on a Budget

> The tool lists below are inferred from the current [Flywheel MCP tool map](../references/flywheel-mcp-tool-map.md). They are likely tool sequences for each step, not verbatim execution logs.

## [@tensorqt](https://x.com/tensorqt) · [13 Mar 2026, 9:34 pm](https://x.com/tensorqt/status/2032555892399305171)

A really interesting way of using Flywheel is to reproduce papers on a budget: I find this new attention trick interesting, although a little counterintuitive in terms of bitterness of the pill. Now I can simply take my MCP host with Flywheel MCP and turn the paper into a graph like this, asking the model to spend at most $10 doing it:

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_commit_new_node` to create the root reproduction graph or first node for the paper.
- `mcp__flywheel__flywheel_branch_node` to split the paper into parallel validation branches.
- `mcp__flywheel__flywheel_commit_node` to capture the paper claim, reproduction plan, and budget constraint.
- `mcp__flywheel__flywheel_request_compute_grant_approval` to enforce the "$10 max" spend before managed compute starts.
- `mcp__flywheel__flywheel_commit_node` to persist the planned graph structure.

### Image Description

```text
A tall, minimalist node-link graph on a white background. Near the upper-left-center is a solid black hub node overlaid by the truncated label "Reproduction Graph. Ex...". Thin, light-gray edges radiate outward from this hub into a loose star of small pastel circles. Most intermediate nodes are pale pink, while several terminal leaf nodes are light beige. Around the hub, multiple short branches fan out in different directions, but one branch dominates the composition: it drops almost straight downward through a chain of pink nodes, then splits near the bottom into three short offshoots ending in two pink leaves and one beige leaf. The image contains large areas of empty white space, making the graph feel sparse and schematic, like an execution tree or experiment dependency graph rather than a dense network diagram.
```

> **Shuangfei Zhai** ([@zhaisf](https://x.com/zhaisf)) · 12 Mar
>
> Say hi to Exclusive Self Attention (XSA), a (nearly) free improvement to Transformers for LM. Observation: for y = attn(q, k, v), yi and vi tend to have a very high cosine similarity. Fix: exclude vi from yi via zi = yi - (yiTvi)vi/||vi||². Result: better training/val
>
> ### Image Description
>
> ```text
> A compact training-loss chart on a pale gray-lavender grid background. The x-axis is labeled "Training iteration (K)" and runs from 0 to 200; the y-axis is labeled "Training loss" and spans roughly 2.4 to 3.2. Six smooth but slightly noisy curves compare baseline and XSA runs for 0.7b, 1.3b, and 2.7b models, with a legend in the upper-right listing `0.7b_baseline`, `0.7b_xsa`, `1.3b_baseline`, `1.3b_xsa`, `2.7b_baseline`, and `2.7b_xsa`. All curves fall sharply early and then taper into slower improvement. For each model size, the XSA line sits below the corresponding baseline line after the initial drop, visually suggesting better training loss. The 0.7b pair occupies the top of the plot, the 1.3b pair the middle, and the 2.7b pair the bottom, with the best-performing line finishing near the lower-right corner around the mid-2.4s.
> ```

---

## [@tensorqt](https://x.com/tensorqt) · [13 Mar](https://x.com/tensorqt/status/2032555896014766151)

The model decides to play it safe: it starts by showing self-attention correlation on a small A10 GPU (provisioned via Flywheel).

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to open the first empirical branch for the baseline correlation check.
- `mcp__flywheel__flywheel_commit_node` to record the hypothesis and experiment setup.
- `mcp__flywheel__flywheel_compute_acquire`, `mcp__flywheel__flywheel_compute_status`, and `mcp__flywheel__flywheel_compute_connection` to provision and use the small A10 GPU.
- `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, and `mcp__flywheel__flywheel_finalize_artifact_uploads` to attach `attn_similarity_by_layer.png`.
- `mcp__flywheel__flywheel_commit_node` to mark the step as a completed empirical result.

### Image Description

```text
A wide screenshot of a Flywheel artifact viewer card titled `attn_similarity_by_layer.png`, with a light header bar and a `Collapse` control in the top-right. Inside the card is a line chart titled "Exp 1A: Baseline attention similarity bias signal". The x-axis is "Layer index" from 0 to 7, and the y-axis is "Mean cos(y_i, v_i)" from about 0.18 to 0.50. A single blue line with circular markers starts low at roughly 0.19 for layer 0, jumps above 0.38 at layer 1, peaks around 0.50 at layer 2, stays near 0.40 through layers 3 to 5, dips noticeably to about 0.31 at layer 6, and rebounds to about 0.42 at layer 7. A black dashed horizontal reference line labeled `global=0.377` cuts across the figure, with most points except the first and sixth layer sitting above that average. The surrounding UI is clean and white, making the plot feel like a generated experimental artifact rather than a paper figure.
```

---

## [@tensorqt](https://x.com/tensorqt) · [13 Mar](https://x.com/tensorqt/status/2032555899424772549)

Step two is analogous: orthogonality before and after XSA.

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to create the next experimental branch.
- `mcp__flywheel__flywheel_commit_node` to record the orthogonality hypothesis for XSA.
- `mcp__flywheel__flywheel_compute_acquire`, `mcp__flywheel__flywheel_compute_status`, and `mcp__flywheel__flywheel_compute_connection` to run the projection check.
- `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, and `mcp__flywheel__flywheel_finalize_artifact_uploads` to attach `orthogonality_by_layer.png`.
- `mcp__flywheel__flywheel_commit_node` to finalize the branch.

### Image Description

```text
A Flywheel artifact screenshot titled `orthogonality_by_layer.png`. The central figure is a two-series line chart labeled "Exp 2A: XSA projection orthogonality by layer". The x-axis is "Layer" from 0 to 7, and the y-axis is "Cosine similarity". A blue series with circular markers, labeled `cos(y, v) baseline direction`, begins around 0.20 at layer 0 and then stays high, roughly in the 0.47 to 0.55 range, across the remaining layers. An orange series with square markers, labeled `cos(z, v) after XSA projection`, lies directly on the zero line for every layer, visually emphasizing that the projected vector has become nearly orthogonal to `v`. Below the chart, a separate text block headed `HYPOTHESIS` states that XSA projection should drive the post-projection inner product toward numerical zero relative to standard self-attention while staying stable within a spend budget of about 100 cents.
```

---

## [@tensorqt](https://x.com/tensorqt) · [13 Mar](https://x.com/tensorqt/status/2032555903250030762)

Then, it moves to overhead of the orthogonal projection.

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to fork an efficiency-comparison branch.
- `mcp__flywheel__flywheel_commit_node` to define the runtime and VRAM hypothesis.
- `mcp__flywheel__flywheel_compute_acquire`, `mcp__flywheel__flywheel_compute_status`, and `mcp__flywheel__flywheel_compute_connection` to run the matched SA vs XSA benchmark.
- `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, and `mcp__flywheel__flywheel_finalize_artifact_uploads` to attach `efficiency_comparison.png`.
- `mcp__flywheel__flywheel_commit_node` to finalize the overhead measurement.

### Image Description

```text
A Flywheel artifact viewer card titled `efficiency_comparison.png`, again with rounded white panel styling and a `Collapse` control in the upper-right. The main plot is a grouped bar chart titled "Exp 3A: SA vs XSA efficiency comparison". Three category labels run along the x-axis: `Train sec`, `Peak VRAM MB`, and `Tok/sec`. Blue bars represent `SA`, while orange bars represent `XSA-final`. On the shared vertical scale, the train-time bars are so short they are nearly flush with the baseline, indicating very similar runtimes. The peak-VRAM bars are close together around the low twelve-thousand-megabyte range, with XSA appearing only slightly different from SA. The throughput bars dominate the chart, both sitting near roughly 125k tokens per second, with the blue SA bar modestly taller than the orange XSA-final bar. Beneath the plot, a `HYPOTHESIS` note says XSA should add only small runtime and VRAM overhead relative to SA for matched shapes under a budget of roughly 150 cents.
```

---

## [@tensorqt](https://x.com/tensorqt) · [13 Mar](https://x.com/tensorqt/status/2032555907864039646)

Up to now, no trouble. The agent then decides to train a 50M parameter model with XSA versus a SA baseline, finding that, at this size, there seems to be no improvements:

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to create the larger training branch.
- `mcp__flywheel__flywheel_commit_node` to record the 50M-parameter comparison and evaluation criteria.
- `mcp__flywheel__flywheel_compute_acquire`, `mcp__flywheel__flywheel_compute_status`, and `mcp__flywheel__flywheel_compute_connection` to run the longer training jobs.
- `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, and `mcp__flywheel__flywheel_finalize_artifact_uploads` to attach `run_metrics.csv` and `quality_pairs.csv`.
- `mcp__flywheel__flywheel_commit_node` to record that the empirical result did not reproduce the expected gain.

### Image Description

```text
A cropped Flywheel results page showing text summary and tabular artifacts instead of a chart. At the top, a section label `SUMMARY` is followed by a sentence stating that the main quality-gain claim was not reproduced at this compact budget and scale, and that XSA underperformed SA in both matched pairs. Below that, an `ARTIFACTS` section displays an expanded table card titled `run_metrics.csv`. Four runs are visible: `long_sa`, `long_xsa`, `short_sa`, and `short_xsa`. Visible columns include `RUN_ID`, `VAL_BPB`, `TRAINING_SECONDS`, `TOTAL_SECONDS`, `PEAK_VRAM_MB`, and the beginning of an `MFU_...` column. The values show XSA with slightly worse validation BPB and slightly higher total time and VRAM than the corresponding SA runs. A second table card titled `quality_pairs.csv` compares `short` and `long` matched pairs at sequence lengths 1024 and 2048. Its visible `DELTA_XSA_MINUS_SA` values are positive, approximately 0.00455 for the short pair and 0.00756 for the long pair, and the `XSA_BETTER` indicator is 0 for both rows. Horizontal scroll bars under both tables emphasize that the screenshot is a cropped view into wider result tables.
```

---

## [@tensorqt](https://x.com/tensorqt) · [13 Mar](https://x.com/tensorqt/status/2032555911999336864)

Also, across sequence length, the trend seems to worsen.

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to spin off an analysis branch for context length.
- `mcp__flywheel__flywheel_get_node` and `mcp__flywheel__flywheel_list_artifacts` to gather results from the completed training branches.
- `mcp__flywheel__flywheel_commit_node` to record the interpretation that the delta worsens at longer context.
- `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, and `mcp__flywheel__flywheel_finalize_artifact_uploads` to attach `length_trend.png`.
- `mcp__flywheel__flywheel_commit_node` to persist the analysis.

### Image Description

```text
A Flywheel artifact card titled `length_trend.png` containing a simple two-point line chart labeled "Step 5: Context-length trend of XSA advantage". The x-axis is "Sequence length" and spans from just above 1000 to just above 2000. The y-axis reads `Delta BPB (XSA - SA, lower is better)`. One blue marker sits near sequence length 1024 with a value around 0.0046, and the second sits near 2048 with a value around 0.0076. A single straight line connects them, slanting upward from left to right. A black dashed horizontal line marks zero across the bottom of the chart, and both measured points remain clearly above it. The visual message is that XSA is worse than SA under this metric at both tested context lengths, and the gap grows as the sequence length increases.
```

---

## [@tensorqt](https://x.com/tensorqt) · [13 Mar](https://x.com/tensorqt/status/2032555915182789045)

At the same time, baseline seems to also win the LR sweeps.

### Likely Flywheel MCP tools for this step

- `mcp__flywheel__flywheel_branch_node` to create a robustness branch for LR sweeps and sink-style perturbations.
- `mcp__flywheel__flywheel_commit_node` to capture the robustness hypothesis.
- `mcp__flywheel__flywheel_compute_acquire`, `mcp__flywheel__flywheel_compute_status`, and `mcp__flywheel__flywheel_compute_connection` to run the compact sweep experiments.
- `mcp__flywheel__flywheel_prepare_artifact_uploads`, raw upload to the returned signed URLs, and `mcp__flywheel__flywheel_finalize_artifact_uploads` to attach `robustness_deltas.png`.
- `mcp__flywheel__flywheel_commit_node` to finalize the robustness verdict.

### Image Description

```text
A Flywheel artifact screenshot titled `robustness_deltas.png`. The central figure is a vertical bar chart labeled "Exp 6A: Robustness deltas across conditions". The y-axis reads `Delta BPB (XSA - SA, lower is better)`, and the x-axis shows three angled category labels: `default_lr_seq1024`, `low_lr_seq1024`, and `sink_proxy_seq256`. All three bars are blue and all are positive, with heights around 0.0045, 0.0051, and 0.0063 respectively. The rightmost `sink_proxy_seq256` bar is the tallest, while `default_lr_seq1024` is the shortest. Since every bar is above zero, the chart visually indicates that none of the tested robustness conditions produced an XSA win by this metric. Beneath the plot, a `HYPOTHESIS` note says XSA advantage should remain non-negative across a compact learning-rate sweep and one attention-sink perturbation setting under a budget of about 150 cents.
```
