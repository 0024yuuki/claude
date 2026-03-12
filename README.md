# Claude Code Configuration Repository

このリポジトリは、Claude Code の設定、カスタムフック、スキルを管理するためのものです。

## 📁 構成

```
claude/
├── hooks/                # カスタムフック（セッション開始時などに実行）
├── plugins/              # カスタムプラグイン
│   └── second-opinion/  # 複数モデル並列実行＆比較プラグイン
├── settings/             # 汎用的な設定ファイルテンプレート
├── skills/               # 自作スキル定義
├── teams/                # エージェントチーム定義
│   └── code-review/     # コードレビュー専門チーム
└── docs/                 # ドキュメント
```

## 🔧 含まれるもの

### Hooks（カスタムフック）

Claude Code のセッション開始時や特定のイベント時に実行されるシェルスクリプト:

- **conventions.sh** - コーディング規約のチェック
- **path-guard.sh** - パス操作の安全性チェック
- **safety-check.sh** - 危険な操作の検出
- **session-context.sh** - セッションコンテキストの設定

### Plugins（プラグイン）

独自に作成したカスタムプラグイン:

- **second-opinion**: 複数の Claude モデル（Sonnet、Opus、Haiku）で並列実行して回答を比較分析

### Settings（設定）

Claude Code の汎用的な設定テンプレート（機密情報は含まない）

### Skills（スキル）

独自に作成したカスタムスキル

### Teams（エージェントチーム）

複数の専門エージェントが協調して作業するチーム定義:

- **code-review**: セキュリティ・パフォーマンス・テストの3専門家が並列レビューを実施

## 📦 セットアップ

詳細は [docs/setup.md](docs/setup.md) を参照してください。

### クイックスタート

```bash
# リポジトリをクローン
gh repo clone 0024yuuki/claude

# フックをコピー
cp -r claude/hooks/* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# プラグインをコピー
cp -r claude/plugins/* ~/.claude/plugins/
chmod +x ~/.claude/plugins/*/scripts/*.sh

# 設定をコピー（必要に応じて編集）
cp claude/settings/settings.template.json ~/.claude/settings.json
```

## ⚠️ セキュリティ

このリポジトリには以下を**絶対に含めません**:

- 認証情報（`.credentials.json`、APIキーなど）
- 会話履歴やセッションデータ
- プロジェクト固有の機密情報

## 📝 ライセンス

個人用設定リポジトリ

## 🔗 関連リンク

- [Claude Code 公式ドキュメント](https://github.com/anthropics/claude-code)
