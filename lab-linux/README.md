# lab-linux — Linux ラボ共有サーバー専用設定

このディレクトリのフックは **macOS ローカル環境では動作しません**。
研究室の Linux 共有計算サーバー（`/home/yuki0024/`、`/home/condauser/`、SGE ジョブスケジューラ、
conda 環境）を前提に書かれています。

## フック一覧

| フック | イベント | 役割 |
|--------|----------|------|
| `safety-check.sh` | PreToolUse:Bash | sudo / apt / conda base 変更など共有環境を壊す操作をブロック |
| `path-guard.sh` | PreToolUse:Write\|Edit | 書き込み先を `/home/yuki0024/`, `/data2/yuki0024/`, `/tmp/` に限定 |
| `conventions.sh` | PreToolUse:Write\|Edit | 拡張子別に R/SGE/conda のコーディング規約を context 注入 |
| `session-context.sh` | SessionStart | QIIME2/GTDB-Tk 等のツール・データフロー参照表を注入 |

## セットアップ（該当 Linux サーバーでのみ実行）

```bash
mkdir -p ~/.claude/hooks
cp ~/claude/lab-linux/hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

その後 `~/.claude/settings.json` の `hooks` セクションに各フックを登録する
（macOS 用の `macos/settings.json` とは別管理）。
