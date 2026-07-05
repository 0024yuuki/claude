#!/bin/bash
# PreToolUse:Bash - Shared PC safety enforcer
# Blocks dangerous commands that could affect the shared environment

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block sudo commands
if echo "$COMMAND" | grep -qE '(^|\s|;|&&|\|\|)sudo\s'; then
  echo "BLOCKED: sudo commands are forbidden on this shared PC." >&2
  exit 2
fi

# Block system package managers
if echo "$COMMAND" | grep -qE '(^|\s|;|&&|\|\|)(apt|apt-get|yum|dnf|rpm)\s'; then
  echo "BLOCKED: System package managers are forbidden. Use conda environments instead." >&2
  exit 2
fi

# Block modifications to shared conda base environment
if echo "$COMMAND" | grep -qE 'conda\s+install.*(-n\s+base|--name\s+base)'; then
  echo "BLOCKED: Do not modify the shared conda base environment." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'pip\s+install' && echo "$COMMAND" | grep -qE '/home/condauser/'; then
  echo "BLOCKED: Do not install packages into shared conda environments under /home/condauser/." >&2
  exit 2
fi

# Block conda create/remove in shared space
if echo "$COMMAND" | grep -qE 'conda\s+(create|remove|env\s+remove).*(/home/condauser/)'; then
  echo "BLOCKED: Do not create or remove environments in the shared conda space." >&2
  exit 2
fi

# Block access to other users' home directories
if echo "$COMMAND" | grep -qE '(/home/(?!yuki0024|condauser)[a-zA-Z0-9_]+)' | grep -qvE '(ls|cat|head|less|file)\s'; then
  # Allow read-only commands to other directories, block write operations
  if echo "$COMMAND" | grep -qE '(rm|mv|cp|chmod|chown|>|>>)\s.*/home/(?!yuki0024)[a-zA-Z0-9_]+'; then
    echo "BLOCKED: Do not modify files in other users' directories." >&2
    exit 2
  fi
fi

# Block rm -rf on critical paths
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(/home/yuki0024/packages|/home/condauser|/data2(?!/yuki0024))'; then
  echo "BLOCKED: Cannot delete shared infrastructure directories." >&2
  exit 2
fi

exit 0
