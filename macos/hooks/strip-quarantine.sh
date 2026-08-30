#!/usr/bin/env bash
#
# strip-quarantine.sh — Obsidian vault から macOS の隔離属性を除去する（Stop フック）
#
# 背景（2026-08-30 発覚）:
#   Claude Code が書き込んだファイルには com.apple.quarantine が付く。
#   Obsidian は隔離属性の付いたファイルをインデックスしないため、
#   「ディスクには存在するが Obsidian の一覧に出ない」状態になる。
#   その状態でリンクを踏むと Obsidian が新規作成を試み、
#   ファイルシステムが弾いて "File already exists" になる。
#
#   発覚時点で 16 ファイルが埋もれていた（引き継ぎ資料の目次案・W34 のログ・
#   Knowledge/ の技術メモ・Hypotheses/reviews 4件 など）。
#   症状が出るまで気づけないため、書くたびに自動で外す。
#
# ⚠️ このフックが防ぐのは「これから書くファイル」だけ。
#   既に Obsidian のインデックスから漏れたファイルは、隔離属性を外しても
#   インデックスに「無いもの」として残るため、Obsidian を Cmd+Q で
#   完全終了して再起動する必要がある（Reload app without saving では不十分）。
#
# 挙動:
#   - vault 配下（.git を除く）から com.apple.quarantine のみを削除する
#   - 他の拡張属性（com.apple.provenance 等）には触れない
#   - ファイルの内容・権限・タイムスタンプは変更しない
#   - vault が無い環境では何もしない
#   - 常に exit 0。セッションを止めない
#
# 参照: 09_Claude/Knowledge/mistakes/2026-08-30-config-隔離属性でObsidianがファイルを認識しない.md

set -u

VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"

[ -d "$VAULT" ] || exit 0

# -exec ... + でバッチ実行（1ファイル1プロセスにしない）
find "$VAULT" -not -path "*/.git/*" -exec xattr -d com.apple.quarantine {} + 2>/dev/null

exit 0
