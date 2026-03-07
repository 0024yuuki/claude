#!/bin/bash
# PreToolUse:Write|Edit - File-type-specific development conventions
# Injects coding conventions based on file extension

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

CONTEXT=""

case "$FILE_PATH" in
  *.py)
    CONTEXT="Python conventions: Use argparse for CLI tools. Dictionary aggregation pattern for results. Python 3.10 from my_env. Comments in Japanese/English for biological context."
    ;;
  *.R|*.r)
    CONTEXT="R conventions: Use tidyverse (dplyr, ggplot2, tidyr). Source custom functions from /home/yuki0024/packages/R/R_program/. Execute via SGE queue, not local sessions."
    ;;
  *.Rmd|*.rmd)
    CONTEXT="Rmarkdown conventions: YAML frontmatter with code_folding: hide, toc: true. Execute via SGE: qsub /home/yuki0024/packages/R/Rmarkdown_submit.sh. Use tidyverse libraries."
    ;;
  *.sh)
    CONTEXT="Shell/SGE conventions: Use SGE headers (#$ -cwd, #$ -pe smp N, #$ -l s_vmem=XG, #$ -N JobName). Always source ~/.bash_profile and conda activate <env>. Use \${HOME} and \${OUTPUT_DIR} variables. Log to log_o/log_e files."
    ;;
esac

if [ -n "$CONTEXT" ]; then
  # Output as JSON for context injection
  ESCAPED=$(echo "$CONTEXT" | sed 's/"/\\"/g')
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"additionalContext\":\"${ESCAPED}\"}}"
fi

exit 0
