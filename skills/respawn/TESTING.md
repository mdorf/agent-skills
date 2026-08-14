# Testing respawn

Unlike this repo's other skills, respawn's critical path is mechanical (stash file, hook, injection), so it is tested live rather than by scenario simulation. Re-run the end-to-end test after any change to SKILL.md or hooks/respawn-inject.sh.

## Unit: hook script

Pipe-test `hooks/respawn-inject.sh` directly (it ignores stdin):

- Fresh stash present: emits `hookSpecificOutput.additionalContext` JSON containing the stash content; moves the stash to `~/.claude/respawn-last.md`; exit 0.
- No stash: silent, exit 0.
- Stash older than 60 minutes: archived without injecting, exit 0 (set the file's mtime back with `touch -t` to test).

**Observed (2026-08-14):** first two branches verified by pipe-test; the stale branch verified by code review only.

## End to end

1. Clean state: no `respawn-pending.md` / `respawn-last.md` in `~/.claude/`.
2. Session A (headless): given a described mid-task state (a Ruby gem with 3/5 tests passing, a named bug, an approved next feature), invoke the respawn skill.
   - **Pass criteria:** stash written with the resume preamble above the handoff body; handoff contains task/state/open-items/next-step/references/suggested-skills; full handoff printed inline; reply ends with the "Stash armed. Run /clear now" line.
3. Session B (headless, fresh, prompt is just "continue"):
   - **Pass criteria:** first words are "Resumed from respawn."; one or two short paragraphs summarizing done and open items; the agent proceeds from the handoff's next step; stash consumed; `respawn-last.md` present.

**Observed (2026-08-14):** all criteria passed. Session A produced a structured handoff including prioritized open items and suggested skills (it recommended `solve` for the bug, unprompted). Session B opened with the required acknowledgment and summary, then went beyond the criteria: it checked the handoff against the actual repository, found the fictional test payload contradicted reality (no such gem exists in the cwd), refused to fabricate work on nonexistent files, and asked for direction. That behavior comes from the user's step-back discipline (always loaded via CLAUDE.md), not from this skill, but it demonstrates the intended composition: a respawned agent grounds the handoff instead of blindly executing it.

## Known limitations (by design, documented in README)

- `/clear` cannot be automated; the flow is two keystrokes.
- The stash is consumed by the next session started on the machine within 60 minutes, whichever window it is. Run `/clear` promptly.
- No hook support in Codex; the skill falls back to telling the user to point the fresh session at the stash file.
