# Changelog

Claude Code 設定・カスタマイズの変更履歴。

---

## 2026-08-30

### Added
- **`macos/hooks/strip-quarantine.sh`（Stop フック）を追加**：Obsidian vault 配下から
  `com.apple.quarantine` を自動除去する。
  - **背景**：Claude Code が書いたファイルには macOS の隔離属性が継承され、
    **Obsidian がそのファイルをインデックスしない**。結果、ディスク上には存在するのに
    ファイル一覧に現れず、リンクを踏むと「File already exists」になる。
    発覚時点で **16ファイル**が数週間ぶん埋もれていた。
  - **自力検出できない不具合**である点が問題だった。`Write` は成功を返し、
    `ls` も `git status` も正常（**git は拡張属性を保存しない**）。
    本人が開こうとして初めて発覚する。→ 記録ではなくフックで塞ぐ判断。
  - `com.apple.quarantine` のみを対象とし、`com.apple.provenance` 等には触れない。
    ファイル内容・権限・タイムスタンプは変更しない。常に exit 0。
  - **⚠️ 防げるのは新規の書き込みだけ**。既にインデックスから漏れたファイルは
    Obsidian を `Cmd+Q` で完全終了して再起動する必要がある
    （「Reload app without saving」では不十分）。

### Changed
- **`macos/settings.json` に `hooks.Stop` を追加**（`strip-quarantine.sh`・timeout 20秒）。
  - ⚠️ `settings.json` は symlink されず `install.sh` は差分表示のみのため、
    **`~/.claude/settings.json` 側にも同じ内容を手で入れてある**（二重管理）。

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
