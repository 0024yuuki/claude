#!/bin/bash
# PreToolUse:Write|Edit - Path safety guard
# Blocks file writes outside allowed directories

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Resolve to absolute path
if [[ "$FILE_PATH" != /* ]]; then
  CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
  FILE_PATH="${CWD}/${FILE_PATH}"
fi

# Allowed paths
ALLOWED=false

case "$FILE_PATH" in
  /home/yuki0024/*)
    ALLOWED=true
    ;;
  /data2/yuki0024/*)
    ALLOWED=true
    ;;
  /tmp/*)
    ALLOWED=true
    ;;
esac

if [ "$ALLOWED" = false ]; then
  echo "BLOCKED: Writing to '$FILE_PATH' is not allowed. Allowed paths: /home/yuki0024/, /data2/yuki0024/, /tmp/" >&2
  exit 2
fi

# Block writes to shared packages directory (except with explicit subdirs for personal scripts)
if [[ "$FILE_PATH" == /home/yuki0024/packages/* ]]; then
  echo "WARNING: /home/yuki0024/packages/ is shared infrastructure. Proceed with caution." >&2
  # Don't block, just warn (exit 0)
fi

exit 0
