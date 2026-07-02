#!/bin/bash
# PreToolUse:Bash - git push 前に Opus でコードレビュー（通知型・ブロックなし）

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git push を含むコマンドのみ処理（それ以外は即座に通過）
if ! echo "$COMMAND" | grep -qE 'git push'; then
  exit 0
fi

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
DIFF=$(git diff "origin/$CURRENT_BRANCH"..HEAD 2>/dev/null)
[ -z "$DIFF" ] && DIFF=$(git diff HEAD~1..HEAD 2>/dev/null)

if [ -z "$DIFF" ]; then
  echo "★ git push 前レビュー: 差分なし、スキップします"
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "★ git push 前 - Claude Opus コードレビュー"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REVIEW=$(echo "以下のコード変更を git push 前にレビューしてください。バグ・セキュリティ問題・コード品質について日本語で簡潔に報告してください：

$DIFF" | claude --model claude-opus-4-8 --print 2>&1)

echo "$REVIEW"
echo ""
echo "（Opus レビュー完了 - push を続行します）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
