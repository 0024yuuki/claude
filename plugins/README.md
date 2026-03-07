# Plugins（カスタムプラグイン）

このディレクトリには、独自に作成した Claude Code のプラグインを保存します。

## 📦 含まれるプラグイン

### Second Opinion

複数の Claude モデル（Sonnet、Opus、Haiku）で同じ質問に対する回答を並列実行して比較する強力なプラグインです。

**主な機能:**
- ✅ **真の並列実行**: tmux を使用して3モデルを独立したプロセスで同時実行
- ✅ **自動比較分析**: Claude Sonnet が全回答を統合分析し、共通点・相違点を抽出
- ✅ **自然言語トリガー**: 「セカンドオピニオンして」という日本語で起動可能
- ✅ **明示的コマンド**: `/second-opinion` コマンドでオプション指定も可能

**使用例:**
```
User: Pythonでファイルを読み込む最良の方法は?
Assistant: [回答...]

User: セカンドオピニオンして
→ 自動的に3モデルで並列実行し、比較分析が開始されます
```

詳細は [second-opinion/README.md](second-opinion/README.md) を参照してください。

## 🔧 プラグインのインストール

### Second Opinion のインストール

```bash
# プラグインディレクトリにコピー
cp -r plugins/second-opinion ~/.claude/plugins/

# スクリプトに実行権限を付与
chmod +x ~/.claude/plugins/second-opinion/scripts/*.sh
```

**依存関係:**
- tmux: 並列実行に必須
- jq: JSON パースに使用

```bash
# CentOS/RHEL
sudo yum install tmux jq

# Ubuntu/Debian
sudo apt-get install tmux jq
```

## 📋 プラグインの構成

標準的なプラグイン構成:

```
plugins/your-plugin-name/
├── .claude-plugin/
│   └── plugin.json          # プラグインメタデータ（必須）
├── README.md                # プラグイン説明
├── commands/                # コマンド定義
│   └── your-command.md
├── skills/                  # スキル定義
│   └── your-skill/
│       └── SKILL.md
└── scripts/                 # ヘルパースクリプト
    └── your-script.sh
```

## 🎯 新しいプラグインの追加

1. **プラグインを作成**: `~/.claude/plugins/` に新しいプラグインを作成
2. **テスト**: Claude Code で動作確認
3. **リポジトリに追加**:
   ```bash
   cd ~/claude-config
   cp -r ~/.claude/plugins/your-plugin plugins/
   git add plugins/your-plugin
   git commit -m "Add your-plugin"
   ```

## 📚 参考

- [Claude Code Plugins ドキュメント](https://github.com/anthropics/claude-code)
- [Second Opinion Plugin](second-opinion/README.md)

---

これらのプラグインは、Claude Code の機能を拡張し、より強力なワークフローを実現します。
