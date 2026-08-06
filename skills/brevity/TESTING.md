# Testing brevity

Test-first, per house convention. The primary RED evidence is a real transcript (session "JHU SCOPE document review", 2026-08-05, Opus 5): a narrow one-claim question answered in seven bolded paragraphs, the user's verbatim complaint, and a buried offer that cost a round trip. Scenarios below reconstruct those cases with the real facts. Re-run scenarios 2-4 (skill text included) after any edit to [SKILL.md](SKILL.md).

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

## Results summary (2026-08-06, initial release)

Scenario 1 reproduced the failure shape (milder than the Opus 5 original on the test model; the real transcript remains the primary baseline). Scenarios 2-4 passed on all criteria. No loopholes found; no SKILL.md changes required after testing.
