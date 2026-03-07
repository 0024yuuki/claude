#!/bin/bash
set -euo pipefail

TURNS="${1:-5}"
OUTPUT_FILE="${2:-context.txt}"

# 最新のtranscriptファイルを特定
TRANSCRIPT=$(ls -t ~/.claude/projects/-home-yuki0024/*.jsonl 2>/dev/null | head -1)

if [[ ! -f "$TRANSCRIPT" ]]; then
  echo "❌ エラー: Transcriptファイルが見つかりません" >&2
  exit 1
fi

# 一時ファイルを作成
TEMP_FILE=$(mktemp)
trap "rm -f '$TEMP_FILE'" EXIT

# user/assistantメッセージを抽出（tool_resultは除外）
jq -r '
  select(.type == "user" or .type == "assistant") |
  select(.message != null and (.message | type) == "object") |
  {
    role: .message.role,
    content: (
      .message.content
      | if type == "array" then
          map(select(.type == "text")) | map(.text) | join("\n")
        else
          ""
        end
    )
  } |
  select(.content != "") |
  "\(.role | ascii_upcase):\n\(.content)\n---\n"
' "$TRANSCRIPT" 2>/dev/null > "$TEMP_FILE"

# 最新N件のターンを抽出（user-assistant のペアをターンとしてカウント）
# 各ターンは "USER:", "ASSISTANT:", "---" の3セクションで構成
LINE_COUNT=$(wc -l < "$TEMP_FILE")
LINES_PER_TURN=6  # 平均的な行数（可変なので概算）

# 最新のN*6行を抽出（余裕を持って取得）
tail -n $((TURNS * 20)) "$TEMP_FILE" > "$OUTPUT_FILE"

ENTRY_COUNT=$(grep -c "^USER:\|^ASSISTANT:" "$OUTPUT_FILE" || echo 0)

echo "✓ 会話履歴を抽出しました: $OUTPUT_FILE"
echo "  - Transcript: $(basename "$TRANSCRIPT")"
echo "  - エントリ数: ${ENTRY_COUNT}件"
