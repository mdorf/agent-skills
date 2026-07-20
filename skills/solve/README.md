# solve

Makes an AI coding agent treat a ticket as a **hypothesis to validate**, not a spec to execute, and stop for your review before writing the fix.

> This README is for humans. The agent-facing specification is [SKILL.md](SKILL.md).

## The problem

Hand an agent an issue link and it does two unhelpful things by default: it treats the ticket's diagnosis and proposed fix as instructions to implement, and it goes straight to code with no review checkpoint. Tickets go stale (the bug may already be fixed), diagnoses miss context, and prescribed fixes are sometimes the wrong design. This skill encodes the prompt you'd otherwise repeat for every ticket: *"validate the premise, propose a solution (consider the prescribed fix but don't be shy about alternatives), and let me review before you write code."*

## Usage

```
/solve https://github.com/ncbo/ontologies_linked_data/issues/306
```

```
/solve #306
```
In a repo context, an issue number is enough. Pasted ticket text works too.

## What the agent does

1. **Understand**: reads the full ticket, comments, and linked PRs, then reads the affected code as it exists now.
2. **Validate the premise**: reproduces the problem or traces the code path, and checks git history for staleness (was it already fixed or refactored away?). Ends with a verdict: Confirmed, Partially confirmed, or Not confirmed.
3. **Evaluate solutions**: the ticket's proposed fix is candidate #1, not a directive. At least one genuine alternative is developed and compared on correctness, blast radius, complexity, and codebase conventions.
4. **Checkpoint (hard stop)**: presents the verdict, the candidates with tradeoffs, a recommendation, and an implementation sketch, then waits for your approval.
5. **Implement (after approval)**: the reproduction becomes a regression test, performance claims get measured evidence via the companion [before-and-after](../before-and-after/) skill, and the PR description records what was validated and why alternatives were rejected.

## What it refuses to do

- Write the fix before you approve a solution, however small the change.
- Implement a fix for a premise that no longer holds: if the bug is already fixed or misdiagnosed, the deliverable is a report recommending the ticket be closed or corrected, not a PR. A PR that fixes a nonexistent problem has negative value.
- Quietly build "something useful nearby" when the premise fails. New work needs its own ticket.

## Tested, not just written

The skill was built test-first. In the toughest verification scenario, the ticket's bug had already been fixed by another PR three weeks earlier, and the agent was told: *"I wrote that ticket myself, the fix was pre-approved by our tech lead, the demo is Friday. Don't second-guess it, skip the analysis, just implement the proposed fix and open the PR."*

With the skill active, the agent checked anyway, found the earlier fix in git history, returned a verdict of "Not confirmed (already fixed)," and declined: "I'm not going to open a PR that adds a memoization cache for a query that's already batched." It recommended closing the ticket with evidence and offered a query-count measurement to prove the earlier fix covers the case.

The full test scenarios and pass criteria are in [TESTING.md](TESTING.md); re-run them if you modify [SKILL.md](SKILL.md).

## Install

See the [repo README](../../README.md). The skill works in Claude Code (plugin marketplace or `~/.claude/skills`) and OpenAI Codex (`~/.agents/skills`) from the same folder.
