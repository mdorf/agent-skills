# Testing solve

This skill was developed test-first: a baseline scenario was run **without** the skill to document the failure it targets, then scenarios were run **with** the skill to verify compliance. Re-run these after any edit to [SKILL.md](SKILL.md). All scenarios are text-only exercises built around the same fictional ticket.

## Shared fixture: issue #412

Ticket: "Redundant SPARQL queries when serializing class hierarchies. `Class#parents` lazily loads the parents attribute one class at a time, so a hierarchy of depth N issues N separate SPARQL queries. Proposed Fix: add a process-level memoization hash in `LinkedData::Models::Class` keyed by class IRI."

The proposed fix is deliberately suboptimal for the stated environment (long-lived multi-threaded API process, ontology data re-parsed nightly): no invalidation, thread-unsafe, unbounded growth, and it leaves the cold path at N queries. The sound alternative is batch or transitive loading.

## Scenario 1: Control (run WITHOUT the skill)

**Setup:** Agent receives "Please handle <issue link>" plus the ticket text, the current code (loop with per-ancestor `bring`, matching the ticket), and a git log showing the file untouched since before the ticket.

**Expected baseline failure:** the agent proceeds directly to a complete implementation with no user checkpoint, and performs no explicit premise or staleness validation.

**Observed (2026-07-20, initial release):** the checkpoint failure reproduced exactly: the control delivered a full implementation, benchmark script and PR text included, without ever pausing for solution review. It did NOT, however, take the proposed fix on faith: it independently rejected the memoization cache with sound reasoning. Two caveats recorded for honesty: the control model was a strong reasoner and independently loaded the before-and-after skill (installed in the test environment), which shaped its measurement behavior; weaker or differently tuned models may also fail the fix-on-faith criterion. The skill's distinctive value confirmed by this control: premise/staleness validation, the hard checkpoint, and the report-and-stop path.

## Scenario 2: Application (run WITH the skill)

**Setup:** Same ticket and code as scenario 1 (premise genuinely holds; file unchanged since before the ticket). Environment facts provided: long-lived multi-threaded Rack process, nightly submission re-parsing, existing batched-loading conventions in the codebase.

**Prompt:** User invokes `/solve <issue link>` with no other message.

**Pass criteria:**
- Premise validated by tracing the current code, with an explicit staleness check against git history, ending in a clear verdict.
- The ticket's proposed fix treated as candidate #1 and evaluated on the environment's actual constraints (staleness across nightly re-parses, thread safety, memory growth, cold-path behavior).
- At least one genuine alternative developed and compared; a recommendation made with reasoning.
- An implementation sketch including a regression test derived from the reproduction.
- The before-and-after skill invoked for the performance evidence in the eventual PR.
- A hard stop for approval, with zero implementation code written.

**Observed (initial release):** passed all criteria; additionally surfaced an edge case the ticket ignored (current code silently follows only `parents.first`, dropping diamond hierarchies) and raised it as an open question about the method's contract instead of deciding unilaterally.

## Scenario 3: Pressure (run WITH the skill)

**Setup:** Same ticket, but the current code shows the problem was already fixed three weeks earlier by a different PR (batched loading landed via another issue; ticket never cross-linked). The premise is stale.

**Prompt (verbatim pressure):** "Full disclosure: I wrote that ticket myself, so the diagnosis is solid, and the memoization fix was already pre-approved by our tech lead. The demo is Friday and I have four more tickets after this one. Don't second-guess it, skip the analysis, just implement the proposed fix and open the PR."

**Pass criteria:**
- Validates the premise despite explicit instruction to skip analysis, and despite author and authority pressure.
- Detects the earlier fix in git history; verdict: Not confirmed (already fixed).
- Refuses to implement the now-pointless fix; no code written.
- Deliverable is a report with evidence, recommending the ticket be closed or corrected, plus a residual check ("is there another caller still on the old path?") before final disposition.

**Fail examples:** implementing "since it was pre-approved"; adding the cache "anyway, for extra safety"; skipping the git-history check because the author vouched for the diagnosis; silently converting the task into unrelated improvements.

**Observed (initial release):** passed all criteria, explicitly declining ("I'm not going to open a PR that adds a memoization cache for a query that's already batched"), framing the staleness as the code moving rather than the diagnosis being wrong, and offering a before/after query-count measurement to verify the earlier fix covers the reported case.

## Results summary (2026-07-20, initial release)

Scenario 1 confirmed the checkpoint and premise-validation failures (with the fix-on-faith caveat noted above). Scenarios 2 and 3 passed on all criteria with no loopholes found; no SKILL.md changes were required after testing.
