# Testing respawn

Unlike this repo's other skills, respawn's critical path is mechanical (stash file, hook, injection), so it is tested live rather than by scenario simulation. Re-run the end-to-end test after any change to SKILL.md or hooks/respawn-inject.sh.

## Unit: hook script

Pipe-test `hooks/respawn-inject.sh` with a scratch `$HOME` (the script reads hook-input JSON from stdin; fabricate transcripts as JSONL files):

- No stash: silent, exit 0 (the every-prompt fast path).
- Fresh stash, fresh transcript (no `"type":"assistant"` lines): emits `hookSpecificOutput.additionalContext` JSON containing the stash content; moves the stash to `~/.claude/respawn-last.md`; exit 0.
- Fresh stash, ongoing transcript (has an assistant line): silent, **stash left in place**.
- Fresh stash, no `transcript_path` in input (brand-new session, no transcript file yet): injects and consumes.
- Stash older than 60 minutes: archived without injecting, from any session (set the mtime back with `touch -t`).
- Malformed stdin: silent, stash preserved.
- SessionStart event, fresh stash: emits `systemMessage` notice only (no `hookSpecificOutput`), **stash untouched**.
- SessionStart event, stale stash: silent, stash untouched (cleanup belongs to the prompt path).

**Observed (2026-08-14, after the UserPromptSubmit redesign):** all six consumption branches verified by pipe-test. One harness gotcha: validate the emitted JSON with `printf '%s'`, not zsh's `echo`, which expands the `\n` escapes inside the JSON string and makes valid output look broken.

## Amendment loop

After the handoff is shown, a user may request changes ("expand item 2 to include Rachel's comments") before clearing. Pass criteria: the agent applies the change, rewrites the stash file (not just the reply), reprints the amended handoff, and re-ends with the bolded closing instruction.

**Observed (2026-08-14):** verified live against the real harness. A headless session composed a handoff from a described mid-task state, then a resumed second turn asked to fold in two reviewer requirements; the on-disk stash was rewritten containing both, the preamble stayed intact above the body, and the reply re-armed with the closing paragraph.

**Observed (2026-08-14, after adding the display-only SessionStart branch):** all branches re-verified by pipe-test, including both SessionStart cases; the live fresh-headless injection test was re-run and passed (marker echoed, stash consumed, visible confirmation emitted alongside the context). The systemMessage rendering itself is standard harness behavior and was not separately verified in a live window.

**Observed (2026-08-14, first interactive desktop run):** full pass on the flow itself, including an unprompted live exercise of the amendment loop and the "Resumed from respawn." resume. One expectation corrected: the desktop app creates the post-clear session lazily, at the first submitted message, so the SessionStart "pending" notice fired simultaneously with the prompt and the injection (all three share one transcript timestamp) and was not rendered by the UI. A pending notice at `/clear` time is unachievable in the desktop app; the screen staying blank until the first message is normal there. The branch is kept for eager-session harnesses and documented as such in the README.

## End to end

1. Clean state: no `respawn-pending.md` / `respawn-last.md` in `~/.claude/`.
2. Session A (headless): given a described mid-task state (a Ruby gem with 3/5 tests passing, a named bug, an approved next feature), invoke the respawn skill.
   - **Pass criteria:** stash written with the resume preamble above the handoff body; handoff contains task/state/open-items/next-step/references/suggested-skills; full handoff printed inline; reply ends with the bolded "**Stash armed → run `/clear` now.**" paragraph.
3. Session B (headless, fresh, prompt is just "continue"):
   - **Pass criteria:** first words are "Resumed from respawn."; one or two short paragraphs summarizing done and open items; the agent proceeds from the handoff's next step; stash consumed; `respawn-last.md` present.
4. Session C (resume session B with a second prompt while a fresh stash is planted):
   - **Pass criteria:** the ongoing session does not consume the stash; `respawn-pending.md` still present afterward.

**Observed (2026-08-14, original SessionStart design):** session A and B criteria all passed. Session A produced a structured handoff including prioritized open items and suggested skills (it recommended `solve` for the bug, unprompted). Session B opened with the required acknowledgment, checked the handoff against the actual repository, found the fictional test payload contradicted reality, and refused to fabricate work on nonexistent files. That grounding comes from the user's step-back discipline, not this skill, but it demonstrates the intended composition.

