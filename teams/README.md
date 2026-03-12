# Teams

Claude Code のエージェントチーム定義を管理するディレクトリです。

## 概要

各チームは以下の2種類のファイルで構成されます：

- **`team.json`** — チームの構成定義（メンバー・役割・ワークフロー）
- **`prompts/*.md`** — 各エージェントへの指示プロンプト

> **注意**: `~/.claude/teams/` に生成される `config.json` はセッション固有の情報（`agentId`、`joinedAt` 等）を含むため git 管理しません。このディレクトリには再利用可能な定義のみを保存します。

## チーム一覧

| チーム名 | 説明 |
|---|---|
| [code-review](./code-review/) | コードレビュー専門チーム（セキュリティ・パフォーマンス・テスト） |

## 使い方

### チームを起動する

```
TeamCreate で team_name を指定してチームを作成し、
各エージェントの prompts/*.md を読み込んで Agent ツールでスポーンする。
```

### ワークフロー例（code-review）

```
review-lead → [security-reviewer, performance-reviewer, test-reviewer] (並列)
                          ↓ 全員完了
                     review-lead → 統合レポートをユーザーに報告
```

## 新しいチームを追加する

```
teams/
└── your-team-name/
    ├── team.json           # チーム定義
    └── prompts/
        ├── agent-1.md      # 各エージェントのプロンプト
        └── agent-2.md
```
