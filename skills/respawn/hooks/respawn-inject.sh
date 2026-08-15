#!/usr/bin/env bash
# UserPromptSubmit hook: inject a pending /respawn handoff stash at the first
# user prompt of a fresh session, consume-once.
#
# Why UserPromptSubmit and not SessionStart: SessionStart fires for sessions
# nobody is looking at (app relaunch warm sessions, background utility
# sessions), and one of those can silently eat the stash. A UserPromptSubmit
# event is proof a human is typing in that session. The freshness check below
# additionally keeps ongoing conversations in other windows from consuming a
# stash meant for a cleared one.
set -u
STASH="$HOME/.claude/respawn-pending.md"
LAST="$HOME/.claude/respawn-last.md"

# Fast path: this hook runs on every prompt; one stat and out when idle.
[ -f "$STASH" ] || exit 0

# The program is passed via -c, not a stdin heredoc: the hook's stdin must
# stay untouched so python can read the hook input JSON from it.
PROG=$(cat << 'PY'
import json, os, sys, time

stash, last = sys.argv[1], sys.argv[2]

try:
    mtime = os.stat(stash).st_mtime
except FileNotFoundError:
    sys.exit(0)  # raced with another session's consume

# Older than 60 minutes: stale. Archive without injecting, from any session,
# so a forgotten /respawn never contaminates an unrelated later session.
if time.time() - mtime > 3600:
    os.replace(stash, last)
    sys.exit(0)

# Only a fresh session may consume the stash. "Fresh" means its transcript has
# no assistant turns yet: true right after /clear or at the first prompt of a
# new window, false for every ongoing conversation. A non-fresh session leaves
# the stash in place for the session it was meant for.
try:
    hook_input = json.load(sys.stdin)
except Exception:
    sys.exit(0)
transcript = hook_input.get("transcript_path") or ""
if transcript and os.path.exists(transcript):
    with open(transcript, errors="replace") as f:
        for line in f:
            try:
                if json.loads(line).get("type") == "assistant":
                    sys.exit(0)
            except Exception:
                continue

# Consume first (atomic rename), then read from the recovery copy, so two
# fresh sessions racing on the same stash cannot both inject it.
try:
    os.replace(stash, last)
except FileNotFoundError:
    sys.exit(0)
content = open(last, errors="replace").read()
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": content,
    }
}))
PY
)
python3 -c "$PROG" "$STASH" "$LAST"
