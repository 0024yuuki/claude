# Claude Code Configuration Repository

Claude Code の設定・フック・コマンドを Git 管理し、`install.sh` で `~/.claude` に
**symlink** として反映するためのリポジトリ。手動 `cp` によるドリフトを排除する。

## 📁 構成

```
claude/
├── install.sh            symlink 一括作成スクリプト（冪等・--check/--dry-run 対応）
├── macos/                この Mac 用（~/.claude へ symlink される）
│   ├── settings.json     設定マスター（機密なし。差分表示のみ、symlink はしない）
│   ├── CLAUDE.md         グローバル CLAUDE.md（宣言ルール）
│   ├── hooks/            opus-plan-review.sh / opus-push-review.sh
│   └── commands/         second-opinion.md / task-organize.md
├── lab-linux/            Linux ラボ共有サーバー専用（macOS では動作しない）
│   └── hooks/            safety-check / path-guard / conventions / session-context
├── teams/                エージェントチーム定義（code-review / oitoma-blog）
├── docs/                 セットアップ・MCP ドキュメント
└── CHANGELOG.md
```

> **重要**: `macos/` と `lab-linux/` は別マシン向け。混在させない。
> このリポジトリはかつて両者を無差別に混ぜており、Linux 専用フックを macOS に
> 適用しようとして破綻していた（2026-07 に分離）。

## 🔧 含まれるもの

### macOS 用フック（`macos/hooks/`）
- **opus-push-review.sh** — `git push` 前に Opus がコード差分をレビュー（PreToolUse:Bash・通知型）
- **opus-plan-review.sh** — プラン承認後に Opus がプランをレビュー（PostToolUse:ExitPlanMode）

### macOS 用コマンド（`macos/commands/`）
- **/second-opinion** — Opus によるオンデマンドコードレビュー（`--staged` / `--last`）
- **/task-organize** — Google カレンダー → GitHub Issue 変換

### Linux ラボ用フック（`lab-linux/hooks/`）
研究室の共有計算サーバー（SGE・conda・`/home/yuki0024/`）専用。詳細は
[lab-linux/README.md](lab-linux/README.md)。

## 📦 セットアップ（この Mac）

```bash
# クローン
gh repo clone 0024yuuki/claude ~/claude
cd ~/claude

# 差分確認（変更しない）
./install.sh --check

# symlink を反映（既存実体は ~/.claude/backups/ へ自動退避）
./install.sh
```

`settings.json` は symlink せず、`macos/settings.json` をマスターとして
`install.sh` が差分表示するのみ（個人トークン等の誤 push を避けるため手動反映）。

## 🔄 同期の考え方

- フックやコマンドを編集 → `macos/` 配下を直接編集すれば **symlink 経由で即反映**。
- 実環境を触ってしまった場合 → `./install.sh --check` でドリフト検知、`./install.sh` で復元。

## ⚠️ セキュリティ

`.gitignore` で認証情報・会話履歴・`*.local.json` を除外。以下は**絶対に含めない**:
- 認証情報（`credentials.json`, `*.key`, `*.pem`）
- 会話履歴・セッションデータ（`history.jsonl`, `projects/`, `plans/`）

## 🔗 関連

- [docs/setup.md](docs/setup.md) — 詳細セットアップ
- [docs/mcp-notebooklm.md](docs/mcp-notebooklm.md) — NotebookLM MCP
- [Claude Code 公式ドキュメント](https://github.com/anthropics/claude-code)
