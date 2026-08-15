# handoff

Compact the current session into a handoff document a fresh agent can continue from: `/handoff`, review the inline copy, request amendments if needed, done. The file lands in a durable directory with a dated name, so it is still there after a reboot, an OS update, or a week.

> This README is for humans. The agent-facing specification is [SKILL.md](SKILL.md).

## The problem

Ending a session mid-task loses everything the conversation established: state, decisions, open items, gotchas. A handoff doc fixes that, but only if it survives until the next session reads it, and only if you actually saw what went into it.

## How it works

1. `/handoff` (optionally with a focus, e.g. `/handoff continue the API migration`): the agent writes a handoff doc covering state, open items, references, and suggested skills for the next agent.
2. The file is saved to `~/Downloads` (falling back to `~/Documents`, then `$HOME`) as `handoff-<topic>-<YYYY-MM-DD>.md`, and the full document is also printed inline for review and easy copy-paste.
3. Request amendments while the agent still has full context; the file always matches the last version shown.

For a same-window reset with automatic re-injection, use the sibling [respawn](../respawn/) skill instead; handoff is for crossing machines, tools, or time.

## Origin

Adapted from Matt Pocock's [handoff skill](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff), MIT-licensed. His original established the shape: compact the conversation for another agent, reference artifacts instead of duplicating them, redact secrets, include a suggested-skills section, and treat arguments as the next session's focus. This version changes:

- **Destination.** The original saves to the OS temporary directory; this version considers that the main defect, since macOS wipes `/tmp` on system updates and other systems clear temp on reboot, exactly the lifetime a handoff must survive. Files go to a durable, user-visible directory instead, with a fallback chain for portability.
- **Dated, descriptive filenames**, so accumulated handoffs stay identifiable.
- **Inline copy, always.** The document is printed in the reply as well as saved, enabling review, amendment while the writing agent still has context, and copy-paste into another tool.
- **Amendment rule.** The saved file must always match the last version shown.
- **Trigger description** tuned to win over temp-directory-writing alternatives when multiple handoff skills are installed.

## Tested, not just written

See [TESTING.md](TESTING.md) for scenarios and recorded results.
