# agent-skills

Portable Agent Skills ([SKILL.md](https://agentskills.io) open standard) for **Claude Code**, **OpenAI Codex**, and other AI coding agents.

Each skill is a self-contained folder under [`skills/`](skills/) with a `SKILL.md` file (plus optional `references/` and `scripts/`). The same skill folder works in both Claude Code and Codex without modification. Only the install location differs.

## Skills

| Skill | Description |
|---|---|
| [before-and-after](skills/before-and-after/) | Instruments measured before/after performance evidence (query counts, round trips, latency) for a code change and adds it to the PR |
| [solve](skills/solve/) | Resolves an issue/ticket with discipline: validates the premise against current code, weighs the proposed fix against alternatives, and stops for review before writing the fix |

## Installation

### Claude Code

Option A, via the plugin marketplace (recommended):

```
/plugin marketplace add mdorf/agent-skills
/plugin install agent-skills@mdorf-agent-skills
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
│       ├── references/    # optional supporting docs (loaded on demand)
│       └── scripts/       # optional helper scripts
├── .claude-plugin/
│   └── marketplace.json   # Claude Code plugin marketplace manifest (ignored by Codex)
└── install.sh             # symlink installer for user-level use in both tools
```

## Compatibility notes

- `SKILL.md` frontmatter sticks to the shared fields of the open standard (`name`, `description`) so skills stay portable.
- Claude-specific extras (e.g. `allowed-tools`) and Codex-specific extras (e.g. `openai.yaml`) may appear in a skill folder; each tool ignores the other's additions.
- Claude-only plugin features (slash commands, subagents, hooks) would live in sibling top-level directories if ever added, leaving `skills/` fully portable.
