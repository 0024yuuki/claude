---
description: "Googleカレンダーから今月のイベントを取得し、タスクを整理してGitHub Issueに登録する"
allowed-tools:
  - mcp__google-calendar__list-events
  - mcp__google-calendar__get-current-time
  - mcp__claude_ai_Google_Calendar__gcal_list_events
  - mcp__claude_ai_Google_Calendar__gcal_list_calendars
  - Bash(gh issue create:*)
  - Bash(gh issue list:*)
  - Bash(gh label list:*)
  - AskUserQuestion
---

# タスク整理スキル

あなたはタスク管理のアシスタントです。以下の手順でGoogleカレンダーのイベントをGitHub Issueに変換してください。

## 現在の日時

- 今日の日付: !`date '+%Y-%m-%d'`

## Step 1: Googleカレンダーから今月のイベントを取得

利用可能なカレンダーMCPツール（`mcp__google-calendar__list-events` または `mcp__claude_ai_Google_Calendar__gcal_list_events`）を使い、**今月1日〜月末まで**のイベントをすべて取得してください。

取得したら、以下の形式でイベント一覧を表示してください：

```
【今月のカレンダーイベント】

No.  日時              タイトル
---  ----------------  -----------------------
 1   3/7 (火)          車査定
 2   3/8 (水)          Claude解約検討（締切）
...
```

## Step 2: 既存Issueとの重複チェック

以下のコマンドで既存Issueを取得し、重複するイベントはリストから除外（またはその旨を表示）してください：

```
gh issue list --repo 0024yuuki/todo --limit 50 --state open
```

## Step 3: タスク選択

イベント一覧を表示したら、ユーザーに以下を確認してください：

「上記のイベントのうち、GitHub Issueとして登録したいものをカンマ区切りで番号を入力してください（例: 1,3,5）。「全部」と入力すると全件登録します。「スキップ」で終了します。」

## Step 4: 選択されたイベントのIssue情報を生成

選択されたイベントについて、以下のルールでIssue情報を生成してください：

### ラベル選択ルール

**カテゴリラベル（1つ選択）:**
- `work`: 仕事・面談・ミーティング・業務関連
- `personal`: プライベート・個人的な予定・健康・イベント

**優先度ラベル（1つ選択）:**
- `priority: high`: 締切がある・重要な決断・ビジネス関連・エントリー締切
- `priority: medium`: 通常の予定・イベント参加
- `priority: low`: 詳細未確定・任意参加

**ステータスラベル（固定）:**
- `status: todo`

### サブタスク生成ルール

イベントの性質に応じて、実行すべき具体的なサブタスクを3〜5個生成してください。

例：
- 締切系 → 手続き確認・実行・記録
- 面談・ミーティング → 事前準備・当日参加・フォローアップ
- 医療・健康 → 予約確認・書類準備・受診
- 式典・パーティー → 参加確認・準備・会場確認

## Step 5: ユーザー確認

選択したイベントに対して生成したIssue情報（タイトル・ラベル・サブタスク）を一覧表示し、以下を確認してください：

「上記の内容でGitHub Issueを作成してよいですか？（はい/いいえ/修正）」

## Step 6: GitHub Issueの作成

ユーザーが「はい」と答えたら、以下のコマンド形式で各Issueを作成してください：

```
gh issue create --repo 0024yuuki/todo \
  --title "<タイトル>" \
  --body "## タスク\n\n- [ ] <サブタスク1>\n- [ ] <サブタスク2>\n- [ ] <サブタスク3>" \
  --label "<カテゴリ>" --label "<優先度>" --label "status: todo"
```

全件作成後、以下で確認してください：

```
gh issue list --repo 0024yuuki/todo --limit 20
```

## 注意事項

- すでにIssueが存在するイベントは重複登録しない
- イベントの日時情報はIssueタイトルに含める（例: `車査定（3/7）`）
- ラベルは必ず既存のものを使用する（新規作成しない）
- 登録先リポジトリ: `0024yuuki/todo`
