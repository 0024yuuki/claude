# Skills（カスタムスキル）

このディレクトリには、独自に作成した Claude Code のスキルを保存します。

## 📁 スキルの構成

各スキルは独立したディレクトリとして管理します:

```
skills/
└── your-skill-name/
    ├── skill.json          # スキル定義（必須）
    ├── instructions.md     # 詳細な使用方法（推奨）
    ├── examples/           # 使用例（オプション）
    │   └── example1.md
    └── README.md           # スキルの説明（オプション）
```

## 🔧 スキルの作成

### 基本的な skill.json の構造

```json
{
  "name": "your-skill-name",
  "description": "スキルの簡潔な説明",
  "version": "1.0.0",
  "author": "0024yuuki",
  "instructions": "スキルが実行すべき詳細な指示...",
  "parameters": {
    "param1": {
      "type": "string",
      "description": "パラメータの説明",
      "required": false
    }
  }
}
```

## 📝 スキルのインストール

作成したスキルを Claude Code で使用するには、適切なディレクトリに配置します。

詳細は Claude Code の公式ドキュメントを参照してください。

## 💡 スキルのアイデア

以下のようなスキルが有用かもしれません:

- **バイオインフォマティクス関連**
  - FastQC レポートの自動解析
  - BLAST 結果の整形と要約
  - antiSMASH 出力の解釈

- **データ処理**
  - CSV/TSV ファイルの統計サマリー
  - バッチ処理スクリプトの生成

- **ドキュメント生成**
  - 解析結果レポートの自動生成
  - README の自動更新

## 🔗 参考

- [Claude Code Skills ドキュメント](https://github.com/anthropics/claude-code)

---

**注意**: 現在このディレクトリは空ですが、今後作成したスキルをここに追加していきます。
