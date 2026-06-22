# Claude Rereview Request: Gimme 1.2.0+3

## 依頼

このZIPは、AI Summit 6.0 第2回で選ばれたアプリ `Gimme` の再レビュー用パッケージです。

前回Claude/クロエから、以下のような厳しい指摘を受けました。

- `daysLeft` が固定で、全ユーザーに同じ締切が出る
- `city` が計算に使われていない
- Paywallが実際には何も制限していない
- サブスク節約額が雑な `monthly * 2..6` になっている
- 「今月」と年次/単発/毎月の扱いが混ざっている
- チェック完了額を実回収額として扱っている
- 実AI機能がない
- Android/iOSメタデータや古いテンプレート残骸が残っている

しんちゃんから「MVPではなく100%完成品を目指す指示だった。低すぎるとの批判は間違いではない」と修正方針が出たため、今回の版では検証MVP扱いをやめ、完成品基準に近づけるため以下を反映しています。

## 今回の主な修正

- 期限を固定値から実日付計算へ変更
- `daysLeft` は `deadline - asOf` から導出
- 地域入力をローカル自治体プロファイル、候補金額、根拠、表示文に接続
- Free/Plus gatingを実装
  - Freeは上位3件とぼかし金額
  - Plusは全候補、詳細根拠、手順、書類、実回収記録を解放
- サブスク節約額を月額総額、契約数、未使用候補数、放置月数から算定
- 年次/毎月/単発の期間概念を追加
- 「申請準備完了額」と「実回収額」を分離
- AI明細スキャンを追加
  - 現版はローカル解析
  - 正式版で外部AI/APIへ差し替えやすい境界にしている
- Android/iOSの表示名を `Gimme` に統一
- 古い `com/example/gimme` フォルダを削除
- `.dart_tool`, `.gradle`, `.kotlin`, `.idea`, `.wrangler`, `build` をレビュー同梱から除外
- 版数を `1.2.0+3` に更新

## クロエに見てほしいこと

前回より改善したかどうかを甘く見ず、完成品基準で辛口に再評価してください。

特に見てほしい観点:

1. アプリ企画として本当にヒットしそうか
2. 継続収益、課金導線、支払い理由がまだ弱くないか
3. UI/UXがAI生成っぽい試作品に見えないか
4. Android/iOSネイティブ正式リリース前提として設計が破綻していないか
5. Flutter実装、状態管理、永続化、画面構成、テストに問題がないか
6. 法務・安全・制度情報の扱いで、後から潰れそうなリスクは何か
7. 前回指摘した致命傷が本当に潰れているか
8. このまま出しても弱いところ、直すなら優先順位の高い順に何か
9. 「金になるアプリ」として、どこを尖らせるべきか
10. 完成品としてまだ10割に届いていない理由は何か

## 返答形式

- 総合評価: 100点満点
- 前回からの改善度: 100点満点
- ヒット可能性: 100点満点
- マネタイズ可能性: 100点満点
- UI/UX品質: 100点満点
- 技術品質: 100点満点
- 前回の致命傷が潰れたか
- まだ致命的な懸念
- 直すべき順番 Top 10
- 収益性を上げる改善案 Top 10
- そのまま残すべき強み
- 次にClaude/Codexへ出す修正指示プロンプト

## 公開確認URL

https://new31005.github.io/ai-summit-gimme-20260622/

## GitHub

https://github.com/NEW31005/ai-summit-gimme-20260622

最新コミット:

`6230291 Make Gimme completion-standard product logic real`

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
  - Claude一次レビュー/再レビュー/再レビュー対応メモ
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
- `flutter test`: pass, 9 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass
- GitHub Pagesスマホ幅表示確認: pass at 390 x 844
