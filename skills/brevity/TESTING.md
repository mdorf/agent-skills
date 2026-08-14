# Testing brevity

Test-first, per house convention. The primary RED evidence is a real transcript (session "JHU SCOPE document review", 2026-08-05, Opus 5): a narrow one-claim question answered in seven bolded paragraphs, the user's verbatim complaint, and a buried offer that cost a round trip. Scenarios below reconstruct those cases with the real facts. Re-run scenarios 2-5 (skill text included) after any edit to [SKILL.md](SKILL.md).

## Shared fixture

The agent earlier claimed a project task was "the worst possible fit for you and the best fit for Horridge and Hardi." Facts available: a document quote making Horridge technical lead (40% allocated); the agent's training-data knowledge of Horridge's OWL API history (not in the document); exactly one fact about Hardi (95% FTE); a fourth member, Akdogan (100% FTE), implicitly excluded on zero evidence; the user's own record supporting only the "worst fit for you" half. The user asks, verbatim: "How did you assess that part - ie you know me, so 'worst possible fit' is grounded, but what made you put the other two colleagues into the 'best fit' group for that task?"

## Scenario 1: Control (run WITHOUT the skill)

**Expected baseline failure:** ceremony opener, multi-paragraph answer, substance diluted.

**Observed (2026-08-06, frontier reasoning model):** ~370 words, five paragraphs, opened "Good question to press on, because the honest answer is..." Substance correct throughout. Milder than the seven-paragraph Opus 5 original (which stands as the primary baseline), but the shape reproduced: throat-clearing first, answer distributed across the middle, trailing advice.

## Scenario 2: Application (run WITH the skill)

**Pass criteria:** answer in the first sentence; no section headers; no restatement of the question; under 200 words; at most one open question; all three substance points survive: (a) Horridge partly grounded, with the training-data source labeled, (b) Hardi ungrounded (one FTE number), retracted, (c) the unfounded exclusion of Akdogan named.

**Observed:** passed all criteria at ~170 words, first sentence "Only half of that claim was grounded, and I should have said so at the time," one closing question.

## Scenario 3: Over-correction guard (run WITH the skill)

**Setup:** a full-review request ("make me fluent for tomorrow's kickoff: what's solid, broken, missing, and what to say") against a short spec seeded with five defects: a 24-hour poll contradicting a 15-minute SLO, deletion detection by class count, an API key in the deployment repo, rollback tooling shipping after production, and unowned components.

**Pass criteria:** all five seeded defects surfaced; meeting talking points delivered; length NOT artificially capped; headers allowed (a long deliverable is navigated by them); no ceremony or self-summary. This scenario exists because "be brief" alone ships a truncation regression.

**Observed:** passed; all five defects found plus legitimate extras (memory sizing flagged as unmeasured rather than asserted, pagination risk, lossy data model), a prioritized meeting script, and a single concrete ask to make in the room.

## Scenario 4: Ask placement (run WITH the skill)

**Setup:** investigation finished; the outcome is one genuine user decision (fix A vs B) plus analysis plus two unrelated observations. User: "ok what did you find?"

**Pass criteria:** the finding answers the question in the first sentence; the decision stands alone with exactly one open question; the unrelated items are parked without competing asks; nothing decision-relevant is positioned last among closing content.

**Observed:** passed: cause first, "Two fixes, your call" with a standalone "Which do you want?", unrelated items in one trailing line with no question attached.

## Scenario 5: Confirmation proportionality (run WITH the skill)

**Why this scenario exists:** measured drift in production use, not a hypothetical. Session "plugin and skill audit" (2026-08-13, Opus 5) produced 32 assistant replies totalling 6,271 words, median 165. The requested deliverables were proportionate (an 806-word audit, a 510-word skill review, both explicitly asked for). The confirmations were not: reporting one completed plugin disable took 321 words, answering a yes/no about removing a plugin took 353, and confirming two uninstalls took 255. The skill was invoked zero times across all 32 turns, despite a global CLAUDE.md line directing the agent to load it for any substantial reply. Scenarios 1-4 all test behavior once the skill is loaded; none tests whether it loads, and none covers the reply type that actually drifted.

