# Claude Review Request: Gimme

## 依頼

このZIPは、AI Summit 6.0 第2回で選ばれたアプリ `Gimme` のレビュー用パッケージです。

2026-06-22のClaude一次レビュー指摘を受けて、以下を反映した改善版です。

- 金額を一点表示から概算レンジ表示に変更
- 各候補へ推定根拠を追加
- 医療費控除を「支払額が戻る」表現から、還付/軽減見込みの説明へ修正
- 免責とプライバシー表示を追加
- `Gimme Plus` の課金画面と確認版の有効化状態を追加
- Flutterテンプレート由来のメタデータ、Android application id、iOS bundle idを修正

あなたには、以下の観点で厳しめにレビューしてほしいです。

1. アプリ企画として本当にヒットしそうか
2. 継続収益、課金導線、支払い理由が弱くないか
3. UI/UXがAI生成っぽい試作品に見えないか
4. Android/iOSネイティブ正式リリース前提として設計が破綻していないか
5. Flutter実装、状態管理、永続化、画面構成、テストに問題がないか
6. 法務・安全・制度情報の扱いで、後から潰れそうなリスクは何か
7. このまま出しても弱いところ、直すなら優先順位の高い順に何か
8. 「金になるアプリ」として、どこを尖らせるべきか

レビュー結果は、以下の形式で返してください。

- 総合評価: 100点満点
- ヒット可能性: 100点満点
- マネタイズ可能性: 100点満点
- UI/UX品質: 100点満点
- 技術品質: 100点満点
- 致命的な懸念
- 直すべき順番 Top 10
- 収益性を上げる改善案 Top 10
- そのまま残すべき強み
- 次にClaude/Codexへ出す修正指示プロンプト

## 公開確認URL

https://new31005.github.io/ai-summit-gimme-20260622/

## GitHub

https://github.com/NEW31005/ai-summit-gimme-20260622

## ZIP内の主な内容

- `app_project_source/`
  - Flutterアプリの主要ソース
  - `lib/`, `test/`, `android/`, `ios/`, `web/`
  - `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`
- `ai_summit_run/`
  - Round 1-4 のAI Summit記録
  - Top 5
  - しんちゃんの選択
  - 最終企画書
  - QA/デプロイ記録
  - NoMan保存企画
- `deploy_github_pages_repo/`
  - GitHub Pagesへ公開したFlutter Web成果物
- `lineup/`
  - `AIサミット_アプリラインナップ.xlsx`

## APKについて

Android debug APKはサイズが大きいため、このClaude添付用ZIPには入れていません。

生成済みAPK:

`C:\dev\summit_2026_06_25_frame2_genre_002\build\app\outputs\flutter-apk\app-debug.apk`

検証済み:

- `flutter analyze`: pass
- `flutter test`: pass
- `flutter build web`: pass
- `flutter build apk --debug`: pass
- GitHub Pagesスマホ幅表示確認: pass
