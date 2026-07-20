---
name: solve
description: Use when given an issue or ticket to resolve (a GitHub issue, Jira ticket, or bug report link or number), especially one written by someone else that contains a diagnosis or a proposed fix, before writing any implementation code for it.
---

# Solve

## Overview

Turn a ticket into a validated solution, then into code, in that order. A ticket is testimony, not truth: its premise (the claimed problem) and any proposed fix are hypotheses to verify against the current code, written by someone without full context and possibly before the code changed.

Core rule: **no implementation code until (1) the premise is validated against the current codebase and (2) the user has approved a solution.** Reproduction scripts and failing tests written to verify the premise are allowed and encouraged; the fix itself is not.

The invocation argument is the ticket: a URL, an issue number, or pasted text.

## Phase 1: Understand

- Read the full ticket: description, comments, linked issues and PRs.
- Locate the code it concerns and read it as it exists NOW on the default branch, not as the ticket describes it.

## Phase 2: Validate the premise

- Confirm the claimed problem exists in the current code: reproduce it (failing test, script, observed behavior) or trace the code path and show exactly where the flaw lives.
- Check for staleness: `git log` / `git blame` the relevant files. Has the code changed since the ticket was filed? Was it already fixed, partially fixed, or refactored out of existence?
- Conclude with one verdict: **Confirmed**, **Partially confirmed** (state which part survives), or **Not confirmed** (already fixed, misdiagnosed, or not reproducible).
- If Not confirmed: the deliverable is a report with evidence (commits, code references, reproduction attempts), recommending the ticket be closed or corrected. Do not implement anything. A PR that fixes a nonexistent problem has negative value.

## Phase 3: Evaluate solutions

- Treat the ticket's proposed fix, if present, as candidate #1, not as a directive. It earns implementation by surviving comparison, not by being written down.
- Develop at least one genuine alternative: a different approach a competent reviewer might prefer, not a strawman.
- Compare candidates on: correctness (including edge cases the ticket ignores), blast radius, complexity, performance, and consistency with the codebase's existing conventions.
- Recommend one, with reasoning. Recommending the ticket's own fix is a fine outcome; say why it won.

## Phase 4: Checkpoint (hard stop)

Present to the user, compactly:

1. Premise verdict and the evidence for it.
2. Candidate solutions with tradeoffs, and the recommendation.
3. Implementation sketch: files to change, tests to add or adapt.
4. Open questions, if any.

Then STOP and wait for approval. Do not start implementing while waiting. If the user replies with a change of direction, update the plan and re-confirm.

## Phase 5: Implement (only after approval)

- Implement the approved solution. Where feasible, the Phase 2 reproduction becomes a regression test that fails before the fix and passes after.
- If the fix's central claim is a performance improvement, apply the before-and-after skill so the PR carries measured evidence.
- Open the PR referencing the ticket. The description states: what premise was validated and how, which solution was chosen, and why alternatives were rejected. A reviewer should be able to see the reasoning, not just the diff.

## Red flags: stop if you catch yourself thinking

| Thought | Reality |
|---|---|
| "The author already diagnosed it; re-checking wastes time" | Tickets go stale and diagnoses miss context. Validation costs minutes; a wrong-premise PR wastes a full review cycle. |
| "The proposed fix is obviously right, no need for alternatives" | Evaluate at least one real alternative anyway. Obvious fixes are exactly where better designs hide. |
| "It's a small change, I'll code it and let the diff be the review" | A diff anchors the discussion to what was built. The checkpoint exists to review the solution before the sunk cost of code. |
| "The premise didn't hold, but I'll implement something useful nearby" | Scope discipline: report the finding and stop. New work needs its own ticket and its own premise. |
| "The user is in a hurry, so skip the checkpoint" | Compress the checkpoint, never skip it: a short premise verdict plus recommendation takes one message. |
