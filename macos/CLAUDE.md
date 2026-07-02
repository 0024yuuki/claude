# グローバル Claude Code 設定

全プロジェクト・全セッション共通のルール。プロジェクト固有の CLAUDE.md があればそちらが優先。

## 自動レビュー

- **プラン承認後**、Opus が自動でプランをレビューする（見落とし・リスク検出）。
- **`git push` 前**、Opus が自動でコード差分をレビューする（通知のみ・ブロックしない）。

## 利用可能なスラッシュコマンド

| コマンド | 用途 |
|---------|------|
| `/second-opinion` | Opus によるオンデマンドコードレビュー（`--staged` / `--last`） |
| `/task-organize` | Google カレンダー → GitHub Issue 変換 |

## 設定の管理

この設定は `github.com/0024yuuki/claude`（ローカル `~/claude/`）で Git 管理され、
`install.sh` により `~/.claude/` へ symlink 反映される。
セットアップ手順・フックの実装場所などの手続きは同リポジトリの `docs/setup.md` を参照。
