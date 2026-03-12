---
description: SEO・アフィリエイト最適化した長文記事（3,000〜4,000文字）を作成・WordPress に投稿する。「SEO記事書きたい」「アフィリエイト記事」「blog-write-pro」と言われたら使う。
argument-hint: [トピックのヒント（省略可）]
allowed-tools: [Bash, Read, Write, WebSearch]
---

# Blog Write Pro — SEO＋アフィリエイト最適化記事作成

このコマンドは `/blog-write` の強化版です。3,000〜4,000文字の長文記事を SEO を意識した構成で作成し、アフィリエイトリンクを自然に挿入します。

作業ディレクトリは常に `/Users/onishiyuki/Desktop/website` です。

---

## Step 1: 文体分析（サイレント実行）

```bash
cd /Users/onishiyuki/Desktop/website && ./wp.sh posts list
```

最新5件の記事本文を取得して文体・語調・構成を分析します:

```bash
cd /Users/onishiyuki/Desktop/website && ./wp.sh posts get <id>
```

**分析ポイント:**
- 文末の表現（「〜です」「〜だ」「〜ですね」など）
- 段落の長さと構成
- 感情表現や口語的な言い回し
- よく使うキーワードや表現パターン
- H2/H3 見出しの使い方

また、既存記事の URL をメモしておきます（内部リンク挿入に使用）。

---

## Step 2: キーワードキューの確認（サイレント実行）

`seo/keyword-queue.md` が存在するか確認します:

```bash
cat /Users/onishiyuki/Desktop/website/seo/keyword-queue.md 2>/dev/null || echo "keyword-queue.md なし"
```

存在する場合、優先度の高いキーワードをメモします（タイトルや本文に反映）。

`plans/` に今月のコンテンツプランがあれば参照します:

```bash
ls /Users/onishiyuki/Desktop/website/plans/ 2>/dev/null
```

---

## Step 3: カテゴリー・タグの把握（サイレント実行）

```bash
cd /Users/onishiyuki/Desktop/website && ./wp.sh categories list
cd /Users/onishiyuki/Desktop/website && ./wp.sh tags list
```

---

## Step 4: インタビュー

ユーザーに以下の質問を **一問ずつ** 行います。前の回答を受けてから次へ進みます。

**必須の質問（順番通り）:**
1. 「何について書きますか？レースレポート・ギアレビュー・旅行記・ノウハウ記事などで教えてください。」
2. 「いつ・どこでの出来事ですか？もしくはいつ気づいたことですか？」
3. 「そのときどう感じましたか？読者に一番伝えたいことは何ですか？」
4. 「紹介したい商品・ギア・サービスはありますか？（Amazon アソシエイトリンクを挿入します）」

**回答が薄い場合のみ追加する質問:**
5. 「他に付け加えたいエピソードや情報はありますか？」

---

## Step 5: SEO キーワード調査（WebSearch）

インタビュー結果とキーワードキューをもとに、記事のメインキーワードを決定します。

WebSearch で以下を確認します:
- 「[メインキーワード] site:oitoma.net」— 既存記事との重複確認
- 「[メインキーワード] 検索ボリューム」— 需要確認

競合記事の構成（H2 見出し）も調査し、差別化ポイントを特定します。

---

## Step 6: アフィリエイト商品リサーチ（WebSearch）

記事テーマに応じて紹介する商品を決定します。

**ランニング記事の場合（カテゴリ8%）:**
- シューズ（アシックス・ナイキ・ホカ）: `WebSearch` で「[シューズ名] Amazon」を検索して最新価格・リンクを確認
- GPS ウォッチ（Garmin・COROS・Polar）
- ランニングウェア・栄養補助食品

**旅行記事の場合:**
- スーツケース・トラベルグッズ
- 変換プラグ・モバイルバッテリー
- ガイドブック

Amazon の商品ページ URL を取得し（`https://www.amazon.co.jp/dp/[ASIN]/?tag=oitoma-22` 形式）、記事内に自然に挿入します。

