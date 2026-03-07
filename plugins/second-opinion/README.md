# Second Opinion Plugin

複数のClaude モデル（Sonnet、Opus、Haiku）で同じ質問に対する回答を並列実行して比較する強力なプラグインです。

## 概要

重要な技術的判断や設計決定を行う際、単一のモデルの意見だけでなく、複数のモデルの視点を比較することで、より信頼性の高い結論を導くことができます。このプラグインは、tmuxを使った真の並列実行により、3つのClaude モデルを同時に起動し、それぞれの回答を自動的に比較分析します。

## 主な機能

- ✅ **真の並列実行**: tmuxを使用して3モデルを独立したプロセスで同時実行
- ✅ **自動比較分析**: Claude Sonnetが全回答を統合分析し、共通点・相違点を抽出
- ✅ **自然言語トリガー**: 「セカンドオピニオンして」という日本語で起動可能
- ✅ **明示的コマンド**: `/second-opinion`コマンドでオプション指定も可能
- ✅ **エラーハンドリング**: タイムアウト、APIエラーにも対応
- ✅ **カスタマイズ可能**: モデル選択、ターン数、タイムアウトを調整可能

## 利用シーン

### いつ使うべきか

- **アーキテクチャ設計の妥当性確認**: 設計の選択肢が複数ある場合
- **セキュリティやパフォーマンスに関わる判断**: リスクが高い決定の前に
- **デバッグで原因特定が困難な場合**: 異なる視点からの分析が必要な時
- **複数の実装アプローチの評価**: トレードオフを理解したい時

### いつ使わないべきか

- **単純な事実確認**: 1つのモデルで十分な場合
- **時間制約が厳しい**: 並列実行でも30-120秒かかります
- **コストを最小化したい**: 3モデル実行はトークン消費が3倍になります

## インストール

このプラグインは既に `~/.claude/plugins/second-opinion/` にインストールされています。

### 依存関係

- **tmux**: 並列実行に必須

```bash
# CentOS/RHEL
sudo yum install tmux

# Ubuntu/Debian
sudo apt-get install tmux

# macOS
brew install tmux
```

- **jq**: JSONLパースに使用

```bash
# CentOS/RHEL
sudo yum install jq

# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

- **Claude Code CLI**: 既にインストール済み

## 使用方法

### 方法1: 自然言語トリガー（推奨）

会話中に以下のフレーズを使うだけで、自動的にスキルが起動します：

```
User: Pythonでファイルを読み込む最良の方法は？
Assistant: [回答...]

User: セカンドオピニオンして
```

→ 自動的に3モデルで並列実行し、比較分析が開始されます。

**トリガーフレーズ:**
- "セカンドオピニオンして"
- "他のモデルの意見も聞きたい"
- "複数のモデルで確認して"
- "second opinion"

### 方法2: 明示的コマンド

オプションを指定して実行する場合は、コマンドを使用します：

```
/second-opinion
```

**オプション付き:**

```
# 2モデルのみで高速化
/second-opinion sonnet,opus

# 最新3ターンのみで比較
/second-opinion --turns 3

# タイムアウトを10分に延長
/second-opinion --timeout 600

# 複数オプションを組み合わせ
/second-opinion sonnet,haiku --turns 3 --timeout 180
```

## 出力例

### 1. 実行サマリー

```markdown
## 実行サマリー

| モデル | 状態 | 特徴 |
|--------|------|------|
| Sonnet | ✓ 完了 | バランス型、詳細な説明 |
| Opus   | ✓ 完了 | 高精度、包括的分析 |
| Haiku  | ✓ 完了 | 高速、簡潔で実用的 |
```

### 2. 各モデルの回答

各モデルの完全な回答が見出しで区切られて表示されます。

### 3. 比較分析

Claude Sonnetによる自動分析：

```markdown
## 🔍 比較分析

### 共通する推奨事項
- [全モデルが一致している重要なポイント]

### モデル間の主要な相違点
- **アプローチの違い**: [...]
- **詳細度の比較**: [...]

### 各モデルの特徴的な視点
- **Sonnet**: [...]
- **Opus**: [...]
- **Haiku**: [...]

## 💡 総合評価

### 最も信頼性が高い回答
[評価と理由]

