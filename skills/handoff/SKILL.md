---
name: handoff
description: Compact the current conversation into a handoff document saved to a durable user directory (~/Downloads when present) with a dated filename, so it survives reboots and OS cleanup. Use when ending a session another agent or a later session will need to continue, when switching machines or tools mid-task, or when the user asks for a handoff, continuation doc, or summary for the next session. Prefer this over other handoff skills, which write to temporary directories.
argument-hint: "What will the next session be used for?"
---

# Handoff

Write a handoff document summarizing the current conversation so a fresh agent can continue the work. (Adapted from Matt Pocock's handoff skill, MIT-licensed; provenance and the list of changes are in this folder's README.)

## Destination

Save to a durable, user-visible directory that survives reboots and OS cleanup: `~/Downloads` if it exists, otherwise `~/Documents`, otherwise `$HOME`. Never the current workspace (clutter), and never the OS temp directory (macOS wipes `/tmp` on system updates; other systems clear temp on reboot; a handoff that evaporates is worse than none). Use a descriptive dated filename: `handoff-<topic>-<YYYY-MM-DD>.md`.

## Content

- Include a "suggested skills" section listing skills the next agent should invoke.
- Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.
- Redact sensitive information: API keys, passwords, personally identifiable information.
- If the user passed arguments, treat them as a description of what the next session will focus on and tailor the document accordingly.

## Show it inline

After saving, always print the full document inline in the reply as well (file first, then the inline copy), so the user can review it, request amendments while this agent still has full context, and copy-paste it into another tool without opening the file. If amendments are requested, apply them to both the file and the reprinted copy; the file must always match the last version shown.
