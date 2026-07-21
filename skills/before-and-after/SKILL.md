---
name: before-and-after
description: Use when a code change is meant to produce an observable improvement and no captured evidence exists yet: performance work (fewer SPARQL/SQL queries, fewer backend or triple-store round trips, batching, caching, lower latency), visual or UI changes (layout, styling, CSS, UX behavior), or any change whose effect can be demonstrated. Also use when the user asks to instrument before/after evidence (metrics or screenshots) for a fix, branch, or PR, or when about to open a PR whose central claim is an improvement.
---

# Before and After

## Overview

A change whose purpose is an observable improvement is not complete when the code works; it is complete when the improvement is **captured**. This skill produces before/after evidence from both revisions and puts it in the PR.

Core principle: **never fabricate evidence. Every number comes from a measurement that was actually run; every screenshot comes from rendering the actual code at the stated revision.** If capturing evidence is blocked, say so explicitly in the PR instead of silently omitting it.

Invocation arguments are optional hints that pre-answer discovery: an environment description ("API on localhost:9393 against staging"), or a target ("PR #309", a branch name). Anything not supplied is discovered; anything not discoverable is asked.

## Establish what to compare

- **After** = the change: current branch/working tree, or the PR/branch/commit named in the arguments.
- **Before** = the merge-base of the change with the main branch (`git merge-base HEAD origin/main`), NOT main's HEAD, which may contain unrelated commits.
- When invoked after the change is already implemented (the common case), use `git worktree add` or stash/checkout to run identical captures on both revisions.

## Establish the environment

Discover before asking; ask before assuming; never fabricate.

1. **Discover** how the project runs: AGENTS.md / CLAUDE.md first (a previous run may have recorded the answer), then README, docker-compose, .env*, config files, Procfile, package/Rake/Make scripts.
2. **Verify liveness**: probe the actual ports/health endpoints. Configured ≠ running.
3. **Start it** if down and a documented, safe way exists.
4. **Ask for the residue** in ONE consolidated list: endpoints, credentials, representative test data/requests/pages, how to trigger the changed code path. Not piecemeal questions.

**Always ask before generating repeated load against shared infrastructure** (staging databases, triple stores, search indexes used by a team), even when everything else was discoverable.

## Choose the evidence to match the claim

| The change claims | Evidence to capture |
|---|---|
| Less work (fewer queries, fewer round trips, smaller payloads) | Work metrics: exact counts via query logs, counters, instrumentation. Often measurable with no live backend at all (a stubbed client or test fixtures can count what the code *generates*) |
| Faster | Latency (median / p95 / mean in ms) under the performance protocol below |
| Looks or behaves better in the UI | Paired screenshots of both revisions under the visual protocol below, plus a behavior comparison table |
| Other observable effects (memory, bundle size, accessibility audit scores) | Same pattern: one instrument, both revisions, identical conditions |

A change can make more than one claim; capture evidence for each claim the PR makes.

## Performance protocol

- Identical inputs for both revisions (same requests, same data).
- ≥5 warmup requests per revision before measuring.
- **Alternate measured requests between revisions** (A,B,A,B,…) rather than all-A-then-all-B; alternation cancels environmental drift (cache warming, shared-server load). ≥30 measured requests per revision.
- Report absolute values AND percent delta: `454.1 ms → 236.9 ms (−47.8%)`. Percentages alone are not acceptable.
- Correctness guard: capture and diff the actual responses of both revisions for the measured inputs. A speedup on different answers is a bug, not an improvement.
- Keep the measurement runnable: a script, committed to the repo or pasted in the PR.

## Visual protocol

- Both screenshots come from **running code**: Before rendered from the merge-base worktree, After from the change. A design mockup, a Figma export, or a written description is not an After.
- Identical capture conditions: same viewport size, same browser, same page, same navigation state, same data. State them in the PR.
- Capture one labeled Before/After pair per changed aspect (e.g., page top, scrolled state, the specific component), not a single catch-all pair.
- Accompany screenshots with a comparison table: one row per changed aspect, Before behavior vs After behavior in words.
- Correctness guard: the pairs should differ ONLY in the claimed changes; an unexplained difference means investigate before publishing.
- Include manual verification steps a reviewer can follow.
- Capture mechanism: use whatever is available: built-in browser tooling, a headless capture script (Playwright/Puppeteer, or the repo's own system-test harness, e.g. Capybara with headless Chromium). Prefer a script committed to the repo; it doubles as the Reproduce artifact.
- Having no way to capture screenshots is not a dead end and must not block the PR: set up both revisions so capturing is trivial, then hand the user exact capture instructions (URLs for both revisions, viewport size, the states to capture) in the consolidated ask, or open the PR with the pairs marked pending and those instructions included. The inability to screenshot never justifies presenting a words-only description as evidence.

## Report: the PR Before/After section

Append to the PR description (or post as a PR comment if the description cannot be edited). For performance claims:

```markdown
## Performance

**Environment:** <what was measured against>
**Compared:** <baseline sha> (merge-base with main) vs <change sha>
**Method:** <N> warmups + <M> alternating measured requests per revision; identical inputs; responses verified identical.

| Metric | Before | After | Δ |
|---|---|---|---|
| Queries per request | 9 | 3 | −67% |
| Median latency | 454.1 ms | 236.9 ms | −47.8% |

<one honest sentence of interpretation>

Reproduce: <script path or command>
```

For visual claims, title the section `## Before / After`; the Method line states viewport, browser, and page/data/state used for both captures; the table becomes one row per changed aspect (Before behavior vs After behavior); embed the labeled screenshot pairs; `Reproduce:` becomes the manual verification steps.

PR bodies can only reference hosted images: commit the screenshots to the branch (e.g. a `docs/screenshots/` folder, removable before merge) and link them by relative URL, or give the user the labeled image files plus a paste-ready section to drag-and-drop into the PR description.

Report ALL results, including null and negative ones. An honest "no measurable impact" is a valid, useful outcome. If only part of the evidence was capturable, label each item with how it was obtained and mark the rest as pending; never blend captured and inferred evidence.

## Afterwards

Offer (do not do silently) to record what was learned in the project's AGENTS.md / CLAUDE.md: how to start the environment, endpoints, which infrastructure is benchmark-safe, where the capture script lives. The next invocation in this repo then runs without questions.

## Red flags: stop if you catch yourself thinking

| Thought | Reality |
|---|---|
| "The improvement is obvious from the code" | Obvious improvements have shipped regressions. Capture it. |
| "I'll estimate the query reduction" | An estimate presented as evidence is fabrication. Run it, or ask for what you need. |
| "I'll describe the visual change; reviewers can picture it" | A description is a claim. Screenshot pairs from both revisions are evidence. |
| "The design mockup shows the after state" | A mockup is intent, not outcome. The After screenshot comes from the code as it will merge. |
| "The environment isn't available, so skip the evidence" | Don't skip silently: capture what needs no environment (work metrics), ask about the rest, or state in the PR that evidence is pending and why. |
| "Tests pass, that's evidence enough" | Tests prove correctness, not the claimed improvement. |
| "I'll benchmark against staging without asking" | Shared infra + repeated load needs explicit permission first. |
