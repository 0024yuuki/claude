# second-opinion プラグイン

Claude Opus によるコードレビュー（セカンドオピニオン）を提供するコマンドプラグイン。
複数モデル並列比較から Opus 専用シンプル版に刷新（2026-06-27）。

## 使用法

```
/second-opinion              # プッシュ予定の差分をレビュー
/second-opinion --staged     # ステージ済み変更のみ
/second-opinion --last       # 最終コミットのみ
```

## 動作

1. git diff で変更差分を取得
2. Claude Opus (`claude-opus-4-8`) にパイプして詳細レビューを依頼
3. バグ・セキュリティ・コード品質・改善提案を日本語で報告

## 自動フックとの違い

| 方法 | 発動 | 用途 |
|------|------|------|
| `/second-opinion` | 手動 | 任意のタイミングでオンデマンドレビュー |
| PreToolUse hook | 自動（git push 前） | push 直前の最終チェック |
| PostToolUse hook | 自動（プラン承認後） | プランの品質チェック |

## ファイル構造

```
plugins/second-opinion/
├── .claude-plugin/plugin.json
├── README.md
└── commands/second-opinion.md
```

## インストール

```bash
# グローバルコマンドとして配置
cp plugins/second-opinion/commands/second-opinion.md ~/.claude/commands/

# フックも合わせて設定（hooks/ ディレクトリを参照）
cp hooks/opus-push-review.sh ~/.claude/hooks/
cp hooks/opus-plan-review.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

`~/.claude/settings.json` に hooks セクションを追加することを忘れずに（`settings/settings.template.json` 参照）。
