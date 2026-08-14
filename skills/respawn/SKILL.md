---
name: respawn
description: Use when the user invokes /respawn, or asks to hand this session off to a fresh one in the same window, reset context without losing state, or continue seamlessly after the context fills up.
---

# Respawn

Hand this session off to a fresh agent in the same window. Two moves: write a complete handoff to a stash file that the next session ingests automatically, and show it to the user for review. The user then runs `/clear`; a SessionStart hook injects the stash into the new context.

## Step 1: Compose the handoff

Write it for an agent with zero context. Include, in this order:

1. **Task and goal**: what this session is doing and why.
2. **State**: what is already done, with evidence (files changed, commits, test results, decisions the user approved).
3. **Open items**: what remains, in priority order, with enough detail to act on each.
4. **Next step**: the single concrete action the new agent should take first.
5. **References**: paths, URLs, ticket/PR numbers. Reference artifacts (plans, PRDs, commits, diffs) instead of duplicating their content.
6. **Suggested skills** the next agent should invoke, if any.

Redact secrets (API keys, passwords, personal data). If the user passed arguments, treat them as what the next session will focus on and tailor the handoff accordingly.

## Step 2: Prepend the resume preamble

The stash must open with instructions to the NEXT agent, above the handoff body:

```
You are resuming a session via /respawn. The previous agent in this window
wrote the handoff below, then the user cleared the context. Open your first
reply with "Resumed from respawn." followed by one or two short paragraphs:
what was already done, and what remains open. Then continue the work; the
handoff's "Next step" is your starting point. Do not re-litigate decisions
recorded here.
```

## Step 3: Stash, show, arm

1. Write preamble + handoff to `~/.claude/respawn-pending.md` (overwrite if present).
2. Print the full handoff inline in the reply so the user can review it while this agent can still amend it.
3. End the reply with exactly this instruction as its own line: "Stash armed. Run /clear now; the next session resumes automatically."

## Requirements and fallback

Automatic injection requires the SessionStart hook shipped with this skill (see README). If the hook is not installed, or this harness has no hook support (e.g. Codex), say so and fall back: keep the stash file and tell the user to start their fresh session with "read ~/.claude/respawn-pending.md and continue". Never skip writing the stash; the inline copy disappears when the user clears the window.
