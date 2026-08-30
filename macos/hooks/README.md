# macos/hooks — macOS ローカル環境のフック

Claude Code のセッション中、特定のタイミングで実行されるシェルスクリプト。

- **稼働中は3本**。`install.sh` が `~/.claude/hooks/` へ **symlink** する
- 登録は `macos/settings.json` の `hooks` セクション
- Linux ラボ共有サーバー用のフック（`safety-check` / `path-guard` / `conventions` /
  `session-context`）は **ここには無い** → [`lab-linux/README.md`](../../lab-linux/README.md)

## フック一覧

| フック | イベント | 役割 | ブロック |
|--------|----------|------|----------|
| `opus-plan-review.sh` | `PostToolUse` : `ExitPlanMode` | プラン承認後に Opus がプランをレビュー（見落とし・リスク検出） | しない（出力のみ） |
| `opus-push-review.sh` | `PreToolUse` : `Bash` | `git push` を含むコマンドの直前に Opus がコード差分をレビュー | **しない**（通知のみ・常に `exit 0`） |
| `strip-quarantine.sh` | `Stop` | Obsidian vault から `com.apple.quarantine` を除去 | しない |

---

### opus-plan-review.sh

`~/.claude/plans/*.md` の**最新ファイル**を拾い、`claude --model opus --print`
に投げてレビュー結果を出力する。プランファイルが無ければ何もせず終了。

> 📌 **モデルは `opus` エイリアスで指定する（バージョンを固定しない）。**
> 以前は `claude-opus-4-8` に固定されており、Opus が世代交代しても追随せず、
> **「Opus によるレビュー」と称しながら旧世代を呼び続けていた**。
> 常に最新の Opus を使いたいので `opus` を使う。`opus-push-review.sh` と
> `commands/second-opinion.md` も同様。

### opus-push-review.sh

標準入力の JSON から `.tool_input.command` を取り出し、**`git push` を含まないコマンドは
即座に通過**する（全 Bash 呼び出しで走るので、この早期 return が実質のフィルタ）。

差分は `origin/<現在のブランチ>..HEAD`、取れなければ `HEAD~1..HEAD` にフォールバック。
差分が無ければスキップ。**レビュー結果を表示するだけで push は止めない。**

### strip-quarantine.sh

Obsidian vault 配下（`.git` を除く）から `com.apple.quarantine` **のみ**を削除する。
`com.apple.provenance` 等の他の拡張属性、ファイル内容・権限・タイムスタンプには触れない。
vault が無い環境では何もしない。常に `exit 0`。

**なぜ必要か**: Claude Code が書いたファイルには macOS の隔離属性が継承され、
**Obsidian がそのファイルをインデックスしない**。ディスク上には存在するのに一覧に現れず、
リンクを踏むと「File already exists」になる。2026-08-30 の発覚時点で **16ファイル**が
数週間ぶん埋もれていた。

`Write` は成功を返し `ls` も `git status` も正常に見えるため（**git は拡張属性を保存しない**）、
**本人が開こうとするまで検出できない**。だから記録ではなくフックで塞いでいる。

> ⚠️ **このフックが防ぐのは新規の書き込みだけ。**
> 既に Obsidian のインデックスから漏れたファイルは、隔離属性を外しても
> インデックスに「無いもの」として残る。**Obsidian を `Cmd+Q` で完全終了して再起動**する必要がある
> （「Reload app without saving」では不十分）。
>
> 取りこぼしを手で直す場合:
> ```bash
> find "$VAULT" -not -path "*/.git/*" -exec xattr -d com.apple.quarantine {} + 2>/dev/null
> ```

---

## セットアップ

```bash
~/claude/install.sh          # symlink を張る（冪等）
~/claude/install.sh --check  # 現状確認のみ
```

⚠️ **`cp` しない。** symlink なのでリポジトリ側を編集すれば即反映される。
新しいフックを追加したら **`install.sh` の `LINKS` 配列にも足す**（ハードコードのため）。

## settings.json への登録

```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "ExitPlanMode",
        "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/opus-plan-review.sh" }] }
    ],
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/opus-push-review.sh" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command",
                    "command": "$HOME/.claude/hooks/strip-quarantine.sh",
                    "timeout": 20,
                    "statusMessage": "Obsidian: 隔離属性を除去中" }] }
    ]
  }
}
```

> 🔴 **`settings.json` は symlink されない。**
> 機密混入を避けるため `install.sh` は**差分表示のみ**行う。
> → **`macos/settings.json` と `~/.claude/settings.json` の両方に手で入れる**必要がある。
> 片方だけだと「フックは登録されているのに symlink が無い」等で壊れる。
>
> 差分確認: `diff ~/claude/macos/settings.json ~/.claude/settings.json`

> ⚠️ **登録直後は効かない。** 設定ウォッチャはセッション開始時に存在した設定ファイルしか
> 監視しないため、**次のセッション**、または **`/hooks` を一度開く**（設定が再読込される）まで待つ。

## テスト

フックは**標準入力に JSON** を受け取る。実際に届くペイロードを流して確かめる。

```bash
# strip-quarantine.sh — 隔離属性を付けたテストファイルで確認
V="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"
printf 'test\n' > "$V/.qtest.md"
xattr -w com.apple.quarantine "0081;00000000;;" "$V/.qtest.md"
echo '{}' | ~/.claude/hooks/strip-quarantine.sh
xattr "$V/.qtest.md"   # → quarantine が消えていること（provenance は残る）
rm -f "$V/.qtest.md"

# opus-push-review.sh — git push 以外は即通過することの確認
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ~/.claude/hooks/opus-push-review.sh
# → 何も出力されず exit 0

# opus-plan-review.sh — 最新のプランファイルを読むだけなので直接実行でよい
echo '{}' | ~/.claude/hooks/opus-plan-review.sh
```

JSON の妥当性とスキーマは `jq -e` で確認できる:

```bash
jq -e '.hooks.Stop[] | .hooks[] | select(.type=="command") | .command' ~/.claude/settings.json
# exit 0 かつコマンドが出力されれば OK。exit 5 は JSON 破損 or ネスト誤り
```

⚠️ **`settings.json` が壊れると、そのファイルの設定が丸ごと無効になる**（サイレント）。
編集後は必ず検証する。

## 仕様メモ

- **入力**: 標準入力に JSON。`PreToolUse` / `PostToolUse` では `.tool_name` と `.tool_input`
  （`Bash` なら `.tool_input.command`、`Write`/`Edit` なら `.tool_input.file_path`）
- **出力**: `exit 0` で通過。`PreToolUse` で `exit 2` を返すとツール実行をブロックできる
- **ブロックしないフックは必ず `exit 0` で終える**（`opus-push-review.sh` が明示的にそうしている）
- 詳細: <https://docs.claude.com/en/docs/claude-code/hooks>
