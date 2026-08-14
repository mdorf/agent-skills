# respawn

One command to hand a full session off to a fresh agent in the same window: `/respawn`, review the handoff, `/clear`, keep typing. The new agent opens with "Resumed from respawn." and a short summary proving it's in the know.

> This README is for humans. The agent-facing specification is [SKILL.md](SKILL.md).

## The problem

Long sessions hit the context ceiling mid-task. Auto-compaction summarizes on the harness's schedule, not yours, and manual handoffs cost a file, a new window, and a paste. This skill makes the reset a deliberate, two-keystroke act that loses nothing.

## How it works

1. `/respawn`: the agent writes a thorough handoff (state, open items, next step, references, suggested skills) to `~/.claude/respawn-pending.md` and prints it inline for review. This is the moment to say "add X" while the old agent still has full context.
2. `/clear`: you clear the window. A SessionStart hook finds the fresh stash, injects it into the new session's context, and consumes it (a recovery copy stays at `~/.claude/respawn-last.md`).
3. Your next message can be one word. The new agent opens with "Resumed from respawn." plus a short done/open summary.

Stashes older than 60 minutes are archived without injecting, so a forgotten `/respawn` never contaminates an unrelated later session.

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
    ]
  }
}
```

## Limitations, stated plainly

- The agent cannot run `/clear` for you; that keystroke is yours. Two commands total, not one.
- The hook injects into the **next session that starts** on the machine within 60 minutes. Run `/clear` promptly after `/respawn`; a different window or a headless run started in between would consume the stash instead.
- Codex has no hook mechanism: there the skill degrades to writing the stash and telling you to open your fresh session with "read ~/.claude/respawn-pending.md and continue".

## Tested, not just written

Verified end to end on 2026-08-14: a live session invoked the skill mid-task, and a second session started cold on the one-word prompt "continue", opened with "Resumed from respawn." plus an accurate done/open summary, and picked up from the handoff's next step; the stash was consumed and archived. The resumed agent even validated the handoff against the repository before acting, courtesy of the step-back discipline this toolbox pairs with. Details in [TESTING.md](TESTING.md).
