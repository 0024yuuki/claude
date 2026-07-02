# グローバル Claude Code 設定

全プロジェクト・全セッション共通のルール。プロジェクト固有の CLAUDE.md がある場合はそちらが優先される。

## 自動 Opus レビュー（hooks）

以下のタイミングで自動的に Claude Opus がレビューを実行する：

| タイミング | フック種別 | 目的 |
|-----------|-----------|------|
| プラン承認後（ExitPlanMode） | PostToolUse | プランの問題・リスク検出 |
| git push 実行前（Bash） | PreToolUse | コード差分のレビュー（通知のみ・ブロックなし） |

## スラッシュコマンド

| コマンド | 説明 |
|---------|------|
| `/second-opinion` | Opus によるオンデマンドコードレビュー |
| `/second-opinion --staged` | ステージ済み変更のみレビュー |
| `/second-opinion --last` | 最終コミットのみレビュー |
| `/task-organize` | Google カレンダー → GitHub Issue 変換 |

## フック設定場所

- `~/.claude/hooks/opus-push-review.sh` — PreToolUse:Bash（git push 検出）
- `~/.claude/hooks/opus-plan-review.sh` — PostToolUse:ExitPlanMode
- 設定登録: `~/.claude/settings.json` の `hooks` セクション

## リポジトリ

設定のバージョン管理: `https://github.com/0024yuuki/claude`（ローカル: `~/claude/`）
