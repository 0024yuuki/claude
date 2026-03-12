---
description: 既存記事のアフィリエイトリンクを監査し、リンクのない記事に商品リンクを追加提案・反映する。「アフィリエイト監査」「monetize」「monetize-audit」と言われたら使う。
argument-hint: [記事ID（省略時は全記事を対象）]
allowed-tools: [Bash, Read, Write, WebSearch]
---

# Monetize Audit — アフィリエイトリンク監査・改善

既存記事を全件スキャンし、アフィリエイトリンクが未挿入の記事を特定。記事テーマに合った商品を調査し、自然な形でリンクを追加します。

作業ディレクトリは常に `/Users/onishiyuki/Desktop/website` です。

---

## Step 1: 全記事取得（サイレント実行）

```bash
cd /Users/onishiyuki/Desktop/website && ./wp.sh posts list
```

公開済み（publish）記事の ID とタイトルをすべてリストアップします。

---

## Step 2: 各記事のアフィリエイトリンク有無を確認（サイレント実行）

各記事について本文を取得し、アフィリエイトリンクの有無を確認します:

```bash
cd /Users/onishiyuki/Desktop/website && ./wp.sh posts get <id>
```

**アフィリエイトリンクとみなす条件:**
- `amazon.co.jp` を含む URL
- `a8.net`、`af.moshimo.com`、`valuecommerce.com` などのアフィリエイトネットワーク URL
- `tag=oitoma-22` を含む URL（自サイトのアソシエイトタグ）

**判定結果を以下の形式でメモ:**
```
ID: [post_id] | タイトル: [...] | リンク: あり/なし | カテゴリ: [...]
```

---

## Step 3: リンクなし記事の商品リサーチ（WebSearch）

アフィリエイトリンクがない記事について、カテゴリ・内容に応じた商品を調査します。

**ランニング系記事の場合:**
- レースレポート → 使用シューズ・GPS ウォッチ・補給食を WebSearch で Amazon 検索
- トレーニング記事 → トレーニング本・ウェア・シューズ
- 大会紹介 → エントリー代替商品（関連ウェア・地図・ガイドブック）

**旅行系記事の場合:**
- 旅行記 → スーツケース・変換プラグ・ガイドブック・カメラ用品
- 観光地紹介 → 現地ツアー・旅行保険・持ち物リスト商品

**商品候補の確認ポイント:**
- Amazon.co.jp で実際に購入可能か
- レビュー数 100件以上・評価 4.0以上を優先
- ASIN を取得して `https://www.amazon.co.jp/dp/[ASIN]/?tag=oitoma-22` 形式のリンクを作成

---

## Step 4: 挿入提案をユーザーに提示

リンクなし記事ごとに、以下の形式で提案します:

```
【記事 ID: XXX】タイトル: [記事タイトル]

📌 提案する商品リンク:

1. [商品名]
   挿入箇所: [本文の「〜」という部分の直後]
   リンク: https://www.amazon.co.jp/dp/ASIN/?tag=oitoma-22
   理由: [なぜこの商品が自然に挿入できるか]

2. [商品名]
   挿入箇所: [本文の「〜」という部分]
   リンク: https://www.amazon.co.jp/dp/ASIN/?tag=oitoma-22
   理由: [理由]

この提案でよければ「OK」、修正がある場合は教えてください。
スキップする場合は「スキップ」と言ってください。
```

記事を複数件まとめて提案するのではなく、**1件ずつ確認** して次へ進みます。

---

## Step 5: 記事更新（ユーザー承認後）

ユーザーが「OK」を出した記事について、本文を更新します。

アフィリエイトリンクは以下の HTML 形式で挿入します（記事の自然な流れを維持）:

```html
<a href="https://www.amazon.co.jp/dp/ASIN/?tag=oitoma-22" target="_blank" rel="nofollow noopener noreferrer">[商品名]（Amazon）</a>
```

更新コマンド:

```bash
cd /Users/onishiyuki/Desktop/website && ./wp.sh posts update <id> --content "[アフィリエイトリンクを挿入した本文全体]"
```

---

## Step 6: 監査レポートの出力

全記事の処理完了後、サマリーを表示します:

```
【アフィリエイト監査レポート】実行日: YYYY-MM-DD

対象記事数: X件
- リンクあり（変更なし）: X件
- リンク追加済み: X件
- スキップ: X件

追加したリンク数: X件
想定月間収益増加（試算）: 約 [X] 円
（PV × クリック率 1% × 成約率 5% × 平均単価 × カテゴリ手数料率で試算）

次回の監査推奨日: 来月初旬
```
