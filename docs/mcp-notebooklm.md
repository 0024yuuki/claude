# NotebookLM MCP セットアップ

## 概要

`notebooklm-mcp-cli` v0.7.7 を Claude Code CLI の MCP サーバーとして登録。
Claude Code から NotebookLM のノートブック操作（作成・検索・ソース追加・ポッドキャスト生成等）が自然言語で可能になる。

**ソース**: https://github.com/jacob-bd/notebooklm-mcp-cli  
**注意**: 非公式の内部 API を使用。Google の仕様変更で動作しなくなる可能性あり。

---

## インストール手順

```bash
# 1. uv インストール
brew install uv

# 2. notebooklm-mcp-cli インストール
uv tool install notebooklm-mcp-cli

# 3. PATH に追加（~/.zshrc に追記）
export PATH="$HOME/.local/bin:$PATH"

# 4. Google アカウント認証（手動クッキーインポート）
#    Chrome で notebooklm.google.com を開き、DevTools の Network タブから
#    任意リクエストの "cookie:" ヘッダー値をコピーしてファイルに保存
nlm login --manual --file /path/to/cookies.txt

# 認証確認
nlm login --check

# 5. Claude Code に MCP 登録（フルパス指定が必要）
claude mcp add --scope user notebooklm-mcp /Users/onishiyuki/.local/bin/notebooklm-mcp
```

---

## 設定ファイル

MCP 設定は `~/.claude.json` の `mcpServers` セクションに保存される（`settings.json` ではない）。

認証情報: `~/.notebooklm-mcp-cli/profiles/default`

---

## 重要な注意事項

- `nlm setup add claude-code` は Claude Desktop 向けのコマンドで、Claude Code CLI には効かない
- `~/.local/bin` を PATH に追加しないと `nlm` コマンドが使えない（`claude mcp add` にはフルパス指定が必要）
- クッキー認証は自動ログイン（Chrome DevTools Protocol）が macOS では失敗しやすい → 手動インポートが確実
- クッキーは **2〜4週間で失効** → 定期的に `nlm login --manual` で再認証が必要

---

## 利用可能な MCP ツール（39個）

| 機能 | ツール名 |
|------|---------|
| ノートブック一覧 | `notebook_list` |
| ノートブック作成 | `notebook_create` |
| ソース追加 | `source_add` |
| ノートブック検索 | `notebook_query` |
| ポッドキャスト生成 | `studio_create` |
| ダウンロード | `download_artifact` |
| クロスノートブック検索 | `cross_notebook_query` |

詳細: `nlm --help` または `nlm --ai`
