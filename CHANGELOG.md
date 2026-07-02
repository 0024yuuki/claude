# Changelog

Claude Code 設定・カスタマイズの変更履歴。

---

## 2026-07-02

### Changed（設定監査に基づく再構成）
- **リポジトリを macos/ と lab-linux/ に分離**。macOS では動作しない Linux ラボ
  共有サーバー専用フック（safety-check/path-guard/conventions/session-context）を
  `lab-linux/hooks/` へ隔離。以前は両マシンの設定が無差別に混在していた。
- **稼働中の設定を `macos/` に集約**（opus フック2本・commands 2本・CLAUDE.md）。
- **`install.sh` を追加**：冪等な symlink 一括反映（`--check` / `--dry-run` 対応、
  既存実体は自動退避）。手動 `cp` によるドリフトを廃止。
- **壊れた `settings/settings.template.json` を削除**し `macos/settings.json` に一本化
  （旧テンプレートは存在しないフックを参照しており適用すると破綻した）。
- **重複していた `plugins/second-opinion/` と `skills/task-organize/` を削除**
  （実運用は commands/*.md 単体のため）。
- **README.md / docs/setup.md を実態に合わせ全面改訂**。
- **グローバル CLAUDE.md を宣言ルール中心に整理**（手続きは docs/setup.md へ移動）。

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