> **注意:** アソシエイトタグは `oitoma-22` を使用します（ユーザーに確認が必要な場合は確認する）。

---

## Step 7: 記事生成

インタビュー・文体分析・SEO調査・商品リサーチをもとに長文記事を生成します。

**生成ルール:**
- Step 1 で分析したユーザーの文体・語調を再現する
- **3,000〜4,000文字**（SEO 上の優位性のため必須）
- H2 見出し **4〜6個**（メインキーワードを含む見出しを1〜2個）
- **FAQ セクション**（よくある質問 3〜5問）を記事末尾に必須追加
- アフィリエイトリンクを **2〜4箇所**、会話の流れを妨げない形で自然に挿入
- 既存記事への **内部リンクを1〜3本**（Step 1 でメモした URL を使用）
- メタディスクリプション（120〜160文字）も生成する

**推奨構成:**
```
H1: [記事タイトル（メインキーワード含む）]

[リード文: 読者の悩み・共感から始める 200字程度]

H2: [背景・体験談]
[本文 500〜700字]

H2: [メインコンテンツ 1]
[本文 500〜700字、アフィリエイトリンク1箇所]

H2: [メインコンテンツ 2]
[本文 500〜700字、アフィリエイトリンク1箇所]

H2: [結果・成果・まとめ]
[本文 400〜500字]

H2: [まとめ・読者へのメッセージ]
[本文 300字、内部リンク1〜2本]

H2: よくある質問（FAQ）
Q: [質問1]
A: [回答1]
Q: [質問2]
A: [回答2]
Q: [質問3]
A: [回答3]
```

**出力形式:**
```
---
タイトル: [提案タイトル（メインキーワード含む）]
メタディスクリプション: [120〜160文字の説明文]
カテゴリー: [カテゴリー名]
タグ: [タグ1, タグ2, タグ3, タグ4]
使用キーワード: [メインキーワード, サブキーワード1, サブキーワード2]
アフィリエイトリンク: [挿入した商品名とURL一覧]
文字数: [概算]
---

[本文（HTML形式）]
```

---

## Step 8: レビュー

記事を表示した後、ユーザーに確認します:

> 「この記事でよければ「OK」と言ってください。修正したい場合は具体的に教えていただければ直します。アフィリエイトリンクの商品やタグも確認をお願いします。」

**修正ループ:** フィードバックがあれば修正して再提示。「OK」が出るまで繰り返す。

---

## Step 9: WordPress へ投稿

ユーザーが「OK」を出したら投稿します:

```bash
cd /Users/onishiyuki/Desktop/website && ./wp.sh posts create \
  --title "タイトル" \
  --content "本文（HTML形式）" \
  --status publish \
  --category "カテゴリー名" \
  --tags "タグ1,タグ2,タグ3,タグ4"
```

出力から `post_id` と URL を取得し、ユーザーに報告します。

---

## Step 10: Markdown 保存 & git commit

### 10-1. Markdown ファイルを保存

ファイル名: `posts/YYYY-MM-DD-slug.md`

```markdown
---
title: "タイトル"
date: YYYY-MM-DD
wp_id: POST_ID
category: "カテゴリー名"
tags: ["タグ1", "タグ2", "タグ3"]
keywords: ["メインKW", "サブKW"]
affiliate_links:
  - name: "商品名"
    url: "https://www.amazon.co.jp/dp/ASIN/?tag=oitoma-22"
word_count: 3500
---

本文（Markdown形式）
```

### 10-2. keyword-queue.md を更新

使用したキーワードを `seo/keyword-queue.md` から削除または済みマークを付けます（ファイルが存在する場合）。

### 10-3. git commit

```bash
cd /Users/onishiyuki/Desktop/website && git add posts/YYYY-MM-DD-slug.md && git commit -m "feat(blog): タイトル [wp-id:POST_ID]"
```

commit 完了後、ユーザーに「投稿完了しました！ 記事URL: [URL]」と報告して終了。
