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
    MODELS+=("$model")
  fi
done

if [[ ${#MODELS[@]} -eq 0 ]]; then
  echo "❌ エラー: 結果ファイルが見つかりません" >&2
  exit 1
fi

# モデル特徴の定義
get_model_features() {
  case "$1" in
    sonnet)
      echo "バランス型、詳細な説明"
      ;;
    opus)
      echo "高精度、包括的分析"
      ;;
    haiku)
      echo "高速、簡潔で実用的"
      ;;
    *)
      echo "標準モデル"
      ;;
  esac
}

# マークダウン形式で出力
cat <<EOF
# 🔍 セカンドオピニオン結果

## 実行サマリー

| モデル | 状態 | 特徴 |
|--------|------|------|
EOF

# 各モデルの状態を表示
for model in "${MODELS[@]}"; do
  if [[ -f "$WORK_DIR/${model}.done" ]]; then
    status="✓ 完了"
  elif [[ -f "$WORK_DIR/${model}.error" ]]; then
    status="⚠️ エラー"
  else
    status="❓ 不明"
  fi

  features=$(get_model_features "$model")
  echo "| $(echo "$model" | sed 's/\b\(.\)/\u\1/g') | $status | $features |"
done

cat <<EOF

---

## 📊 各モデルの回答

EOF

# 各モデルの回答を表示
for model in "${MODELS[@]}"; do
  model_name=$(echo "$model" | sed 's/sonnet/Claude Sonnet 4.5/' | sed 's/opus/Claude Opus 4.6/' | sed 's/haiku/Claude Haiku 4.5/')

  cat <<EOF
### $model_name

EOF

  if [[ -f "$WORK_DIR/${model}.md" ]]; then
    cat "$WORK_DIR/${model}.md"
  else
    echo "⚠️ 結果が見つかりません"
  fi

  echo ""
  echo "---"
  echo ""
done

# 作業ディレクトリのパスを出力（デバッグ用）
cat <<EOF

---

*結果ファイル: \`$WORK_DIR\`*

EOF
