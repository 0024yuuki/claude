#!/bin/bash
set -euo pipefail

# 依存関係チェック
if ! command -v tmux &> /dev/null; then
  echo "❌ エラー: tmuxがインストールされていません" >&2
  echo "   インストールコマンド: sudo yum install tmux" >&2
  exit 1
fi

if ! command -v claude &> /dev/null; then
  echo "❌ エラー: claudeコマンドが見つかりません" >&2
  exit 1
fi

# 引数パース
CONTEXT_FILE="${1:-}"
MODELS="${2:-sonnet,opus,haiku}"
TIMEOUT="${3:-300}"

if [[ -z "$CONTEXT_FILE" ]] || [[ ! -f "$CONTEXT_FILE" ]]; then
  echo "❌ エラー: コンテキストファイルが指定されていないか存在しません" >&2
  echo "使用法: $0 <context_file> [models] [timeout]" >&2
  exit 1
fi

# 作業ディレクトリ作成
WORK_DIR="/tmp/second-opinion-$$"
mkdir -p "$WORK_DIR"

# ユーザー確認プロンプト
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 セカンドオピニオン実行"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 モデル: $MODELS"
echo "📝 会話履歴: $(basename "$CONTEXT_FILE")"
echo "⏱️  タイムアウト: ${TIMEOUT}秒"
echo ""
echo "続行しますか？ [Y/n] "
read -r response
if [[ "$response" =~ ^[Nn] ]]; then
  echo "キャンセルされました"
  rm -rf "$WORK_DIR"
  exit 0
fi

echo ""
echo "⏳ 並列実行を開始します..."
echo ""

# tmuxセッション作成
TMUX_SESSION="second-opinion-$$"
tmux new-session -d -s "$TMUX_SESSION" -n "orchestrator"

# 各モデルで並列実行
IFS=',' read -ra MODEL_ARRAY <<< "$MODELS"
for model in "${MODEL_ARRAY[@]}"; do
  output_file="$WORK_DIR/${model}.md"
  done_file="$WORK_DIR/${model}.done"
  error_file="$WORK_DIR/${model}.error"

  # プロンプトを準備（コンテキスト + 指示）
  PROMPT_FILE="$WORK_DIR/${model}_prompt.txt"
  cat > "$PROMPT_FILE" <<EOF
以下は、ユーザーとClaude Assistantの会話履歴です。

$(cat "$CONTEXT_FILE")

---

上記の会話内容を踏まえて、ユーザーの最後の質問または要求に対する回答を提供してください。
あなたは${model}モデルとして、あなた独自の視点と専門性を活かした回答をしてください。
EOF

  # tmuxウィンドウで実行（エラーハンドリング付き）
  tmux new-window -t "$TMUX_SESSION" -n "$model" \
    "if cat '$PROMPT_FILE' | claude --model $model --print > '$output_file' 2>&1; then
       echo 'DONE' > '$done_file'
     else
       echo 'ERROR' > '$error_file'
       echo '⚠️ モデル実行中にエラーが発生しました' >> '$output_file'
     fi"

  echo "  ✓ $model 実行開始"
done

echo ""
echo "⏳ 完了を待機中..."

# 完了待機（タイムアウト付き）
start_time=$(date +%s)
while true; do
  all_done=true
  completed_count=0

  for model in "${MODEL_ARRAY[@]}"; do
    if [[ -f "$WORK_DIR/${model}.done" ]]; then
      ((completed_count++))
    elif [[ -f "$WORK_DIR/${model}.error" ]]; then
      ((completed_count++))
    else
      all_done=false
    fi
  done

  # 進捗表示
  total_count=${#MODEL_ARRAY[@]}
  echo -ne "\r  進捗: ${completed_count}/${total_count} モデル完了"

  if $all_done; then
    echo ""
    echo ""
    echo "✓ 全モデルの実行が完了しました"
    break
  fi

  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  if [[ $elapsed -gt $TIMEOUT ]]; then
    echo ""
    echo ""
    echo "⚠️ タイムアウト: 一部のモデルが完了しませんでした"

    for model in "${MODEL_ARRAY[@]}"; do
      if [[ ! -f "$WORK_DIR/${model}.done" ]] && [[ ! -f "$WORK_DIR/${model}.error" ]]; then
        echo "   - $model: 未完了"
        echo "⚠️ タイムアウトにより実行が中断されました" > "$WORK_DIR/${model}.md"
        echo "ERROR" > "$WORK_DIR/${model}.error"
      fi
    done
    break
  fi

  sleep 2
done

# tmuxセッションクリーンアップ
tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

echo ""
echo "📁 作業ディレクトリ: $WORK_DIR"
echo ""
