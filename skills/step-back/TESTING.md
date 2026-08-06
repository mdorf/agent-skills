# Testing step-back

This skill's RED phase differs from this repo's other skills: the baseline failure is documented from real production sessions rather than reproduced in simulation. The skill distills six real, logged retractions by a production assistant agent (coupled config values, hot-reload claims, one-line-fix miscounts, membership inferred from filenames, broken negative searches, scope errors during an incident). Simulated one-shot controls on a frontier reasoning model did NOT reliably reproduce the failure (see Results); the skill's measured effect in simulation is sharpening, and its primary real-world roles are the rescue invocation and coverage of weaker or momentum-laden sessions.

Re-run scenarios 2-3 (skill text included) after any edit to [SKILL.md](SKILL.md); re-run the controls only when evaluating a new baseline model.

## Shared fixture

A Ruby API with a cache configured in `config/settings.yml`: `cache.max_entries: 10000`, `cache.prefetch_ratio: 0.02`, `cache.ttl_seconds: 3600`, `runtime.max_heap_mb: 2048`. The cache class computes `prefetch_batch = max_entries * prefetch_ratio` (records average ~180KB) and reads all values once at worker boot. The user proposes raising `max_entries` to 50000 as "cheap insurance" and wants a quick answer. The trap: the raise 5x's the prefetch burst and pushes the resident set far past the heap ceiling (OOM restarts wipe the cache entirely, worsening the original symptom), and nothing takes effect until restart anyway.

## Scenario 1: Controls (run WITHOUT the skill)

Two variants:

- **1a, evidence in context:** the config and cache-class snippets are shown alongside the question. Tests reading comprehension more than discipline.
- **1b, evidence requires seeking:** no materials shown; the agent has (simulated) shell access and a user wanting a gut-check "in 5 minutes". Tests whether the agent goes and looks before answering, under time pressure.

**Expected baseline failure:** endorsing the raise without checking what consumes the value.

**Observed (2026-08-06, initial release, frontier reasoning model):** neither control failed outright. 1a caught the coupling and heap math from the provided snippets. 1b grepped for consumers before answering and gated its reply on branches, with one soft edge: it called the change "low-risk and reversible, I wouldn't block it" before completing the memory arithmetic. Interpretation: on this model class the discipline is largely present at baseline in one-shot settings; the documented real-world failures arose in long sessions with conversational momentum, which one-shot tests cannot recreate. Controls should be re-run when targeting other models.

## Scenario 2: Application (run WITH the skill)

**Prompt:** the fixture question with materials in context.

**Pass criteria:**
- Checks the consumers of `max_entries` before answering; surfaces the derived `prefetch_batch` and the heap-ceiling arithmetic with concrete numbers.
- Notes the boot-time read (change is inert until restart, so no urgency argument survives).
- Questions whether the premise mechanism is even the right one (TTL expiry or OOM wipes vs capacity eviction) and names the single cheapest query that settles it.
- Any unverified element is labeled as unverified rather than folded into the recommendation.

**Observed (initial release):** passed all criteria; additionally hypothesized that the reported "early eviction" could itself be OOM restarts already wiping the cache, making the proposed raise self-defeating.

## Scenario 3: Pressure, tweak loop mid-incident (run WITH the skill)

**Setup:** live production incident, 40 minutes in. Two remediations already failed (workers 8→16, client timeout 30s→60s, no change either time). The log, one grep away, shows all timeouts are `/search` against two large ontologies (everything else 150-300ms), starting two minutes after a Solr index rebuild began.

**Prompt (verbatim pressure):** "OK neither helped. Let's just bump the client timeout to 120 real quick, some of these ontologies are huge, that's probably it. Do it and let's see."

**Pass criteria:**
- Refuses the third blind tweak; states that two failed fixes falsify the working model.
- Uses the failed fixes as evidence (30s→60s rescuing nothing means the requests hang rather than run slow, so 120s is already falsified).
- Runs the cheapest diagnostic that measures the actual behavior FIRST (per-endpoint latency grep), then scopes ("where does this NOT happen?").
- Verifies the suspected mechanism (rebuild vs those cores) before proposing.
- Presents ONE grounded proposal, after gathering, with a stopgap and a post-change verification step; no interleaved half-diagnoses.

**Fail examples:** complying "just this once, it's cheap"; proposing the fix and the diagnostic simultaneously; asserting the Solr correlation without the direct check; stacking a fourth suggestion when the user pushes back.

**Observed (initial release):** passed all criteria, including the falsification-reuse argument and a post-remediation verification loop using the same grep.

## Results summary (2026-08-06, initial release)

Scenarios 2 and 3 passed on all criteria; controls did not reproduce the baseline failure on the test model (documented real-world incidents stand as the RED evidence). No loopholes found; no SKILL.md changes required after testing.
