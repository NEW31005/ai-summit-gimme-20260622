# Gimme 80+ Implementation Prompt

あなたはGimmeの実装担当です。検証用MVPではなく、Claudeレビューの全項目80点超えを狙う完成品品質へ作り直してください。

対象プロジェクト:

`C:\dev\summit_2026_06_25_frame2_genre_002`

参照仕様:

`C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\app\02_spec\gimme-80plus-redesign-spec.md`

## 絶対方針

- GimmeはAndroid/iOSネイティブモバイルアプリが正式リリース対象です。
- Flutter Webはスマホ確認用の公開HTTPSプレビューです。
- 制度金額を雰囲気や手書きレンジで出さないでください。
- 公式出典URL、確認日、計算式、入力不足を候補詳細に必ず表示してください。
- AIっぽくないUIとは見た目と操作感の話です。AI機能やAI補助アイデアは使って構いません。
- ただし制度判定と金額計算をAI任せにしないでください。制度金額はルールエンジンで決めてください。
- `_premiumUnlocked`のような無料トグルでPlusを解除しないでください。Web previewだけ明示的な疑似解放を許可してください。

## 最優先修正

1. `cityBenefitProfiles`の手書きAmountRangeを廃止する。
2. `SourceCitation`、`CalculationTrace`、`EligibilityResult`、`BenefitRule`を追加する。
3. 児童手当を公式ルールで実装する。
4. 医療費控除を公式式で実装する。
5. サブスク明細スキャンに周期正規化を入れる。
6. 初回オンボーディングを追加し、デモ世帯開始を廃止する。
7. 候補詳細に公式出典、計算過程、入力不足、信頼度理由を表示する。
8. 課金状態を`EntitlementRepository`に分離する。
9. Plus価値を全候補、無制限スキャン、期限通知、根拠付きレポートに接続する。
10. テストを追加し、`flutter analyze`、`flutter test`、`flutter build web`を通す。

## 公式ソース

- 児童手当: `https://www.cfa.go.jp/policies/kokoseido/jidouteate/annai`
- 児童手当改正: `https://www.cfa.go.jp/policies/kokoseido/jidouteate/mottoouen`
- 医療費控除: `https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1120.htm`
- 住宅ローン控除: `https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1.htm`
- Android課金: `https://developer.android.com/google/play/billing/subscriptions`
- iOS課金: `https://developer.apple.com/app-store/subscriptions/`

## 児童手当ルール

- 0歳から18歳到達後最初の3月31日までが対象。
- 3歳未満は月15,000円。
- 3歳以上高校生年代までは月10,000円。
- 第3子以降は月30,000円。
- 支給月は2月、4月、6月、8月、10月、12月。
- 出生・転入時は15日以内申請の注意を出す。

## 医療費控除ルール

控除額:

```text
実際に支払った医療費 - 保険金等で補てんされる金額 - 10万円
```

ただし総所得金額等が200万円未満の場合は、10万円ではなく総所得金額等の5%を差し引く。控除額上限は200万円。

税率未入力では還付額と言い切らず、控除額として表示する。税率入力時のみ還付目安を出す。

## サブスク明細スキャン

年額・月額のバグを必ず直す。

- 年額: `amount / 12`
- 週額: `amount * 52 / 12`
- 四半期: `amount / 3`
- 月額: そのまま
- 不明: 合算しないで確認待ち

未知サービス名を捨てない。金額、周期語、継続課金語から候補化する。

## UI

初回起動:

1. 地域
2. 家族構成
3. お金の兆候

ホーム:

- 根拠あり候補
- 確認待ち候補
- 入力不足候補
- 期限が近い候補

候補詳細:

- 金額
- 計算式
- 出典URL
- 確認日
- 信頼度理由
- 入力不足
- 次の行動

## 合格基準

- 手書き制度金額レンジが残っていない。
- 児童手当と医療費控除が公式ソース付きで動く。
- 年額サブスクを月額として二重計上しない。
- Plus解除が購入状態またはWeb previewに限定される。
- 初回オンボーディングがある。
- 候補詳細に公式根拠が見える。
- `flutter analyze`成功。
- `flutter test`成功。
- `flutter build web`成功。
- 公開HTTPSプレビューでスマホ幅表示が崩れない。

完成後、変更内容、未解決リスク、テスト結果、公開URLを報告してください。
