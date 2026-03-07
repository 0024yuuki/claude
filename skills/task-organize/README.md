# task-organize

Googleカレンダーから今月のイベントを取得し、タスクを整理してGitHub Issueに登録するスキル。

## トリガー

「タスクを整理して」または `/task-organize`

## フロー

1. **カレンダー取得** — Google Calendar MCPで今月のイベントを一覧表示
2. **重複チェック** — `0024yuuki/todo` の既存Issueと照合
3. **タスク選択** — 番号入力でIssue化したいイベントを選択（「全部」も可）
4. **Issue情報の生成** — ラベル（priority/category）とサブタスクを自動提案
5. **確認** — 内容をプレビューして承認
6. **GitHub Issue作成** — `0024yuuki/todo` リポジトリに一括登録

## ラベル付けルール

| 条件 | ラベル |
|------|--------|
| 仕事・面談 | `work` + `priority: high` |
| プライベート重要（締切あり） | `personal` + `priority: high` |
| 通常のイベント | `personal` + `priority: medium` |
| 詳細未確定 | `personal` + `priority: low` |

## インストール

```
cp instructions.md ~/.claude/commands/task-organize.md
```

## 依存関係

- Google Calendar MCP (`mcp__google-calendar__*` または `mcp__claude_ai_Google_Calendar__*`)
- GitHub CLI (`gh`)
- 対象リポジトリ: `0024yuuki/todo`
