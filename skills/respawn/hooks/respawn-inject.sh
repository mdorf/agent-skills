#!/usr/bin/env bash
# SessionStart hook (matchers: clear|startup): inject a pending /respawn
# handoff stash into the new session's context, consume-once.
set -u
STASH="$HOME/.claude/respawn-pending.md"
LAST="$HOME/.claude/respawn-last.md"
[ -f "$STASH" ] || exit 0

now=$(date +%s)
mtime=$(stat -f %m "$STASH" 2>/dev/null || stat -c %Y "$STASH" 2>/dev/null) || exit 0
age=$(( now - mtime ))

# Consume the stash either way so a stale one never lingers; keep a recovery copy.
mv "$STASH" "$LAST"

# Older than 60 minutes: treat as stale, archive without injecting.
[ "$age" -gt 3600 ] && exit 0

python3 - "$LAST" << 'PY'
import json, sys
content = open(sys.argv[1]).read()
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": content,
    }
}))
PY
