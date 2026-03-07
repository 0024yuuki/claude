# Claude Code 設定のセットアップガイド

このガイドでは、このリポジトリに保存されている Claude Code の設定を新しい環境に適用する方法を説明します。

## 📋 前提条件

- Claude Code がインストールされていること
- Git がインストールされていること
- GitHub CLI (gh) がインストールされていること（推奨）

## 🚀 セットアップ手順

### 1. リポジトリのクローン

```bash
# GitHub CLI を使用する場合
gh repo clone 0024yuuki/claude

# または通常の git を使用
git clone https://github.com/0024yuuki/claude.git
cd claude
```

### 2. フックのインストール

カスタムフックを Claude の設定ディレクトリにコピーします:

```bash
# フックディレクトリを作成（存在しない場合）
mkdir -p ~/.claude/hooks

# フックをコピー
cp -r hooks/* ~/.claude/hooks/

# 実行権限を付与
chmod +x ~/.claude/hooks/*.sh
```

### 3. 設定ファイルの適用

```bash
# 既存の設定をバックアップ（念のため）
cp ~/.claude/settings.json ~/.claude/settings.json.backup

# テンプレートをコピー
cp settings/settings.template.json ~/.claude/settings.json
```

**注意**: `settings.template.json` には以下が含まれています:
- パーミッション設定（allow/deny/ask）
- フック設定
- 有効なプラグインリスト
- デフォルトモデル設定

必要に応じて編集してください。

### 4. フックの動作確認

各フックの目的:

- **safety-check.sh**: 危険な Bash コマンド（`rm -rf` など）を検出
- **path-guard.sh**: 書き込み操作の対象パスが安全かチェック
- **conventions.sh**: コーディング規約に従っているかチェック
- **session-context.sh**: セッション開始時にプロジェクトコンテキストを設定

フックが正しく動作するかテスト:

```bash
# safety-check.sh のテスト
echo 'rm -rf /' | ~/.claude/hooks/safety-check.sh

# 危険なコマンドの場合、エラーメッセージが表示されるはずです
```

## 🎯 カスタマイズ

### 独自のフックを追加

1. `~/.claude/hooks/` に新しいシェルスクリプトを作成
2. 実行権限を付与: `chmod +x ~/.claude/hooks/your-hook.sh`
3. `settings.json` の `hooks` セクションに登録

### スキルの追加

自作スキルは `skills/` ディレクトリに配置し、以下の形式で管理:

```
skills/
└── your-skill-name/
    ├── skill.json          # スキル定義
    ├── instructions.md     # 説明
    └── examples/           # 使用例
```

## 🔄 設定の同期

### ローカルからリポジトリへ

新しいフックやスキルを作成したら、リポジトリに追加:

```bash
# 変更をコミット
git add hooks/ skills/ settings/
git commit -m "Add new hook/skill"
git push
```

### リポジトリからローカルへ

他の環境で追加した設定を取得:

```bash
cd ~/claude
git pull
cp -r hooks/* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

## ⚠️ 重要な注意事項

### 絶対に含めてはいけないもの

- `.credentials.json` - 認証情報
- `history.jsonl` - 会話履歴
- APIキーや個人情報を含むファイル

### プロジェクト固有の設定

`claude.md` などのプロジェクト固有の設定は、プロジェクトのリポジトリで管理し、この汎用設定リポジトリには含めません。

## 🔧 トラブルシューティング

### フックが実行されない

```bash
# 実行権限を確認
ls -la ~/.claude/hooks/

# 権限がない場合は付与
chmod +x ~/.claude/hooks/*.sh
```

### 設定が反映されない

Claude Code を再起動してください。

### フックがエラーを返す

フックスクリプトを直接実行してデバッグ:

```bash
bash -x ~/.claude/hooks/safety-check.sh
```

## 📚 参考リンク

- [Claude Code 公式ドキュメント](https://github.com/anthropics/claude-code)
- [Hooks の詳細](https://github.com/anthropics/claude-code/blob/main/docs/hooks.md)
