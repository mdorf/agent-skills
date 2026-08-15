# respawn

One command to hand a full session off to a fresh agent in the same window: `/respawn`, review the handoff, `/clear`, keep typing. The new agent opens with "Resumed from respawn." and a short summary proving it's in the know.

> This README is for humans. The agent-facing specification is [SKILL.md](SKILL.md).

## The problem

Long sessions hit the context ceiling mid-task. Auto-compaction summarizes on the harness's schedule, not yours, and manual handoffs cost a file, a new window, and a paste. This skill makes the reset a deliberate, two-keystroke act that loses nothing.

## How it works

1. `/respawn`: the agent writes a thorough handoff (state, open items, next step, references, suggested skills) to `~/.claude/respawn-pending.md` and prints it inline for review. This is the moment to say "add X" while the old agent still has full context.
2. `/clear`: you clear the window. In the desktop app the window simply goes blank; that's normal (see the limitation below).
3. Your next message can be one word. A UserPromptSubmit hook sees the fresh stash, injects it right there, and consumes it. A visible confirmation is shown ("Respawn handoff injected into this session"; a recovery copy stays at `~/.claude/respawn-last.md`), and the new agent opens with "Resumed from respawn." plus a short done/open summary.

Two guards keep the stash from going to the wrong place. Injection happens at a user prompt, not at session start, so sessions nobody is typing in (app-relaunch warm sessions, background utility sessions) can never consume it. And only a *fresh* session (no assistant turns in its transcript yet) qualifies, so typing in an ongoing conversation in another window leaves the stash alone. Stashes older than 60 minutes are archived without injecting, so a forgotten `/respawn` never contaminates an unrelated later session.

## Install

The skill itself installs like the others in this repo (plugin marketplace or symlink). The automatic injection additionally needs the hook, which is Claude Code-specific:

```bash
mkdir -p ~/.claude/hooks
cp skills/respawn/hooks/respawn-inject.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/respawn-inject.sh
```

Then add to `~/.claude/settings.json` (merge with existing keys):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "clear|startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.claude/hooks/respawn-inject.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.claude/hooks/respawn-inject.sh\"",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

One script serves both events: SessionStart is display-only (it announces a pending stash and never consumes it), UserPromptSubmit does the injection. The split exists because SessionStart also fires for sessions nobody is typing in, which is how an earlier version of this hook once lost a handoff to an app relaunch.

## Limitations, stated plainly

- The agent cannot run `/clear` for you; that keystroke is yours. Two commands total, not one.
- The hook injects at the **first prompt of the first fresh session** on the machine within 60 minutes. Run `/clear` and type there promptly after `/respawn`; prompting a different fresh session (a new window, a headless run) in between would consume the stash instead. Ongoing sessions and unattended session starts cannot.
- The hook runs on every prompt submission; when no stash is pending it exits after a single file-existence check.
- The "Respawn handoff pending" notice (a display-only SessionStart branch) cannot appear at `/clear` time in the desktop app, because the app creates the post-clear session lazily, at your first message; until then no hook can run, so the screen stays blank. Verified from a live transcript: the SessionStart notice, the prompt, and the injection all carry the same timestamp. The notice only helps in harnesses that start sessions eagerly.
- In the Claude desktop app, `/clear` also resets a custom session title; the app re-auto-titles from the first post-clear message. The skill cannot preserve it: the app's session-management tools refuse to act on the caller's own session, so the resumed agent can neither read nor restore the name. Rename the session manually afterward (or ask any other Claude window to do it) if the title matters.
- Codex has no hook mechanism, so there the skill degrades to writing the stash and telling you: `/new`, then open the fresh chat with "read ~/.claude/respawn-pending.md and continue". The stash-reading agent moves the file to `respawn-last.md` itself, since no hook will.

## Tested, not just written

Verified end to end on 2026-08-14: a live session invoked the skill mid-task, and a second session started cold on the one-word prompt "continue", opened with "Resumed from respawn." plus an accurate done/open summary, and picked up from the handoff's next step; the stash was consumed and archived. The resumed agent even validated the handoff against the repository before acting, courtesy of the step-back discipline this toolbox pairs with.

The same day, dogfooding found the design's one real failure mode: the original SessionStart hook let an app relaunch (a session start with nobody typing) silently eat the stash. The hook was redesigned around UserPromptSubmit plus the freshness check, and re-verified live: a fresh headless session received the injection at its first prompt, and a resumed ongoing session left the stash untouched. Details in [TESTING.md](TESTING.md).
