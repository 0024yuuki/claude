---
description: "Run second opinion with multiple Claude models"
argument-hint: "[models] [--turns N] [--timeout SECONDS]"
allowed-tools:
  - "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*:*)"
  - "Write(/tmp/*:*)"
  - "Read(/tmp/*:*)"
---

# Second Opinion Command

複数のClaude モデルで並列実行して意見を比較します。

## 使用法

```bash
/second-opinion [models] [--turns N] [--timeout SECONDS]
```

### オプション引数

- `models`: カンマ区切りのモデルリスト（デフォルト: `sonnet,opus,haiku`）
  - 例: `sonnet,opus` （2モデルのみ）
  - 例: `haiku` （単一モデル）

- `--turns N`: 会話履歴のターン数（デフォルト: 5）
  - 例: `--turns 3` （最新3ターンのみ）

- `--timeout SECONDS`: タイムアウト秒数（デフォルト: 300）
  - 例: `--timeout 600` （10分）

## 使用例

### 基本的な使用（デフォルト設定）

```
/second-opinion
```

→ Sonnet、Opus、Haikuの3モデルで最新5ターンを比較

### モデルを指定

```
/second-opinion sonnet,opus
```

→ SonnetとOpusの2モデルのみで比較（高速化）

### ターン数を変更

```
/second-opinion --turns 3
```

→ 最新3ターンのみで比較

### タイムアウトを延長

```
/second-opinion --timeout 600
```

→ タイムアウトを10分に延長

### 複数オプションを組み合わせ

```
/second-opinion sonnet,haiku --turns 3 --timeout 180
```

→ SonnetとHaikuで最新3ターンを比較（タイムアウト3分）

## 実装

以下の手順で実行します：

### 引数のパース

```bash
# デフォルト値
MODELS="sonnet,opus,haiku"
TURNS=5
TIMEOUT=300

# 引数を処理
ARGS=("$@")
for arg in "${ARGS[@]}"; do
  case "$arg" in
    --turns)
      shift
      TURNS="$1"
      shift
      ;;
    --timeout)
      shift
      TIMEOUT="$1"
      shift
      ;;
    --turns=*)
      TURNS="${arg#*=}"
      ;;
    --timeout=*)
      TIMEOUT="${arg#*=}"
      ;;
    *)
      # モデルリストとして解釈
      if [[ "$arg" =~ ^[a-z,]+$ ]]; then
        MODELS="$arg"
      fi
      ;;
  esac
done
```

### Step 1: 会話履歴の抽出

```bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
CONTEXT_FILE="/tmp/second-opinion-context-$$.txt"

"${PLUGIN_ROOT}/scripts/extract-context.sh" "$TURNS" "$CONTEXT_FILE"

if [[ ! -f "$CONTEXT_FILE" ]] || [[ ! -s "$CONTEXT_FILE" ]]; then
  echo "❌ エラー: 会話履歴の抽出に失敗しました"
  exit 1
fi
```

### Step 2: 並列実行

```bash
# 最後の行に作業ディレクトリのパスが出力される
OUTPUT=$("${PLUGIN_ROOT}/scripts/run-parallel-models.sh" "$CONTEXT_FILE" "$MODELS" "$TIMEOUT" 2>&1)
WORK_DIR=$(echo "$OUTPUT" | grep "^/tmp/second-opinion-" | tail -1)

if [[ -z "$WORK_DIR" ]] || [[ ! -d "$WORK_DIR" ]]; then
  echo "❌ エラー: 並列実行に失敗しました"
  echo "$OUTPUT"
  exit 1
fi
```

### Step 3: 結果収集と表示

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 各モデルの回答"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

"${PLUGIN_ROOT}/scripts/collect-results.sh" "$WORK_DIR"
```

### Step 4: 自動比較分析

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 自動比較分析"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

"${PLUGIN_ROOT}/scripts/analyze-comparison.sh" "$WORK_DIR"
```

### Step 5: クリーンアップ

```bash
echo ""
echo "🗑️  作業ディレクトリを削除しますか？ [y/N]"
read -r response
if [[ "$response" =~ ^[Yy] ]]; then
  rm -rf "$WORK_DIR"
  echo "✓ クリーンアップ完了"
else
  echo "📁 結果は以下に保存されています: $WORK_DIR"
fi
```

## 出力形式

### 1. 実行サマリー

| モデル | 状態 | 特徴 |
|--------|------|------|
| Sonnet | ✓ 完了 | バランス型、詳細な説明 |
| Opus   | ✓ 完了 | 高精度、包括的分析 |
| Haiku  | ✓ 完了 | 高速、簡潔で実用的 |

### 2. 各モデルの回答

見出しで区切って、各モデルの完全な回答を表示します。

### 3. 比較分析

Claude Sonnetによる統合分析：
- **共通する推奨事項**: 全モデルが一致している内容
- **モデル間の相違点**: アプローチ、詳細度、リスク評価の違い
- **各モデルの特徴**: 独自の視点や提案
- **総合評価**: 最も信頼性が高い回答と推奨アクション

## エラーハンドリング

### tmux未インストール

```
❌ エラー: tmuxがインストールされていません
   インストールコマンド: sudo yum install tmux
```

### 会話履歴が空

```
❌ エラー: 会話履歴の抽出に失敗しました
```

→ 会話が開始されていない、またはtranscriptファイルが見つかりません

### タイムアウト

```
⚠️ タイムアウト: 一部のモデルが完了しませんでした
   - opus: 未完了
```

→ 完了したモデルの結果のみを表示し、分析を実行します

### モデル実行エラー

```
⚠️ モデル実行中にエラーが発生しました
```

→ APIエラーやレート制限の可能性があります。時間を空けて再実行してください。

## パフォーマンス

### 実行時間の目安

- **3モデル並列実行**: 約30-120秒（会話長による）
- **2モデル並列実行**: 約20-90秒
- **単一モデル**: 約15-60秒

### コスト効率化

コストを抑えたい場合：
1. ターン数を減らす（`--turns 3`）
2. モデル数を減らす（`sonnet,haiku`で中速+高速の組み合わせ）
3. 重要な判断のみに使用

## 関連スキル

- `multi-model-comparison`: 自然言語トリガー版（「セカンドオピニオンして」）
  - このコマンドと同じ機能を自然な会話で起動できます

## 参考資料

- `skills/multi-model-comparison/SKILL.md`: スキル版の詳細
- `skills/multi-model-comparison/references/model-profiles.md`: モデル特性の詳細
