# Changelog

Claude Code 設定・カスタマイズの変更履歴。

---

## 2026-06-28

### Added
- **NotebookLM MCP** (`notebooklm-mcp-cli` v0.7.7) を Claude Code に追加
  - `~/.claude.json` に MCP サーバー登録（フルパス: `~/.local/bin/notebooklm-mcp`）
  - `uv` を Homebrew でインストール
  - 手動クッキー認証（Chrome DevTools Network タブ経由）
  - 詳細: [docs/mcp-notebooklm.md](docs/mcp-notebooklm.md)

---

## 2026-06-27

### Added
- **Opus 自動コードレビューフック** を設定
  - `hooks/opus-push-review.sh` — `git push` 前に Opus がコード差分をレビュー（PreToolUse:Bash）
  - `hooks/opus-plan-review.sh` — プラン承認後に Opus がプランをレビュー（PostToolUse:ExitPlanMode）
  - `/second-opinion` スラッシュコマンド（Opus 専用オンデマンドレビュー）
  - グローバル `~/.claude/CLAUDE.md` 新規作成
