# agent-skills

Portable Agent Skills ([SKILL.md](https://agentskills.io) open standard) for **Claude Code**, **OpenAI Codex**, and other AI coding agents.

Each skill is a self-contained folder under [`skills/`](skills/) with a `SKILL.md` file (plus optional `references/` and `scripts/`). The same skill folder works in both Claude Code and Codex without modification. Only the install location differs.

## Skills

| Skill | Description |
|---|---|
| [before-and-after](skills/before-and-after/) | Captures before/after evidence for a code change (query counts, latency, UI screenshot pairs) under identical conditions and adds it to the PR |
| [solve](skills/solve/) | Resolves an issue/ticket with discipline: validates the premise against current code, weighs the proposed fix against alternatives, and stops for review before writing the fix |
| [step-back](skills/step-back/)† | Grounding discipline: verify a suggestion's mechanism before voicing it, treat negative search results as unproven, establish scope before remedy, and stop the tweak-upon-tweak loop after failed fixes |
| [brevity](skills/brevity/)† | Replies that land: answer first, length proportional to what the reply must accomplish, plain register, asks never buried, and no substance lost to shortening |
| [respawn](skills/respawn/) | **A MUST-HAVE skill that cures context rot.** Invoke it in the same session when you notice your usable context filling up, or when your agent's responses aren't as sharp as they used to be. It lets you reset your context back to zero without losing a drop of conversation quality.<br><br>Same-window session handoff that survives a context reset:<br>**1.** `/respawn` → review the handoff it prints<br>**2.** *(optional)* request corrections → the handoff is amended and re-armed<br>**3.** `/clear` → screen goes blank (normal, nothing can render here)<br>**4.** type anything → "handoff injected" confirmation, and the fresh agent opens with "Resumed from respawn.", already in the know<br><sub>Desktop-app quirks, by the app's design: step 4's keystroke cannot be automated, and `/clear` resets a custom session title (rename it back by hand).</sub> |
| [handoff](skills/handoff/) | Compacts the session into a handoff document a fresh agent can continue from, saved durably (`~/Downloads`, dated filename, survives reboots and OS cleanup) and always printed inline for review, amendment, and copy-paste. Use it to cross machines, tools, or time; use respawn for a same-window reset. Adapted with credit from [Matt Pocock's handoff](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff) (MIT); the delta is in the skill's README |

† Meant to run implicitly, which needs always-on companion rules. Claude Code users: install the [ground-rules](ground-rules/) companion plugin (one command, below). Codex or manual users: paste the snippet from the skill's README into your global CLAUDE.md / AGENTS.md. Without either, these two work as manual commands (/step-back, /brevity) only.

## Installation

### Claude Code

Option A, via the plugin marketplace (recommended):

```
/plugin marketplace add mdorf/agent-skills
/plugin install agent-skills@mdorf-agent-skills
```

Optional third command, recommended if you want step-back and brevity active implicitly in every session (see the † note above):

```
/plugin install ground-rules@mdorf-agent-skills
```

Option B, symlink or copy a skill directly:

```bash
# user-level (all projects)
ln -s "$(pwd)/skills/<skill-name>" ~/.claude/skills/<skill-name>

# project-level (one repo)
ln -s "$(pwd)/skills/<skill-name>" /path/to/project/.claude/skills/<skill-name>
```

### OpenAI Codex

```bash
# user-level (all projects)
ln -s "$(pwd)/skills/<skill-name>" ~/.agents/skills/<skill-name>

# project-level (one repo)
ln -s "$(pwd)/skills/<skill-name>" /path/to/project/.agents/skills/<skill-name>
```

### Both at once

```bash
./install.sh <skill-name>   # symlinks into ~/.claude/skills and ~/.agents/skills
```

## Repo layout

```
agent-skills/
├── skills/                # canonical source of truth, one folder per skill
│   └── <skill-name>/
│       ├── SKILL.md       # portable: works in Claude Code and Codex as-is
│       ├── README.md      # human-facing: the problem, usage, evidence
│       ├── TESTING.md     # scenarios, pass criteria, recorded results
│       ├── references/    # optional supporting docs (loaded on demand)
│       └── scripts/       # optional helper scripts
├── .claude-plugin/
│   ├── plugin.json        # plugin manifest; bump version here on release
│   └── marketplace.json   # marketplace manifest (ignored by Codex)
└── install.sh             # symlink installer for user-level use in both tools
```

## Releasing changes

When publishing a change, bump `version` in both `.claude-plugin/plugin.json` and the plugin entry of `.claude-plugin/marketplace.json` (keep them identical). Claude Code identifies installed plugin builds by this version; without it, the git commit hash is used, which leaks into skill names and accumulates stale cache directories.

## Compatibility notes

- `SKILL.md` frontmatter sticks to the shared fields of the open standard (`name`, `description`) so skills stay portable.
- Claude-specific extras (e.g. `allowed-tools`) and Codex-specific extras (e.g. `openai.yaml`) may appear in a skill folder; each tool ignores the other's additions.
- Claude-only plugin features (slash commands, subagents, hooks) would live in sibling top-level directories if ever added, leaving `skills/` fully portable.
