#!/usr/bin/env bash
#
# install.sh — macOS 用 Claude Code 設定を ~/.claude に symlink で反映する（冪等）
#
# 使い方:
#   ./install.sh            実際に symlink を張る（既存実体はバックアップ）
#   ./install.sh --dry-run  何をするか表示するだけ（変更しない）
#   ./install.sh --check    実環境とリポジトリの差分を検知（CI/定期確認用）
#
# 対象は macos/ 配下のみ。lab-linux/ は Linux ラボサーバーで別途手動セットアップする。
# settings.json は機密（個人トークン等が混入しうる）を避けるため symlink せず、
# macos/settings.json をマスターとして差分表示のみ行う（コピーは手動判断）。

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACOS_DIR="$REPO_DIR/macos"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups/install-$(date +%Y%m%d-%H%M%S)"

MODE="install"
case "${1:-}" in
  --dry-run) MODE="dry-run" ;;
  --check)   MODE="check" ;;
  "")        MODE="install" ;;
  *) echo "unknown option: $1" >&2; exit 64 ;;
esac

# symlink 対象（macos/ からの相対パス）
LINKS=(
  "hooks/opus-plan-review.sh"
  "hooks/opus-push-review.sh"
  "commands/second-opinion.md"
  "commands/task-organize.md"
  "CLAUDE.md"
)

RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; RST=$'\033[0m'
drift=0

backup_once() {
  # $1 = 退避したい実体パス
  mkdir -p "$BACKUP_DIR/$(dirname "${1#$CLAUDE_DIR/}")"
  cp -R "$1" "$BACKUP_DIR/${1#$CLAUDE_DIR/}"
}

link_one() {
  local rel="$1"
  local src="$MACOS_DIR/$rel"
  local dst="$CLAUDE_DIR/$rel"

  if [ ! -e "$src" ]; then
    echo "${YLW}skip${RST}  $rel  (リポジトリ側に無し: $src)"
    return
  fi

  # 既に正しい symlink → 冪等でスキップ
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "${GRN}ok${RST}    $rel  (既に正しい symlink)"
    return
  fi

  case "$MODE" in
    check)
      echo "${RED}drift${RST} $rel  (symlink 未設定 or ずれ)"
      drift=1
      return
      ;;
    dry-run)
      echo "would-link $rel -> $src"
      [ -e "$dst" ] && [ ! -L "$dst" ] && echo "           （既存実体を $BACKUP_DIR へ退避予定）"
      return
      ;;
  esac

  # install 本番
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ ! -L "$dst" ]; then
      backup_once "$dst"
      echo "       （既存実体を退避: $BACKUP_DIR/${dst#$CLAUDE_DIR/}）"
    fi
    rm -rf "$dst"
  fi
  ln -sfn "$src" "$dst"
  echo "${GRN}link${RST}  $rel -> $src"
}

echo "REPO   : $REPO_DIR"
echo "TARGET : $CLAUDE_DIR"
echo "MODE   : $MODE"
echo "-----------------------------------------"

for rel in "${LINKS[@]}"; do
  link_one "$rel"
done

# settings.json は差分表示のみ（symlink しない）
echo "-----------------------------------------"
if [ -f "$MACOS_DIR/settings.json" ]; then
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    if diff -q "$MACOS_DIR/settings.json" "$CLAUDE_DIR/settings.json" >/dev/null 2>&1; then
      echo "${GRN}ok${RST}    settings.json  (リポジトリと一致)"
    else
      echo "${YLW}diff${RST}  settings.json  (実環境とリポジトリで差分あり)"
      echo "       確認: diff \"$MACOS_DIR/settings.json\" \"$CLAUDE_DIR/settings.json\""
      [ "$MODE" = "check" ] && drift=1
    fi
  else
    echo "${YLW}note${RST}  実環境に settings.json が無い"
  fi
else
  echo "${YLW}note${RST}  macos/settings.json 未整備（手動管理中）"
fi

echo "-----------------------------------------"
if [ "$MODE" = "check" ]; then
  if [ "$drift" -eq 0 ]; then
    echo "${GRN}CHECK OK: ドリフトなし${RST}"
    exit 0
  else
    echo "${RED}CHECK FAILED: ドリフトあり。./install.sh で修正してください${RST}"
    exit 1
  fi
fi
echo "完了。バックアップ（作成された場合）: $BACKUP_DIR"
