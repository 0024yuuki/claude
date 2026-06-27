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

- **opus-push-review.sh** - `git push` 前に Opus がコード差分をレビュー（PreToolUse:Bash）
- **opus-plan-review.sh** - プラン承認後に Opus がプランをレビュー（PostToolUse:ExitPlanMode）
- **conventions.sh** - コーディング規約のチェック
- **path-guard.sh** - パス操作の安全性チェック
- **safety-check.sh** - 危険な操作の検出
- **session-context.sh** - セッションコンテキストの設定

### Plugins（プラグイン）

独自に作成したカスタムプラグイン:

- **second-opinion**: Claude Opus によるコードレビュー（セカンドオピニオン）。`/second-opinion` で起動

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
gh repo clone 0024yuuki/claude ~/claude

# フックをコピーして実行権限を付与
mkdir -p ~/.claude/hooks
cp ~/claude/hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# /second-opinion コマンドをコピー
mkdir -p ~/.claude/commands
cp ~/claude/plugins/second-opinion/commands/second-opinion.md ~/.claude/commands/

# 設定をコピー（必要に応じて編集）
cp ~/claude/settings/settings.template.json ~/.claude/settings.json
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
