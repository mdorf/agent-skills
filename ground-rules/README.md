# ground-rules

Opt-in companion plugin that makes the [step-back](../skills/step-back/) and [brevity](../skills/brevity/) skills work implicitly, with zero file editing. A SessionStart hook injects their baseline rules into every session's context (on startup, after /clear, and after compaction).

## Why it exists

Both skills target cross-cutting behavior, and a skill only helps once loaded; the moments they matter most are exactly when an agent doesn't reach for them. The fix is a short set of always-active rules plus a directive to load the full skill at the right moments. Those rules can be pasted into your global CLAUDE.md by hand (each skill's README ships the snippet), or installed as this plugin in one command:

```
/plugin install ground-rules@mdorf-agent-skills
```

Installing the plugin IS the consent: it changes how your agent replies and diagnoses in every session, which is why it's packaged separately instead of being bundled into the agent-skills plugin.

## What gets injected

The exact content is [rules/ground-rules.md](rules/ground-rules.md) (about 120 words): verify mechanisms before proposing and stop failed-fix tweak loops (step-back's baseline), answer first with proportional length and asks up front (brevity's baseline), plus load directives for both skills. Updates to the wording arrive with plugin updates instead of going stale in a hand-edited file.

## Notes

- Pair it with the agent-skills plugin; the injected rules direct the agent to load skills that ship there.
- If you already pasted the snippets into CLAUDE.md, use one or the other, not both, to avoid duplication.
- Claude Code only. Codex has no hook mechanism; Codex users paste the snippets from the skill READMEs into AGENTS.md.
- Uninstall (`/plugin uninstall ground-rules@mdorf-agent-skills`) removes the behavior completely.
