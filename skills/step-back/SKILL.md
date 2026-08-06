---
name: step-back
description: Use before voicing any recommendation, fix, or config change whose mechanism has not been checked; when debugging or diagnosing, especially during a live incident; when a previous suggestion had to be retracted; when consecutive small fixes have failed; or when the user says the agent is thrashing, guessing, flailing, or asks it to slow down and ground itself.
---

# Step Back

## Overview

Do not float a recommendation until the mechanism it depends on has been checked. Take the extra minute: read the code path, find where the value is actually consumed, run the probe, and *then* speak. This applies to plain advice, and especially to code and configuration changes.

An unverified idea labelled as unverified is fine ("worth checking, I haven't confirmed X"). An unverified idea presented as a recommendation is not. Every retraction burns the user's time, erodes trust in every *other* claim made, and for config changes risks degrading a live, working system.

Sanity check before sending any suggestion: **what would have to be true for this to be wrong, have I actually looked, and would a single cheap query settle it?**

## The traps

Each of these produced a real, confident proposal that had to be retracted a turn later.

| Trap | Discipline |
|---|---|
| **Coupled or derived values.** A "safe" threshold increase fed a second setting derived from it (budget = threshold × ratio); the change would have cut retained data 4x and fought an adjustment made an hour earlier. | Before recommending a setting, check what else consumes or derives from it. |
| **Restart/reload semantics.** A config section was claimed to hot-reload; the values are read once at process init, so running instances silently keep old values. | Never state that a change takes effect without finding where the value is read. |
| **"One-line fix" claims.** A bug called a one-line diff had 13 call sites feeding keys and allowlists; the safe fix was a different, narrower change. | Count the call sites before sizing the fix. |
| **Inferring identity or membership from names/counts.** A group's membership was inferred from four cache filenames; one belonged to the service's own account, so a real member stayed blocked. One API call to the authoritative source settled it. | Query the authoritative source; filenames and counts are not it. |
| **Stale file:line citations.** Line numbers drift silently across dependency updates. | Re-verify citations after any update. |
| **Speculative optimization.** A projection with wide error bars is the weakest basis for degrading something that works. | Prefer adding early warning (a monitor, a threshold alert) over changing behavior now. |

## Negative results need a positive control

"I searched and found nothing" is the weakest possible basis for "it doesn't exist", and it fails in two ways: the search itself can be broken (an invalid CLI flag made every query error while the wrapper printed "no matches", nearly turning three already-filed issues into "unfiled"), and the search can be aimed at the wrong place (a grep of one file "proved" a code path didn't exist; it was documented in an adapter and worked by an indirect route).

Before asserting absence: run a query that MUST return something, and look in at least one other place or phrasing.

## Establish scope before proposing a remedy

One observation is not a general failure. Ask "where does this NOT happen?"; the contrast is usually the diagnosis. A single timeout in one context led to a proposal to disable the whole feature; a one-line grep of the same log showed 11-18s completions in one-on-one use vs 600s only in the group context. The feature was fine; one context failed. That grep directly measured the behavior under discussion, was available from the first minute, and was run third.

**The cheapest diagnostic that measures the actual thing goes FIRST.**

## Stop the tweak loop

The failure compounds when fixes stack: tweak, fail, tweak again, each proposal made on top of the last unverified one.

- If the previous fix did not work, the next action is NOT another fix. Something in the mental model is wrong, and another tweak samples the same broken model.
- After two consecutive failed fixes, stop is mandatory: state plainly what is known, what is assumed, and what the failed attempts rule out; run the cheapest diagnostic that measures the actual behavior; establish scope; then present ONE grounded proposal with its mechanism verified.
- Do not propose a fix mid-incident. While something is still unfolding, gather; propose once, after. Interleaving half-diagnoses with remediation advice produces exactly the suggest-and-backtrack pattern, and each revision costs more credibility than the fix was worth.

## Red flags: stop if you catch yourself thinking

| Thought | Reality |
|---|---|
| "I'm pretty sure that's how it works" | Pretty sure is the tell. Read the consumer, or label the idea unverified. |
| "This is obviously a one-line fix" | Count the call sites first. |
| "The search returned nothing, so it doesn't exist" | Broken or misaimed searches also return nothing. Positive control first. |
| "Just one more tweak, this one will do it" | A failed fix falsifies the model that produced the next one. Stop and ground. |
| "The incident is live, they need suggestions NOW" | Mid-incident they need facts and scope. The proposal comes once, after. |
| "I'll propose it now and verify if they push back" | The user cannot tell checked claims from unchecked ones. That asymmetry is the whole problem. |
