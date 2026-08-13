# brevity

Makes an AI agent's replies land: answer first, length proportional to the question, plain words, asks never buried.

> This README is for humans. The agent-facing specification is [SKILL.md](SKILL.md).

## The problem

Four related failures, all from real sessions: a one-line question gets seven paragraphs; the phrasing runs academic where plain words work; the reply's actual ask sits in the last sentence and gets missed, costing a round trip; and the result is correct answers nobody finishes reading.

"Be concise" alone doesn't fix this. It causes under-answering, the complaint that would come next. The rule this skill encodes is proportion: cut words, never content, candor, or ideas, and never cap a deliverable that earned its length.

## Usage

Loaded at discrete moments, not continuously: reporting the results of an investigation or review, reporting completed work, answering a yes/no, carrying a decision the user must act on, or recovering after a verbosity complaint. An earlier version triggered on "composing any reply" and measured zero invocations across 32 turns of real use; a trigger with no decision point never fires. Keep the always-on floor in your global CLAUDE.md / AGENTS.md (answer first, asks up front, plain words); the skill carries the register, the deletion list, and the proportionality ladder, which are worth loading when a reply is about to run long. Invoke `/brevity` directly when a session has drifted wordy.

## What it encodes

- First sentence is the answer, verdict, or ask.
- A proportionality ladder: a confirmation gets the outcome and anything that contradicts what was promised; a narrow question gets a few sentences; a requested deliverable gets what its content needs.
- Per-sentence test: would the reader act differently without it? No: cut.
- Asks go first or stand alone; one open question per reply.
- Formatting must earn its place; short replies get none.
- Plain technical register, with a swap-list for showcase vocabulary.
- Named deletions: question restatement, previews, self-summaries, hedge stacks, ceremony, and narrating verification that passed.
- Hard floors: substance, candor, ideas, and deliverable completeness are never traded for length.

## Tested, not just written

Same real question, same available facts: without the skill, ~370 words opening with "Good question to press on..."; with it, ~170 words starting "Only half of that claim was grounded", all three substance points intact, one closing question. The over-correction guard confirmed a full spec review still comes back complete (all seeded defects plus a meeting script), and the placement test put the decision first with exactly one question.

The proportionality ladder and the verification-narration deletion came later, from measuring 32 replies in one real session: the requested deliverables were proportionate, but confirmations ran 250 to 350 words each. Re-running the three behavioral scenarios after that change found no regression, including the one guarding against truncated deliverables. Scenarios and criteria in [TESTING.md](TESTING.md).

## Install

See the [repo README](../../README.md). Works in Claude Code (plugin marketplace or `~/.claude/skills`) and OpenAI Codex (`~/.agents/skills`) from the same folder.
