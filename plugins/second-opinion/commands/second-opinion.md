---
description: "Claude Opus によるコードレビュー（セカンドオピニオン）"
allowed-tools:
  - "Bash(git diff:*)"
  - "Bash(git diff *)"
  - "Bash(git log:*)"
  - "Bash(git log *)"
  - "Bash(git branch:*)"
  - "Bash(git branch *)"
  - "Bash(git status:*)"
  - "Bash(git status *)"
  - "Bash(claude *)"
---

# Opus セカンドオピニオン

現在の変更について Claude Opus がコードレビューを実施します。

引数: $ARGUMENTS
- 省略: プッシュ予定の差分（`origin/<branch>..HEAD`）をレビュー
- `--staged`: ステージ済みの変更のみ
- `--last`: 最終コミットのみ

## 実行手順

1. 現在のブランチと状態を確認する：
   ```bash
   git branch --show-current
   git status --short
   ```

2. 引数に応じてレビュー対象の差分を取得する：
   - デフォルト: `git diff origin/$(git branch --show-current)..HEAD 2>/dev/null || git diff HEAD~1..HEAD`
   - `--staged` の場合: `git diff --cached`
   - `--last` の場合: `git diff HEAD~1..HEAD`

3. 取得した差分を Opus にパイプして詳細レビューを依頼する：
   ```bash
   DIFF=$(git diff origin/$(git branch --show-current)..HEAD 2>/dev/null || git diff HEAD~1..HEAD 2>/dev/null)
   echo "以下のコード変更についてセカンドオピニオンをお願いします。バグ・セキュリティ脆弱性・コード品質・パフォーマンス・改善提案を日本語で詳しく報告してください：

   $DIFF" | claude --model claude-opus-4-8 --print
   ```

4. Opus の指摘事項を以下の形式で要点まとめして報告する：
   - 重大な問題（対処必須）
   - 改善推奨事項
   - 軽微なコメント（参考）
