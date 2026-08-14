# step-back

Makes an AI coding agent **check the mechanism before voicing a recommendation**, and stop the tweak-upon-tweak loop: ground first, then propose one real solution.

> This README is for humans. The agent-facing specification is [SKILL.md](SKILL.md).

## The problem

Agents propose confidently and retract a turn later once they actually look ("suggest-and-backtrack"). Each retraction burns your time, erodes trust in every other claim (you can no longer tell which assertions were checked), and for config changes risks degrading a live, working system. The failure compounds under momentum: tweak, fail, tweak again, each fix stacked on the last unverified one.

This skill distills a set of real, documented retractions by a production agent into standing discipline: verify the mechanism first, treat negative search results as unproven, establish scope before remedy, and after two failed fixes stop tweaking entirely.

## Usage

Two modes:

**Automatic:** the skill's trigger conditions cover diagnosis, debugging, config changes, and incidents, so a well-behaved agent loads it when entering that territory.

**Rescue command (the killer use case):** the moment you see the agent thrashing, guessing, or proposing its third tweak, invoke it directly:

```
/step-back
```

The agent stops, states what is known and what the failed attempts rule out, runs the cheapest diagnostic that measures the actual behavior, and comes back with one grounded proposal.

**Required companion setup for implicit use:** this skill is meant to run implicitly, and a skill only influences behavior once it loads. The impulsive moment it targets is exactly when an agent won't reach for it, so relying on the trigger description alone leaves it unloaded when it matters most. Paste the following into your always-loaded instructions file (global `~/.claude/CLAUDE.md`, or `AGENTS.md` for Codex); it enforces the core rules in every session and directs the agent to load the full skill in the situations that need it:

```markdown
# Working discipline

- Verify the mechanism before proposing: read where the value or code path is
  actually consumed, or run the cheap probe, BEFORE voicing a recommendation.
  Label unverified ideas as unverified; never present them as recommendations.
- If two consecutive fixes have failed, stop tweaking: state what is known and
  ruled out, run the cheapest diagnostic that measures the actual behavior,
  establish scope ("where does this NOT happen?"), then propose one grounded
  solution. Load the step-back skill whenever diagnosing, debugging, or
  proposing config changes.
```

Without these lines, treat the skill as manual-only: invoke `/step-back` yourself when you see thrashing.

## What it encodes

- **The core rule:** an unverified idea labelled as unverified is fine; an unverified idea presented as a recommendation is not.
- **Six traps** that each produced a real retraction: coupled/derived config values, restart-vs-hot-reload semantics, "one-line fix" claims, identity inferred from filenames instead of the authoritative source, stale file:line citations, and speculative optimization (prefer adding a monitor over changing behavior on a wide-error-bar projection).
- **Negative results need a positive control:** "I searched and found nothing" proves nothing until a query that must return something has returned it, and a second place or phrasing has been checked.
- **Scope before remedy:** ask "where does this NOT happen?"; the contrast is usually the diagnosis, and the cheapest diagnostic that measures the actual thing goes first.
- **The tweak-loop stop:** a failed fix falsifies the model that produced the next one. After two consecutive failures, stopping is mandatory: known/assumed/ruled-out, cheapest diagnostic, scope, then ONE verified proposal. And no fixes mid-incident: gather while it unfolds, propose once, after.
- **The pre-send sanity check:** what would have to be true for this to be wrong, have I actually looked, and would a single cheap query settle it?

## Tested, not just written

In the pressure scenario, an agent mid-incident (two failed remediations already, user demanding a third: "bump the timeout to 120 real quick") refused the tweak, and pointed out that the failed 30s-to-60s raise had *already falsified* the new proposal: if requests were slow-but-finishing, some would have succeeded in the widened window; none did, so they hang, and 120s just makes users wait longer for the same error. A 30-second log grep then scoped the problem to two ontologies on one endpoint, correlated with an index rebuild, and produced a single verified proposal.

An honest note on baselines: unlike this repo's other skills, the no-skill control runs (on a frontier reasoning model) largely did the right thing already, so this skill's measured effect is sharpening (mandatory stops, falsification reuse, mechanism checks before proposing) rather than reversal. The documented baseline failures that motivated it come from real production sessions, where long-momentum thrash is common and not reproducible in one-shot tests. Details in [TESTING.md](TESTING.md).

## Install

See the [repo README](../../README.md). The skill works in Claude Code (plugin marketplace or `~/.claude/skills`) and OpenAI Codex (`~/.agents/skills`) from the same folder.