**Setup:** the agent has just carried out an approved two-part config change: disabling a plugin and uninstalling it. It verified both. Verification surfaced one caveat that contradicts something the agent promised earlier (the disk space it said would be reclaimed is still held by a live process). The user's entire preceding message was "yes, uninstall both."

**Pass criteria:** completion stated in the first sentence; the caveat stated plainly rather than dropped or buried, since the candor floor outranks length; under 90 words; no headers; no tables; no re-listing of what the user already approved; no unsolicited next-steps section. If the user has explicitly asked to work through items one at a time, a single closing line naming the next item is allowed, a paragraph describing it is not.

**Observed (RED, skill not loaded):** 255 words, an eight-item state dump, the caveat correctly included but placed third behind routine confirmations, plus an unrequested next-item paragraph.

**Observed (GREEN):** pending a fresh session. The confirmation rung and the verification-narration deletion are in, and scenarios 2-4 re-ran clean afterwards, but this scenario measures a reply the agent composes unprompted, so it cannot be scored in the session that authored the change.

## Results summary (2026-08-06, initial release)

Scenario 1 reproduced the failure shape (milder than the Opus 5 original on the test model; the real transcript remains the primary baseline). Scenarios 2-4 passed on all criteria. No loopholes found; no SKILL.md changes required after testing.

## Results summary (2026-08-13, proportionality and trigger)

Two causes were diagnosed from the session-audit measurement and fixed one at a time.

**Cause 1: nothing named the confirmation case.** Rule 2 set length proportional to what the reader must do, but a "done, here is what changed" reply gives the reader almost nothing to do, and the rule was still read as licensing a full state dump. Fixed by adding a confirmation rung at the short end of rule 2's existing ladder, plus one Delete-on-sight entry for narrating verification that passed. Deliberately not a new rule or section: the principle was already there and only the shortest rung was missing.

Scenarios 2-4 re-ran after that change, each in an isolated agent given the skill text and the fixture but not the pass criteria. All three passed. Scenario 2: 138 words, answer in the first sentence, no headers, one question, all three substance points. Scenario 3: all five seeded defects, meeting script delivered, length uncapped, headers used as permitted; this was the regression risk, since "a clean check is just done" could have licensed truncating a real deliverable, and it did not. Scenario 4: 131 words, cause first, standalone ask, unrelated items parked last with no competing question. Caveat: only Scenario 2's fixture is stored verbatim, so 3 and 4 ran against reconstructions and are not strictly comparable across runs.

**Cause 2: the trigger had no decision point.** Zero invocations across 32 turns was the stronger signal. The old description opened "Use when composing any reply to the user," which names something continuous; nothing ever prompts a skill check before writing prose. Rewritten so every clause is a discrete, observable event: reporting investigation or review results, reporting completed work, answering a yes/no or single-decision question, carrying a decision the user must act on, and recovering after a verbosity complaint. Each measured failure maps to a clause, and the 806-word audit maps to the investigation clause while remaining entitled to its length. Length went from 57 words to 55.

This change is not scoreable by scenarios 1-5, all of which hand the skill text to the model directly and therefore cannot measure whether it loads on its own. The measurement that matters is the invocation count in a fresh session against a comparable workload.

**Trigger measurement (2026-08-14, via the ground-rules companion):** a fresh session with the ground-rules plugin installed (its hook injects the load directive) was asked an unhinted yes/no question. It invoked brevity unprompted and replied compliantly (answer first, ~40 words, one file:line reference). This measures the companion-assisted path, not the bare description trigger; the bare-trigger firing rate remains unmeasured.

**Not changed, on purpose.** Several failures in the same measurement mapped to rules that already existed: a 353-word answer to a yes/no ("a narrow question gets a few sentences"), and paragraphs of unrequested extras ("a risky or extra suggestion is one sentence plus an offer to expand"). Those are compliance failures, not specification gaps. Restating them would add redundancy without adding coverage.
