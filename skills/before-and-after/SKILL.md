---
name: before-and-after
description: Use when a code change is meant to improve performance (fewer SPARQL/SQL queries, fewer backend or triple-store round trips, batching, caching, lower latency) and no measured evidence exists yet, when the user asks to instrument before/after performance metrics for a fix, branch, or PR, or when about to open a PR whose central claim is a performance improvement.
---

# Before and After

## Overview

A performance change is not complete when the code works — it is complete when the improvement is **measured**. This skill produces empirical before/after evidence and puts it in the PR.

Core principle: **never claim, estimate, or extrapolate a number. Every figure in the report comes from a measurement that was actually run.** If measurement is blocked, say so explicitly in the PR instead of silently omitting the section.

Invocation arguments are optional hints that pre-answer discovery: an environment description ("API on localhost:9393 against staging"), or a target ("PR #309", a branch name). Anything not supplied is discovered; anything not discoverable is asked.

## Establish what to compare

- **After** = the change: current branch/working tree, or the PR/branch/commit named in the arguments.
- **Before** = the merge-base of the change with the main branch (`git merge-base HEAD origin/main`) — NOT main's HEAD, which may contain unrelated commits.
- When invoked after the change is already implemented (the common case), use `git worktree add` or stash/checkout to run identical measurements on both revisions.

## Establish the environment

Discover before asking; ask before assuming; never fabricate.

1. **Discover** how the project runs: AGENTS.md / CLAUDE.md first (a previous run may have recorded the answer), then README, docker-compose, .env*, config files, Procfile, package/Rake/Make scripts.
2. **Verify liveness** — probe the actual ports/health endpoints. Configured ≠ running.
3. **Start it** if down and a documented, safe way exists.
4. **Ask for the residue** in ONE consolidated list: endpoints, credentials, representative test data/requests, how to trigger the changed code path. Not piecemeal questions.

**Always ask before generating repeated load against shared infrastructure** (staging databases, triple stores, search indexes used by a team) — even when everything else was discoverable.

## Design the measurement

Two classes of metric; work metrics take priority because they are deterministic:

| Class | Examples | Notes |
|---|---|---|
| Work | # of queries executed, backend round trips, generated query bytes, cache hits | Environment-independent; count exactly via query logs, counters, instrumentation. Often measurable with no live backend at all — a stubbed client or test fixtures can count the queries the code *generates* — so these may be obtainable even when latency measurement is blocked |
| Time | median / p95 / mean latency in ms | Environment-dependent; requires the protocol below |

Latency protocol:

- Identical inputs for both revisions (same requests, same data).
- ≥5 warmup requests per revision before measuring.
- **Alternate measured requests between revisions** (A,B,A,B,…) rather than all-A-then-all-B — alternation cancels environmental drift (cache warming, shared-server load). ≥30 measured requests per revision.
- Report absolute values AND percent delta: `454.1 ms → 236.9 ms (−47.8%)`. Percentages alone are not acceptable.

Correctness guard: capture and diff the actual responses/outputs of both revisions for the measured inputs. A speedup on different answers is a bug, not an improvement.

Keep the measurement runnable: a script, committed to the repo or pasted in the PR, so anyone can reproduce the numbers.

## Report — the PR Performance section

Append to the PR description (or post as a PR comment if the description cannot be edited):

```markdown
## Performance

**Environment:** <what was measured against>
**Compared:** <baseline sha> (merge-base with main) vs <change sha>
**Method:** <N> warmups + <M> alternating measured requests per revision; identical inputs; responses verified identical.

| Metric | Before | After | Δ |
|---|---|---|---|
| Queries per request | 9 | 3 | −67% |
| Median latency | 454.1 ms | 236.9 ms | −47.8% |
| p95 latency | 645.0 ms | 298.7 ms | −53.7% |

<one honest sentence of interpretation>

Reproduce: <script path or command>
```

Report ALL results, including null and negative ones ("generated query size shrank 8% but end-to-end latency was unchanged"). An honest "no measurable impact" is a valid, useful outcome. If only part of the measurement was possible (e.g., work metrics but not latency), label each number with how it was obtained and mark the rest as pending — never blend measured and inferred figures.

## Afterwards

Offer (do not do silently) to record what was learned in the project's AGENTS.md / CLAUDE.md: how to start the environment, endpoints, which infrastructure is benchmark-safe, where the measurement script lives. The next invocation in this repo then runs without questions.

## Red flags — stop if you catch yourself thinking

| Thought | Reality |
|---|---|
| "The improvement is obvious from the code" | Obvious improvements have shipped regressions. Measure. |
| "I'll estimate the query reduction" | An estimate presented in a Performance section is fabrication. Run it, or ask for what you need. |
| "The environment isn't available, so skip the metrics" | Don't skip silently — measure what needs no environment (work metrics), ask about the rest, or state in the PR that measurement is pending and why. |
| "Tests pass, that's evidence enough" | Tests prove correctness, not performance. |
| "I'll benchmark against staging without asking" | Shared infra + repeated load needs explicit permission first. |
