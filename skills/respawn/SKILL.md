---
name: respawn
description: Use when the user invokes /respawn, or asks to hand this session off to a fresh one in the same window, reset context without losing state, or continue seamlessly after the context fills up.
---

# Respawn

Hand this session off to a fresh agent in the same window. Two moves: write a complete handoff to a stash file that the next session ingests automatically, and show it to the user for review. The user then runs `/clear`; a UserPromptSubmit hook injects the stash at the first prompt of the fresh session, with a visible confirmation (sessions that start with nobody typing, like app-relaunch warm sessions, cannot consume it, and ongoing conversations in other windows are skipped).

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
wrote the handoff below, then the user cleared the context. If you are
reading this directly from ~/.claude/respawn-pending.md (manual fallback,
no automatic injection), first move that file to ~/.claude/respawn-last.md
so it cannot leak into an unrelated session. Open your first reply with
"Resumed from respawn." followed by one or two short paragraphs: what was
already done, and what remains open. Then continue the work; the handoff's
"Next step" is your starting point. Do not re-litigate decisions recorded
here.
```

## Step 3: Stash, show, arm

1. Write preamble + handoff to `~/.claude/respawn-pending.md` (overwrite if present).
2. Print the full handoff inline in the reply so the user can review it while this agent can still amend it.
3. End the reply with exactly this instruction, bolded, as its own final paragraph so it cannot be missed: "**Stash armed → run `/clear` now.** (Your first message in the cleared window resumes automatically. Don't prompt a different fresh session in between; the first fresh session you type into consumes the stash.)"
4. If the user requests changes after reviewing, apply them, rewrite the stash file, reprint the full amended handoff, and end with the same closing instruction. The stash on disk must always match the last handoff shown; the version the user approved is the version the next agent gets.

## Requirements and fallback

Automatic injection requires the UserPromptSubmit hook shipped with this skill (see README). If the hook is not installed, or this harness has no hook support (e.g. Codex), say so and fall back: keep the stash file, and replace the closing instruction from step 3 with this harness-neutral one (do not mention `/clear`; Codex has no such command): "**Stash written → start a fresh session (new chat or task) and open it with: `read ~/.claude/respawn-pending.md and continue`**". Never skip writing the stash; the inline copy disappears when the user resets the window.
