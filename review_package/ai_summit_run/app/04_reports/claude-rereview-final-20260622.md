# Claude Final Rereview / 2026-06-22

Claude chat:

`https://claude.ai/chat/dedeb474-719f-4922-bb2d-37d15bae79c5`

## Scores

| Item | Score | Previous | Note |
|---|---:|---:|---|
| 総合評価 | 63 | 51 | 表面の穴は全閉。実データ、実課金、実AIが未完成 |
| 前回からの改善度 | 86 | - | 前回8指摘はほぼ全消化 |
| ヒット可能性 | 58 | 44 | フックは強化。実額ズレの信頼リスクが残る |
| マネタイズ可能性 | 52 | 36 | ゲート構造はできたが、実課金は未接続 |
| UI/UX品質 | 76 | 73 | ロック/ティーザー状態で完成度UP。初回オンボーディング不足 |
| 技術品質 | 70 | 64 | now注入、9テスト、model層gatingは良い。明細パーサとデータ層が弱い |

## Claude's Main Verdict

前回の致命傷だった固定期限、地域無視、空ペイウォールは3/3で本当に潰れている。これはロジック層で確認済み。

ただし完成品基準では、まだ「金を取れる中身」が来ていない。お金エンジンが手書き係数、課金が実決済ではなくプレビュー、AI明細スキャンが正規表現なので、完成品ではなく「よくできたモック」止まり。

## Remaining Fatal Concerns

1. お金エンジンが実在制度に紐づいていない。
   - `childSupport` などのAmountRangeが手書き定数。
   - `sourceLabel` は出典URLではなく、それっぽい文字列。
   - ユーザーが実制度と照合した瞬間に信頼を失うリスク。
2. 課金が実売上につながっていない。
   - Paywallは`_premiumUnlocked`のトグル。
   - ¥1,480/月の表示はあるが、IAP/購入処理がない。
3. AI明細スキャンが正規表現。
   - ホワイトリスト外サービスを捨てる。
   - 年払いを月額として加算する期間正規化バグがある。
4. 自治体データが5件ハードコード。
   - スケールしない。
5. 初回オンボーディングがない。
   - デモ世帯から始まるため、最初の推定額が他人事になる。

## Top Fixes

1. 制度データを実在の値にする。
2. 金額エンジンをデータ駆動へ分離する。
3. 実課金を1本通す。
4. 明細パーサに周期正規化を入れる。
5. 児童手当を最初の実額制度として実装する。
6. 初回オンボーディングを追加する。
7. 期限通知をPlusの核として実装する。
8. confidence値の根拠を文書化またはルール化する。
9. 実回収額入力のUXを強化する。
10. 明細0件、未対応地域、入力未完了の空状態を追加する。

## Claude's Recommended Next Prompt

```text
Gimmeを「表面の穴は全閉」から「製品の心臓を本物にする」フェーズへ進める。

最優先は、金額が実在制度に紐づくこと。次に実課金。AI/通知は本物化。
免責・プライバシー・推定根拠カード・準備/回収分離は現状維持。

【最優先：お金エンジンを実在データ駆動に】
1. lib/data/benefit_rules.dart（またはassets/benefit_rules.json）を新設し、
制度ごとに { id, 計算ルール(関数 or 係数), 一次情報URL, 対象条件, 周期 } を持たせる。
捏造AmountRangeを廃止し、buildOpportunities はこのルールを読むだけにする。

2. まず児童手当を「実在の計算」にする（月額・所得制限・子の年齢区分は公開仕様）。
estimateBasis に必ず一次情報URLを差し込む。最低1制度は完全に本物にすること。

3. cityBenefitProfiles を data 層へ移し、自治体追加=データ追加の構造にする。
ハードコード5件のconst方式をやめる。

【明細パーサを実用化】
4. analyzeSubscriptionStatement に周期正規化を実装。
「年払い/月額/年額」を検出して月額換算してから monthlyTotal に積む（12倍バグ除去）。
ブランド名ホワイトリスト依存をやめ、「サービス名らしき文字列＋金額＋周期」の汎用抽出に変更。未対応サービスを黙って捨てない。

5. unusedSubscriptionMonths のベタ打ち(4/1)を、抽出根拠から推定する式に置換。

【実課金を1本通す】
6. in_app_purchase を導入し、Google Play Billing の商品ID(月額¥1,480)を1個接続。
_premiumUnlocked は「購入が確認できた時のみ true」に縛り、無料トグルを撤去。
Web確認版のみ preview シミュレートを残す（その旨の注記は維持）。

【Plusの核を本物に】
7. flutter_local_notifications で、各候補の実締切日ベースのローカル通知を実装。
「期限通知」を native-ready の口約束から実機能へ。Plus有効時のみ有効化。

【初回コンバージョン】
8. 初回起動時オンボーディング（郵便番号 or 都道府県＋子ども有無＋ローン有無の3問）を追加し、
即「あなたの推定額」を提示。デモ世帯固定の初期状態を廃止。

【品質】
9. confidence の base値(52/72/50/64/42)に根拠コメント or ルール化を付与。
10. 明細スキャン0件/未対応地域/入力未完了の空状態UIを追加。

各変更に flutter test を追加。flutter analyze / test / build web / build apk を pass させる。
児童手当の実額計算には必ずユニットテストを付け、公開仕様の代表ケースで検証すること。
```

## Mari's Read

Claude's review is fair. The previous implementation defects were genuinely fixed, but the product still lacks the hard commercial core. The next meaningful iteration should not add more UI polish first; it should make one real money domain authentic, then connect real billing.
