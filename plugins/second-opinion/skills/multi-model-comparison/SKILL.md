---
name: multi-model-comparison
description: This skill should be used when the user asks to "セカンドオピニオンして", "複数のモデルで確認", "他のモデルの意見", "second opinion", or wants to compare responses from different Claude models. Activate when critical decisions or architectural choices need validation from multiple model perspectives.
version: 1.0.0
allowed-tools:
  - "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*:*)"
  - "Write(/tmp/*:*)"
  - "Read(/tmp/*:*)"
---

# Multi-Model Comparison Skill

このスキルは、複数のClaude モデル（Sonnet、Opus、Haiku）で同じ質問に対する回答を並列実行して比較します。

## 実行フロー

1. **会話履歴の抽出**
   - 最新5ターンの会話を`.jsonl` transcriptから抽出
   - user/assistantメッセージのみを対象

2. **並列実行**
   - tmuxを使用して3モデルを真に並列実行
   - 各モデルは独立したプロセスで実行
   - タイムアウト: 300秒（5分）

3. **結果収集**
   - 各モデルの回答をマークダウン形式で整形
   - エラー状態も適切に表示

4. **自動比較分析**
   - Claude Sonnetで全回答を統合分析
   - 共通点、相違点、推奨事項を抽出

## 使用方法

ユーザーが以下のようなフレーズを使った場合、このスキルを起動してください：
- "セカンドオピニオンして"
- "他のモデルの意見も聞きたい"
- "複数のモデルで確認して"
- "second opinion"

## 実装

以下の手順で実行します：

### Step 1: 会話履歴の抽出

```bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
CONTEXT_FILE="/tmp/second-opinion-context-$$.txt"

"${PLUGIN_ROOT}/scripts/extract-context.sh" 5 "$CONTEXT_FILE"
```

### Step 2: 並列実行

```bash
WORK_DIR=$("${PLUGIN_ROOT}/scripts/run-parallel-models.sh" "$CONTEXT_FILE" "sonnet,opus,haiku" 300 | tail -1)
```

**重要:** このステップでは対話的な確認プロンプトが表示されます。ユーザーに実行の確認を求めてください。

### Step 3: 結果収集と表示

```bash
"${PLUGIN_ROOT}/scripts/collect-results.sh" "$WORK_DIR"
```

### Step 4: 自動比較分析

```bash
"${PLUGIN_ROOT}/scripts/analyze-comparison.sh" "$WORK_DIR"
```

### Step 5: クリーンアップ（オプション）

必要に応じて作業ディレクトリを削除：

```bash
rm -rf "$WORK_DIR"
```

## エラーハンドリング

- tmux未インストール: エラーメッセージを表示し、インストール方法を案内
- タイムアウト: 完了したモデルの結果のみを表示
- モデル実行エラー: エラー状態を明示し、他のモデルの結果を表示

## 出力形式

### 実行サマリー（テーブル形式）
| モデル | 状態 | 特徴 |
|--------|------|------|
| Sonnet | ✓ 完了 | バランス型、詳細な説明 |
| Opus   | ✓ 完了 | 高精度、包括的分析 |
| Haiku  | ✓ 完了 | 高速、簡潔で実用的 |

### 各モデルの回答（セクション分け）

各モデルの回答を見出しで区切って表示します。

### 比較分析

Claude Sonnetによる自動分析結果：
- 共通する推奨事項
- モデル間の主要な相違点
- 各モデルの特徴的な視点
- 総合評価と推奨アクション

## カスタマイズ

### モデルの選択

デフォルトは`sonnet,opus,haiku`の3モデルですが、以下のように変更可能：

```bash
# Sonnet + Opusのみ（高速化）
"${PLUGIN_ROOT}/scripts/run-parallel-models.sh" "$CONTEXT_FILE" "sonnet,opus" 300
```

### ターン数の変更

デフォルトは5ターンですが、変更可能：

```bash
# 最新3ターンのみ
"${PLUGIN_ROOT}/scripts/extract-context.sh" 3 "$CONTEXT_FILE"
```

### タイムアウトの変更

デフォルトは300秒（5分）ですが、変更可能：

```bash
# 10分に延長
"${PLUGIN_ROOT}/scripts/run-parallel-models.sh" "$CONTEXT_FILE" "sonnet,opus,haiku" 600
```

## 参考資料

詳細なモデル特性については、以下を参照：
- `references/model-profiles.md`: 各モデルの詳細な特性と使い分け

## トラブルシューティング

### tmuxが見つからない

```bash
sudo yum install tmux
```

### タイムアウトが頻発する場合

- ターン数を減らす（5 → 3）
- タイムアウトを延長（300 → 600秒）
- モデル数を減らす（3 → 2モデル）

### API レート制限

3モデルの同時実行でレート制限に到達する場合：
- モデル数を減らして2回に分けて実行
- 時間を空けて再実行