## Field failure and redesign (2026-08-14)

The first real (non-test) use of the flow failed. The previous session wrote the stash at 16:59:07 and the user restarted the desktop app (a pending plugin update needed it). The app relaunch fired a SessionStart nobody was looking at, and the hook, then wired to `SessionStart` with matcher `clear|startup`, consumed the stash at 16:59:59 and injected the handoff into a transient session that never persisted a transcript. The user's actual window started at 17:00:08 and got nothing. Root cause: **SessionStart fires for sessions with no human present**, so "next session to start" was the wrong consumption trigger. The `respawn-last.md` recovery copy worked; the resumed agent reconstructed context from it.

Redesign: the hook moved to `UserPromptSubmit` (proof a human is typing) with a freshness guard (only sessions whose transcript has no assistant turns yet may consume; ongoing conversations in other windows skip). Along the way a latent bug was found and fixed: the script fed its python program through a stdin heredoc, which swallowed the hook-input JSON, so nothing downstream of `json.load(sys.stdin)` could ever have worked.

**Observed (2026-08-14, after redesign):** end-to-end steps 3 and 4 re-verified against the real harness with a planted marker stash. A fresh headless session echoed the marker from the injected context and consumed the stash; a resumed ongoing session (step 4) answered normally and left a planted stash untouched. Step 2 (the skill-side handoff composition) was unchanged by the redesign except the closing-instruction wording and was not re-run.

## Dead end: any display at /clear time in the desktop app (2026-08-14)

Evaluated exhaustively after a user request; do not revisit without evidence the app changed. Three channels, all closed:

1. The new session's SessionStart: cannot run, the session doesn't exist until the first prompt (transcript-verified; see the lazy-session note above).
2. A truthful "injected" confirmation: impossible in principle at /clear, injection happens at the first prompt, so nothing has succeeded yet.
3. The old session's SessionEnd: probed live with a temporary hook (log every firing; on reason "clear", print to stderr and exit 2, the one SessionEnd channel the docs say is user-visible). Result: the desktop app fires SessionEnd with reason "other", not "clear", and rendered nothing; the user saw a blank window while the log confirmed the hook had run. Both the detection and the display half fail.

The blank screen between /clear and the first message is final in the desktop app.

## Codex fallback field test (2026-08-14)

First live run of the no-hook degradation, in OpenAI Codex: the agent stated upfront that Codex cannot inject automatically, wrote the stash to the shared path, printed the full six-section handoff, and adapted the closing instruction to append the manual resume line ("read ~/.claude/respawn-pending.md and continue" after the clear). Pass.

It also exposed a cross-tool footgun: a manual resume reads the stash without consuming it, so the still-fresh file remained armed for any fresh Claude session on the same machine (60-minute window). Fixed in the preamble: a reader who gets the stash via the manual fallback is instructed to move it to respawn-last.md before resuming. Not yet re-verified live on the Codex side.

Second finding from the same run: the Codex surface under test (IDE/app) has no `/clear` command (no autocomplete; typing it lands as a plain message, which the Codex agent handled gracefully at runtime by repeating the manual resume line). Verified against the official slash-command reference the same day: `/clear` ("Clear the terminal and start a fresh chat") exists in the Codex CLI only; the docs state the CLI command set does not apply to the web/IDE surfaces. The fallback previously kept the Claude-specific "run /clear now" closing instruction; the spec now replaces it with a harness-neutral "start a fresh session (new chat or task)" instruction that is correct on every Codex surface.

## Known limitations (by design, documented in README)

- `/clear` cannot be automated; the flow is two keystrokes.
- The stash is consumed by the first prompt of the first *fresh* session on the machine within 60 minutes, whichever window it is. Run `/clear` and type there promptly; don't prompt a different new window or start a headless run in between.
- The hook runs on every prompt submission (one file-existence check when idle).
- No hook support in Codex; the skill falls back to telling the user to point the fresh session at the stash file.