### 推奨アクション
1. [具体的なステップ]
2. [...]
```

## モデルの特性

### Claude Sonnet 4.5
- **特徴**: バランス型、詳細な説明
- **強み**: 実装の詳細と理論のバランスが良い
- **適した場面**: 一般的な開発タスク、説明が必要な場面

### Claude Opus 4.6
- **特徴**: 高精度、包括的分析
- **強み**: 複雑な問題の深い分析、エッジケースの考慮
- **適した場面**: アーキテクチャ設計、セキュリティ評価

### Claude Haiku 4.5
- **特徴**: 高速、簡潔で実用的
- **強み**: 明確で実装に直結する提案
- **適した場面**: 迅速な判断が必要な場面、プロトタイピング

詳細は `skills/multi-model-comparison/references/model-profiles.md` を参照してください。

## カスタマイズ

### モデルの選択

デフォルトは3モデルですが、用途に応じて変更可能：

| 組み合わせ | 実行時間 | コスト | 用途 |
|-----------|---------|-------|------|
| sonnet,opus,haiku | 長い | 高い | 重要な判断、包括的分析 |
| sonnet,opus | 中程度 | 中程度 | 高品質な分析、コスト削減 |
| sonnet,haiku | 短い | 低い | バランスと速度の両立 |
| opus | 短い | 低い | 高精度な単一回答 |

### ターン数の調整

| ターン数 | 実行時間 | 用途 |
|---------|---------|------|
| 3 | 最速 | 直近の質問のみ比較 |
| 5 (デフォルト) | 標準 | 十分なコンテキスト |
| 10 | 遅い | 長い会話の全体を考慮 |

### タイムアウトの調整

| タイムアウト | 用途 |
|------------|------|
| 180秒 (3分) | 短い質問、高速化 |
| 300秒 (5分) (デフォルト) | 標準的な質問 |
| 600秒 (10分) | 複雑な質問、長い会話 |

## トラブルシューティング

### tmuxが見つからない

**エラー:**
```
❌ エラー: tmuxがインストールされていません
```

**解決策:**
```bash
sudo yum install tmux
```

### タイムアウトが頻発する

**原因:**
- 会話履歴が長すぎる
- ネットワークが遅い
- モデルの応答が遅い

**解決策:**
1. ターン数を減らす: `/second-opinion --turns 3`
2. タイムアウトを延長: `/second-opinion --timeout 600`
3. モデル数を減らす: `/second-opinion sonnet,opus`

### API レート制限エラー

**エラー:**
```
⚠️ モデル実行中にエラーが発生しました
```

**原因:**
3モデルの同時実行でAPIのレート制限に到達

**解決策:**
1. 時間を空けて再実行
2. モデル数を減らして2回に分けて実行
3. ターン数を減らしてトークン消費を削減

### 会話履歴が抽出できない

**エラー:**
```
❌ エラー: Transcriptファイルが見つかりません
```

**原因:**
- 会話が開始されていない
- transcriptファイルのパスが異なる

**解決策:**
1. 新しいセッションを開始して数ターン会話してから実行
2. transcriptファイルの場所を確認:
   ```bash
   ls -lt ~/.claude/projects/-home-yuki0024/*.jsonl
   ```

## パフォーマンス

### 実行時間の目安

| シナリオ | 時間 |
|---------|------|
| 3モデル × 5ターン | 30-120秒 |
| 2モデル × 5ターン | 20-90秒 |
| 3モデル × 3ターン | 20-80秒 |
| 1モデル × 5ターン | 15-60秒 |

※ 会話の長さとモデルの応答速度により変動

### トークン消費

3モデル実行は、単一モデルの **約3倍** のトークンを消費します。

**コスト効率化のヒント:**
- 重要な判断のみに使用
- ターン数を最小限に（`--turns 3`）
- モデル数を減らす（`sonnet,haiku`）

## ファイル構造

```
~/.claude/plugins/second-opinion/
├── .claude-plugin/
│   └── plugin.json                      # プラグインメタデータ
├── README.md                            # このファイル
├── commands/
│   └── second-opinion.md                # /second-opinion コマンド定義
├── skills/
│   └── multi-model-comparison/
│       ├── SKILL.md                     # メインスキル
│       └── references/
│           └── model-profiles.md        # モデル特性リファレンス
└── scripts/
    ├── extract-context.sh               # 会話履歴抽出
    ├── run-parallel-models.sh           # tmux並列実行
    ├── collect-results.sh               # 結果収集
    └── analyze-comparison.sh            # 自動比較分析
```

## 開発者向け

### スクリプトの個別実行

各スクリプトは独立して実行可能です：

```bash
# 会話履歴抽出
~/.claude/plugins/second-opinion/scripts/extract-context.sh 5 /tmp/context.txt

# 並列実行
~/.claude/plugins/second-opinion/scripts/run-parallel-models.sh /tmp/context.txt "sonnet,opus" 300

# 結果収集
~/.claude/plugins/second-opinion/scripts/collect-results.sh /tmp/second-opinion-12345

# 比較分析
~/.claude/plugins/second-opinion/scripts/analyze-comparison.sh /tmp/second-opinion-12345
```

### デバッグ

作業ディレクトリは `/tmp/second-opinion-<PID>` に作成されます。

**確認方法:**
```bash
# 最新の作業ディレクトリを確認
ls -lt /tmp/second-opinion-* | head -1

# 内容を確認
ls -lah /tmp/second-opinion-12345/
# → sonnet.md, opus.md, haiku.md
# → sonnet.done, opus.done, haiku.done
# → sonnet_prompt.txt, ...
```

### カスタマイズ

スクリプトは全て Bash で記述されており、容易にカスタマイズ可能です：

- **extract-context.sh**: 抽出ロジックの変更
- **run-parallel-models.sh**: 並列実行方法の変更
- **collect-results.sh**: 出力フォーマットの変更
- **analyze-comparison.sh**: 分析プロンプトの調整

## ライセンス

このプラグインはオープンソースです。自由に改変・配布してください。

## バージョン

- **Version**: 1.0.0
- **Last Updated**: 2026-03-07

## サポート

問題が発生した場合や改善提案がある場合は、以下を確認してください：

1. このREADMEのトラブルシューティングセクション
2. `skills/multi-model-comparison/SKILL.md` の詳細ドキュメント
3. スクリプトのエラーメッセージとログ

---

**Happy Second-Opinion! 🔍**