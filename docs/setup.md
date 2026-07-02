# セットアップガイド

このリポジトリの設定を `~/.claude` に反映する方法。`macos/`（この Mac）と
`lab-linux/`（研究室 Linux サーバー）で手順が異なる。

## 前提条件
- Claude Code / Git / GitHub CLI (`gh`)

---

## macOS（この Mac）

### 1. クローン
```bash
gh repo clone 0024yuuki/claude ~/claude
cd ~/claude
```

### 2. 差分確認 → symlink 反映
```bash
# 現状のドリフトを確認（何も変更しない）
./install.sh --check

# 反映（既存実体は ~/.claude/backups/install-<日時>/ へ自動退避してから symlink 化）
./install.sh
```

`install.sh` が張る symlink:

| 実環境 | → リポジトリ |
|--------|--------------|
| `~/.claude/hooks/opus-plan-review.sh` | `~/claude/macos/hooks/opus-plan-review.sh` |
| `~/.claude/hooks/opus-push-review.sh` | `~/claude/macos/hooks/opus-push-review.sh` |
| `~/.claude/commands/second-opinion.md` | `~/claude/macos/commands/second-opinion.md` |
| `~/.claude/commands/task-organize.md` | `~/claude/macos/commands/task-organize.md` |
| `~/.claude/CLAUDE.md` | `~/claude/macos/CLAUDE.md` |

### 3. settings.json（手動）
`settings.json` は symlink しない（個人依存の設定を含むため）。
`macos/settings.json` をマスターとし、`install.sh` は差分表示のみ行う。
反映したい場合は内容を確認のうえ手動でコピー:
```bash
diff macos/settings.json ~/.claude/settings.json
cp macos/settings.json ~/.claude/settings.json   # 必要な場合のみ
```

### 4. 動作確認
```bash
ls -la ~/.claude/hooks/      # 2 本が ~/claude/macos/hooks/ を指す symlink
./install.sh --check         # → CHECK OK
```
Claude Code を再起動するとフック・コマンドが有効になる。

---

## Linux ラボ共有サーバー

`lab-linux/hooks/` のフックは SGE・conda・`/home/yuki0024/` を前提とし、
**macOS では動作しない**。該当サーバーでのみ:

```bash
mkdir -p ~/.claude/hooks
cp ~/claude/lab-linux/hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```
その後 `~/.claude/settings.json` の `hooks` に登録する。詳細は
[../lab-linux/README.md](../lab-linux/README.md)。

---

## 同期フロー

### リポジトリ → 実環境
```bash
cd ~/claude && git pull && ./install.sh
```
symlink なのでフック本体の編集は `git pull` だけで反映される（`install.sh` は
symlink 未設定時のみ必要）。

### 実環境 → リポジトリ
`macos/` 配下を直接編集して commit・push。symlink 経由で実環境にも即反映される。

---

## トラブルシューティング

**フックが動かない** → `ls -la ~/.claude/hooks/` で symlink 切れ（`-> ...（赤）`）を確認し
`./install.sh` で貼り直す。実行権限は `chmod +x macos/hooks/*.sh`。

**ドリフトが出る** → `./install.sh --check` で差分箇所を特定。

**設定が反映されない** → Claude Code を再起動。
