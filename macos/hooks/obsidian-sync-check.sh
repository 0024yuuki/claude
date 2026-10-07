#!/usr/bin/env bash
#
# obsidian-sync-check.sh — Obsidian vault の同期が詰まっていたら警告する（SessionStart フック）
#
# 背景（2026-10-07 発覚）:
#   vault の push が 10/1 07:01 から6日間止まっていた。原因は index に未解決の
#   競合（UU）が5ファイル残ったことで、
#     - ノート本文には競合マーカーが1つも無い
#     - コミットは 10/3・10/4 と進み続けていた
#   ため Obsidian 上から完全に無症状だった。`git status` を見る習慣がないと
#   気づけないので、セッション開始時に機械的に見る。
#
#   📌 2回目だった。1回目（9/30 の23時間）に「本文は直したが git add/commit は
#   本人判断待ち」で残した UU が、そのまま2回目の6日間の停止になっている。
#   → 詳細: 09_Claude/Knowledge/obsidian-git-stale-merge-index.md
#
# ⭐ ネットワークを使わない設計:
#   `git fetch` を入れるとセッション開始が毎回止まり、オフラインで詰まる。
#   そして今回の故障シグネチャは全部ローカルで見える:
#     - UU / MERGE_HEAD はローカルの状態そのもの
#     - origin/main の ref は push が成功したときだけ前に進むので、
#       @{u}..HEAD にコミットが溜まっていること自体が「push が通っていない」証拠
#   よって fetch 無しで6日間の停止は検知できる。
#   ⚠️ 逆に「リモートが進んでいてこちらが遅れている」側は検知しない（pull は
#   obsidian-git が面倒を見るし、データ損失のリスクではないため）。
#
# 挙動: 異常があれば JSON を1つ出す。正常なら何も出さない（沈黙）。
#       どんな場合も exit 0 — セッション開始を妨げない。

set -uo pipefail

VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"

# vault が無い / git リポジトリでない場合は何もしない
[ -d "$VAULT/.git" ] || exit 0
command -v git >/dev/null 2>&1 || exit 0
command -v jq  >/dev/null 2>&1 || exit 0

cd "$VAULT" 2>/dev/null || exit 0

PROBLEMS=()

# ① index に未解決の競合が残っているか（6日間の停止の正体）
UNMERGED=$(git diff --name-only --diff-filter=U 2>/dev/null | wc -l | tr -d ' ')
if [ "${UNMERGED:-0}" -gt 0 ]; then
  FILES=$(git diff --name-only --diff-filter=U 2>/dev/null | sed 's/^/    - /')
  PROBLEMS+=("🔴 index に未解決の競合が ${UNMERGED} ファイル残っています（push が通りません）:
${FILES}
  → 本文を確認して解決し、必ず 'git add -A' と 'git commit' まで終わらせてください。
    本文を直しただけでは UU は消えません。")
fi

# ② マージ / rebase が中断したまま放置されていないか
for STATE in MERGE_HEAD rebase-merge rebase-apply CHERRY_PICK_HEAD; do
  if [ -e ".git/$STATE" ]; then
    SINCE=$(date -r ".git/$STATE" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "不明")
    PROBLEMS+=("🔴 .git/${STATE} が残っています（${SINCE} から中断中）
  → 'git merge --abort' で破棄してから、やり直してください。")
  fi
done

# ③ push されていないコミットが溜まっていないか
#    origin/main の ref は push 成功時だけ前に進むので、これが溜まる＝push が通っていない
if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
  AHEAD=$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
  if [ "${AHEAD:-0}" -gt 0 ]; then
    OLDEST=$(git log --reverse --format='%cd' --date=format:'%Y-%m-%d %H:%M' '@{u}..HEAD' 2>/dev/null | head -1)
    PROBLEMS+=("⚠️ 未 push のコミットが ${AHEAD} 件あります（最古: ${OLDEST}）
  → 'git push origin main' で反映できます。
    件数が多い / 日付が古い場合は自動 push が壊れているサインです。")
  fi
fi

# ④ obsidian-git が競合レポートを残していないか（競合が未解決のサイン）
if [ -f "conflict-files-obsidian-git.md" ]; then
  PROBLEMS+=("⚠️ conflict-files-obsidian-git.md が残っています ＝ obsidian-git が競合を検出したまま未解決です。")
fi

# 正常なら沈黙
[ ${#PROBLEMS[@]} -eq 0 ] && exit 0

# ⚠️ コマンド置換は末尾の改行を削るので、区切りの空行は MSG 側で明示的に入れる
BODY=$(printf '%s\n\n' "${PROBLEMS[@]}")
MSG="🔴 Obsidian vault の同期が詰まっています

${BODY}

確認:
  cd \"${VAULT}\"
  git status
  git rev-list --left-right --count origin/main...HEAD   # \"0  0\" 以外なら未同期
詳細: 09_Claude/Knowledge/obsidian-git-stale-merge-index.md"

jq -n --arg m "$MSG" '{
  systemMessage: $m,
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("Obsidian vault の同期が詰まっています。ユーザーが vault の作業を依頼した場合は先にこれを知らせてください:\n\n" + $m)
  }
}'

exit 0
