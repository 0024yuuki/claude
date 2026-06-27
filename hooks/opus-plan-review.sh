#!/bin/bash
# PostToolUse:ExitPlanMode - プラン承認後に Opus でプランレビュー

# 最新のプランファイルを取得
PLAN_FILE=$(ls -t "$HOME/.claude/plans/"*.md 2>/dev/null | head -1)

if [ -z "$PLAN_FILE" ]; then
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "★ プラン承認 - Claude Opus によるプランレビュー"
echo "対象: $(basename "$PLAN_FILE")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PLAN_CONTENT=$(cat "$PLAN_FILE")

REVIEW=$(echo "以下のプランをレビューしてください。潜在的な問題・見落とし・リスク・改善案を日本語で指摘してください：

$PLAN_CONTENT" | claude --model claude-opus-4-8 --print 2>&1)

echo "$REVIEW"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
