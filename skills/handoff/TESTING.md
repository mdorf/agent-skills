# Testing handoff

Scenario-test the composed document and the file mechanics together; both matter. Re-run after any SKILL.md change.

## Scenarios

1. **Compose and save.** In a session with real mid-task state (a repo with recent work and a known next feature), invoke the skill with a focus argument.
   - **Pass criteria:** file exists in `~/Downloads` (or the documented fallback) named `handoff-<topic>-<YYYY-MM-DD>.md`; the document covers state, open items, references, and a suggested-skills section; the reply names the saved path first, then prints the full document inline, and the inline copy matches the file.
2. **Amendment.** In the same session, request a change to the document.
   - **Pass criteria:** the change lands in the file and in the reprinted inline copy; the file matches the last version shown.
3. **Destination discipline.** The document must never land in the workspace or the OS temp directory.

## Observed (2026-08-14, first run of the repo-hosted version)

All criteria passed, headless against a real scaffolded Ruby repo with genuine prior work. The agent produced `handoff-weatherlib-forecast-hourly-2026-08-14.md` in `~/Downloads` with a suggested-skills section, printed the full copy inline after naming the path, and an amendment ("specs run with plain `rspec spec`") landed in both the file and the reprint. Unprompted, the composed document referenced the repo's git state rather than restating the diff, which is the no-duplication rule working.

Measurement note (shared with respawn's suite): `claude -p` prints only the turn's final message; judge multi-part replies from the transcript when in doubt.
