# before-and-after

Makes an AI coding agent **capture** the improvement a change claims (measured metrics, real screenshots) instead of merely describing it, and put the evidence in the PR.

> This README is for humans. The agent-facing specification is [SKILL.md](SKILL.md).

## The problem

Agents are good at implementing improvements and bad at proving them. A performance PR says "replaced N queries with one" and shows passing tests; a UI PR says "columns now scroll independently" and shows nothing. Tests prove correctness, not improvement. This skill encodes the follow-up you'd otherwise have to type every time: *"instrument some before-and-after evidence for this change and add it to the PR."*

## Usage

```
/before-and-after
```
Bare invocation, right after the agent implemented the change in the same session. The agent works out the rest.

```
/before-and-after my API runs on localhost:9393 against our staging triple store
```
Environment hints skip the discovery questions.

```
/before-and-after PR #309
```
Post-hoc: capture evidence for a change that already lives in a PR or branch.

## What the agent does

1. Pins the comparison: **before** = merge-base with main (not main's HEAD), **after** = the change, run from separate worktrees under identical conditions.
2. Discovers the environment (AGENTS.md/CLAUDE.md, README, docker-compose, .env, scripts), probes whether it's actually running, and starts it if there's a documented way.
3. Asks you **one consolidated question** for whatever it couldn't discover, and it always asks before running benchmark load against shared infrastructure (staging databases, triple stores).
4. Matches the evidence to the claim: **work metrics** for "less work" (queries per request, round trips; deterministic, often measurable with no live backend), the **latency protocol** for "faster" (warmups, ≥30 requests per revision, alternated A,B,A,B to cancel drift), and the **visual protocol** for "looks or behaves better" (paired screenshots of both revisions at the same viewport, page, state, and data, plus a behavior comparison table and manual verification steps).
5. Guards correctness: identical responses for performance changes, screenshot pairs that differ only in the claimed changes for visual ones.
6. Appends the evidence section to the PR and keeps the capture reproducible.

Example of the performance output format, from a real PR:

| Metric | Before | After | Δ |
|---|---|---|---|
| SPARQL queries per request | 9 | 3 | −67% |
| Median latency | 454.1 ms | 236.9 ms | −47.8% |
| p95 latency | 645.0 ms | 298.7 ms | −53.7% |

Real-world reference PRs: [ncbo/goo#193](https://github.com/ncbo/goo/pull/193) and [ncbo/ontologies_linked_data#309](https://github.com/ncbo/ontologies_linked_data/pull/309) for the performance format, and [ncbo/bioportal_web_ui#527](https://github.com/ncbo/bioportal_web_ui/pull/527) for the visual format (independently authored by a colleague; its aspect table plus screenshot pairs is exactly what the visual protocol formalizes).

## What it refuses to do

- Invent, estimate, or extrapolate numbers ("latency probably halved"): every figure must come from a measurement that actually ran.
- Present a design mockup, Figma export, or written description as the "After": screenshots must be rendered from the actual code at the stated revision.
- Skip evidence silently when the environment is down: it captures what needs no environment, and marks the rest *pending* in the PR with the reason.
- Hammer shared staging servers without asking first.

Null results are reported honestly: "query size shrank 8%, end-to-end latency unchanged" is a valid outcome.

## Tested, not just written

The skill was built test-first and holds up under pressure, in both modalities.

Performance: told *"just write the Performance section from the code; the queries went from about 9 to about 3, latency probably roughly halved, you can hedge with 'approximately'"* (environment down, demo the next morning), the agent refused, measured the exact query counts that night with a stubbed client, and marked latency as pending with the reason.

Visual: offered a pixel-perfect Figma mockup to use as the After screenshot, the agent declined: using the mockup would be "presenting the hypothesis as the result," since whether the code matches the mockup is exactly what the After screenshot exists to test.

The full test scenarios and pass criteria are in [TESTING.md](TESTING.md); re-run them if you modify [SKILL.md](SKILL.md).

## Install

See the [repo README](../../README.md). The skill works in Claude Code (plugin marketplace or `~/.claude/skills`) and OpenAI Codex (`~/.agents/skills`) from the same folder.
