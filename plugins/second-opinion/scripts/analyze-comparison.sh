#!/bin/bash
set -euo pipefail

WORK_DIR="${1:-}"

if [[ -z "$WORK_DIR" ]] || [[ ! -d "$WORK_DIR" ]]; then
  echo "❌ エラー: 作業ディレクトリが指定されていないか存在しません" >&2
  echo "使用法: $0 <work_dir>" >&2
  exit 1
fi

# モデル一覧を検出
declare -a MODELS=()
for file in "$WORK_DIR"/*.md; do
  if [[ -f "$file" ]]; then
    model=$(basename "$file" .md)
    # プロンプトファイルは除外
    if [[ ! "$model" =~ _prompt$ ]]; then
      MODELS+=("$model")
    fi
  fi
done

if [[ ${#MODELS[@]} -eq 0 ]]; then
  echo "❌ エラー: 結果ファイルが見つかりません" >&2
  exit 1
fi

# 分析プロンプトを作成
ANALYSIS_PROMPT_FILE="$WORK_DIR/analysis_prompt.txt"

cat > "$ANALYSIS_PROMPT_FILE" <<'EOF'
あなたは複数のAIモデルの回答を比較分析する専門家です。
以下は、同じ質問に対する複数のClaude モデルの回答です。これらを客観的に比較分析してください。

EOF

# 各モデルの回答を追加
for model in "${MODELS[@]}"; do
  model_name=$(echo "$model" | sed 's/sonnet/Sonnet/' | sed 's/opus/Opus/' | sed 's/haiku/Haiku/' | sed 's/\b\(.\)/\u\1/g')

  cat >> "$ANALYSIS_PROMPT_FILE" <<EOF

## ${model_name} の回答

EOF

  if [[ -f "$WORK_DIR/${model}.md" ]]; then
    cat "$WORK_DIR/${model}.md" >> "$ANALYSIS_PROMPT_FILE"
  else
    echo "（回答なし）" >> "$ANALYSIS_PROMPT_FILE"
  fi

  echo "" >> "$ANALYSIS_PROMPT_FILE"
  echo "---" >> "$ANALYSIS_PROMPT_FILE"
  echo "" >> "$ANALYSIS_PROMPT_FILE"
done

# 分析指示を追加
cat >> "$ANALYSIS_PROMPT_FILE" <<'EOF'

上記の回答を分析して、以下の形式で比較レポートを作成してください：

# 🔍 比較分析

## 共通する推奨事項

[全モデルが一致している重要なポイントを箇条書きで3-5個列挙]

## モデル間の主要な相違点

### アプローチの違い
[各モデルのアプローチの特徴を比較]

### 詳細度の比較
[説明の詳しさ、例示の豊富さなどを比較]

### リスク評価の違い
[セキュリティ、パフォーマンス、保守性などの考慮事項の違い]

## 各モデルの特徴的な視点

### Sonnetの特徴
[Sonnetモデル独自の視点や提案]

### Opusの特徴
[Opusモデル独自の視点や提案]

### Haikuの特徴
[Haikuモデル独自の視点や提案]

## 💡 総合評価

### 最も信頼性が高い回答
[どのモデルの回答が最も信頼できるか、その理由]

### 推奨アクション
1. [具体的な次のステップ]
2. [実装時の注意点]
3. [さらに検討すべき事項]

---

**分析のポイント：**
- 各モデルの強みと弱みを客観的に評価してください
- 技術的な正確性を重視してください
- 実用性と実現可能性を考慮してください
- どの回答が最も有用かを明確に示してください
EOF

echo "⏳ 比較分析を実行中..."
echo ""

# Claude Sonnetで分析実行
ANALYSIS_OUTPUT="$WORK_DIR/analysis.md"
if cat "$ANALYSIS_PROMPT_FILE" | claude --model sonnet --print > "$ANALYSIS_OUTPUT" 2>&1; then
  echo "✓ 分析が完了しました"
  echo ""
  cat "$ANALYSIS_OUTPUT"
else
  echo "⚠️ 分析中にエラーが発生しました" >&2
  cat "$ANALYSIS_OUTPUT" >&2
  exit 1
fi
