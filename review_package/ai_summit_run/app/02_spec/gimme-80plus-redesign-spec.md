# Gimme 80+ Redesign Spec

作成日: 2026-06-23  
対象: `C:\dev\summit_2026_06_25_frame2_genre_002`  
目的: Claude最終レビューで残った根本課題を潰し、総合・ヒット可能性・マネタイズ・UI/UX・技術品質の全項目で80点超えを狙う。

## 1. 結論

Gimmeは「もらい損ねを雰囲気で見せる家計アプリ」から、「一次情報に紐づいた世帯別リカバリー台帳」へ作り替える。

最優先はUI追加ではない。信頼できる金額・根拠・課金・初回体験を入れる。

Claudeの最終指摘に対する設計方針:

| 指摘 | 80点超え設計 |
|---|---|
| 金額エンジンが手書き | `BenefitRule`と公式出典URLを持つデータ駆動ルールへ移行 |
| 課金がトグル | `EntitlementState`をIAP購入状態からのみ解除。Webだけ明示的なプレビュー |
| AIスキャンが正規表現風 | 明細行モデル、周期正規化、信頼度、ユーザー確認フローに分解 |
| 自治体データが5件固定 | 自治体は「未検証なら金額を出さない」。国制度から本物化して拡張 |
| オンボーディングがない | 初回3ステップで世帯条件を取得し、デモ世帯開始を廃止 |

## 2. 80点超えの採点目標

| 項目 | 現状 | 目標 | 上げる理由 |
|---|---:|---:|---|
| 総合 | 63 | 84 | 制度根拠・課金・オンボーディングが商品として接続される |
| ヒット可能性 | 58 | 82 | 「今いくら戻るか」が家族条件で具体化される |
| マネタイズ | 52 | 84 | Plusの価値が期限通知・無制限スキャン・根拠レポートに変わる |
| UI/UX | 76 | 85 | 初回導線、空状態、根拠ドリルダウンで普通の完成品になる |
| 技術品質 | 70 | 85 | ルールエンジン、テスト、課金分離、周期正規化が入る |

## 3. 商品定義

### 新しい一言

「うちが今、申請・控除・見直しで取り戻せるお金を、根拠付きで毎月見つけるアプリ」

### 初期ターゲット

- 子育て世帯
- 医療費やサブスク支出がある世帯
- 引っ越し、出産、進学、住宅購入など生活イベントが近い世帯

### 最初に勝つ領域

広く浅い制度一覧ではなく、最初は次の3本に絞る。

1. 児童手当: 公式金額で正確に計算する最初の本物ルール
2. 医療費控除: 公式計算式に基づく控除額、または税率入力後の還付目安
3. サブスク見直し: 明細スキャンの周期正規化で実際の月額漏れを見つける

住宅ローン控除と自治体制度は、初期では「公式要件チェックリスト」まで。金額計算は入力項目とルール表が揃うまで出さない。

## 4. 公式根拠として使う一次情報

2026-06-23時点で確認した一次情報:

- 児童手当: こども家庭庁「児童手当制度のご案内」  
  `https://www.cfa.go.jp/policies/kokoseido/jidouteate/annai`
- 児童手当改正後の支給額・支給時期: こども家庭庁「もっと子育て応援！児童手当」  
  `https://www.cfa.go.jp/policies/kokoseido/jidouteate/mottoouen`
- 医療費控除: 国税庁「No.1120 医療費を支払ったとき（医療費控除）」  
  `https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1120.htm`
- 住宅ローン控除: 国税庁「No.1211-1 令和4年以降に居住の用に供した場合」  
  `https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1.htm`
- Androidサブスク課金: Android Developers「About subscriptions / Play Billing」  
  `https://developer.android.com/google/play/billing/subscriptions`
- iOSサブスク課金: Apple Developer「Auto-renewable subscriptions」  
  `https://developer.apple.com/app-store/subscriptions/`

アプリ内では各候補に「出典」「確認日」「計算式」「入力不足」を必ず出す。

## 5. データ設計

### 5.1 世帯プロフィール

```dart
class HouseholdProfile {
  final String? postalCode;
  final String? prefecture;
  final String? city;
  final List<ChildProfile> children;
  final int? annualMedicalPaid;
  final int? medicalInsuranceReimbursement;
  final int? totalIncome;
  final int? marginalTaxRatePercent;
  final List<StatementLine> statementLines;
  final HousingLoanProfile? housingLoan;
}
```

### 5.2 制度ルール

```dart
class BenefitRule {
  final String id;
  final String title;
  final BenefitCategory category;
  final Jurisdiction jurisdiction;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final List<SourceCitation> sources;
  final EligibilityResult Function(HouseholdProfile profile) evaluate;
}

class SourceCitation {
  final String title;
  final String url;
  final DateTime checkedAt;
  final String quotedBasis;
}

class CalculationTrace {
  final List<String> formulaSteps;
  final List<String> assumptions;
  final List<String> missingInputs;
  final int confidence;
}
```

### 5.3 候補カード

```dart
class GimmeOpportunity {
  final String ruleId;
  final String title;
  final EligibilityStatus status;
  final MoneyRange? amountRange;
  final CalculationTrace trace;
  final List<SourceCitation> sources;
  final DateTime sourceCheckedAt;
  final bool requiresUserConfirmation;
}
```

`sourceLabel`だけの表示は禁止。必ずURL付きの`SourceCitation`を持たせる。

## 6. 金額エンジン

### 6.1 児童手当

最初に完全実装する本物制度。

ルール:

- 0歳から18歳到達後最初の3月31日までの児童を対象にする
- 3歳未満: 月15,000円
- 3歳以上高校生年代まで: 月10,000円
- 第3子以降: 月30,000円
- 支給月は偶数月、前月分まで2か月分
- 出生・転入時は15日以内の申請注意を出す

出力:

- 月額
- 年額
- 次回支給月
- 申請が必要になりやすいケース
- 出典URL

### 6.2 医療費控除

国税庁の式をそのままルール化する。

控除額:

```text
控除額 = 実際に支払った医療費 - 保険金等で補てんされる金額 - 10万円
ただし総所得金額等が200万円未満の場合は、10万円ではなく総所得金額等の5%
上限200万円
```

注意:

- 「還付額」と「控除額」を混同しない
- 税率未入力なら「控除額」だけ表示
- 税率入力後のみ「還付目安」を表示
- 領収書5年保管、医療費控除明細書の作成導線を表示

### 6.3 サブスク明細スキャン

正規表現の単純合算を廃止し、明細行モデルにする。

```dart
enum BillingPeriod { monthly, yearly, weekly, quarterly, oneTime, unknown }

class StatementLine {
  final String merchantName;
  final int rawAmount;
  final BillingPeriod period;
  final int monthlyEquivalent;
  final int confidence;
  final bool requiresConfirmation;
}
```

周期正規化:

- 年額: `amount / 12`
- 週額: `amount * 52 / 12`
- 四半期: `amount / 3`
- 月額: そのまま
- 不明: 月額合算に入れず、確認待ちにする

ブランドホワイトリスト依存は禁止。未知のサービス名でも「金額 + 周期語 + 継続課金語」で候補に残す。

### 6.4 住宅ローン控除

初期は金額の自動算出を無理に出さない。

出すもの:

- 要件チェックリスト
- 入力不足
- 公式ページへの導線
- 年末残高、居住開始日、床面積、所得、住宅区分が揃った場合だけ概算候補へ昇格

## 7. 課金設計

### 7.1 無料

- 初回オンボーディング
- 児童手当の年額計算
- 医療費控除の控除額計算
- サブスク明細スキャン月1回
- 上位2件の候補表示

### 7.2 Gimme Plus

月額: 1,480円を初期仮説。ストア設定後に確定。

Plus価値:

- 全候補表示
- 無制限サブスクスキャン
- 期限通知
- 世帯メンバー追加
- 公式根拠付きPDF/共有レポート
- 年間リカバリーレポート
- 制度更新の再診断

### 7.3 実装

```dart
abstract class EntitlementRepository {
  Future<EntitlementState> load();
  Stream<EntitlementState> watch();
  Future<void> restorePurchases();
}

class StoreEntitlementRepository implements EntitlementRepository {
  // in_app_purchase / Google Play Billing / StoreKit
}

class PreviewEntitlementRepository implements EntitlementRepository {
  // Web preview only. 常に画面上に「確認用プレビュー」と表示する。
}
```

禁止:

- `_premiumUnlocked`を設定画面のトグルで変える
- Webの疑似課金を本番課金に見せる
- 購入状態なしにPlus機能を恒久解放する

## 8. 初回オンボーディング

デモ世帯スタートを廃止する。

1. 住んでいる地域  
   郵便番号、都道府県、市区町村。未入力なら全国制度だけ診断。
2. 家族構成  
   子どもの生年月日、扶養または経済的負担のある兄姉等。
3. お金の兆候  
   医療費、保険補てん、サブスク明細貼り付け、住宅ローン有無。

初回完了後、最初の画面に「根拠あり候補」「確認待ち候補」「入力不足候補」を分けて出す。

## 9. UI/UX

### ホーム

- 今日の見込み回収額
- 根拠あり候補数
- 期限が近い候補
- 入力不足で止まっている候補

### 候補詳細

- 金額
- なぜ対象っぽいか
- 計算過程
- 公式出典
- 次にやること
- 不足している入力
- ユーザー確認ボタン

### 空状態

- 対象制度なし: 「今は根拠付き候補がありません。医療費または明細を追加すると再診断できます」
- 未対応地域: 「全国制度のみ診断中。自治体制度は根拠データ追加後に表示します」
- 明細0件: 「サービス名と金額は読めませんでした。コピー範囲を広げて再貼り付けしてください」
- 入力不足: 「子どもの生年月日があると児童手当を正確に出せます」

## 10. AI利用

AI生成アイデアは問題ないが、制度判定はAI任せにしない。

役割分担:

- 制度金額: ルールエンジン
- 明細読み取り: ローカルパーサー優先
- AI: 曖昧な明細名の分類補助、説明文の自然化、入力不足の案内

プライバシー:

- 世帯情報はローカル保存を基本
- AI送信はオプトイン
- 明細送信時は氏名、カード番号、住所、口座情報をマスク

## 11. 通知

Plusの中核機能として、ローカル通知を実装する。

通知例:

- 出生・転入から15日以内の児童手当申請注意
- 医療費控除の年末整理
- 確定申告時期のリマインド
- サブスク更新日前の見直し
- 住宅ローン控除の書類確認

サーバー通知は初期必須ではない。Android/iOSネイティブ移行を前提にローカル通知から開始する。

## 12. 実装フェーズ

### Phase 1: 信頼の土台

- `lib/data/benefit_rules.dart`を追加
- `SourceCitation`、`CalculationTrace`、`EligibilityResult`を追加
- 児童手当を公式ルールで実装
- 医療費控除を公式式で実装
- `cityBenefitProfiles`の手書き金額を廃止
- 明細スキャンに周期正規化を実装
- 初回オンボーディングを実装
- 単体テストを追加

### Phase 2: 課金の本物化

- `in_app_purchase`を導入
- `EntitlementRepository`へ分離
- AndroidはGoogle Play Billing、iOSはStoreKitを前提に商品IDを設計
- Webはプレビュー専用の疑似解放に限定
- Plusゲートを候補数、通知、レポート、無制限スキャンへ接続

### Phase 3: ネイティブ価値

- ローカル通知
- 年間リカバリーレポート
- 家族プロフィール
- PDF/共有レポート

### Phase 4: 自治体拡張

- 自治体制度JSONを追加
- 各ルールに公式URL、確認日、有効期間、金額式を持たせる
- 未確認制度は金額を出さず、公式ページチェックリストに止める

## 13. テスト基準

最低限追加するテスト:

- 児童手当
  - 2歳は月15,000円
  - 3歳以上高校生年代は月10,000円
  - 第3子以降は月30,000円
  - 対象年齢外は対象外
- 医療費控除
  - 10万円控除
  - 所得200万円未満の5%控除
  - 保険補てん差し引き
  - 上限200万円
- サブスクスキャン
  - 年額を12分割する
  - 週額を月額換算する
  - 不明周期は合算しない
  - 未知サービス名を捨てない
- 課金
  - Store entitlementなしではPlus不可
  - Web previewだけ疑似解放可
- UI
  - オンボーディング未完了ならホームへ入らない
  - 根拠URLが候補詳細に表示される
  - 入力不足候補が空状態として崩れない

## 14. 完成判定

80点超えの最低ライン:

- 手書きの制度金額レンジが残っていない
- 児童手当と医療費控除が公式ソース付きで動く
- サブスク明細の年額・月額バグがない
- Plus解除が購入状態またはWeb previewに限定されている
- 初回オンボーディングがある
- 候補詳細に出典、計算式、確認日、入力不足がある
- `flutter analyze`が通る
- `flutter test`が通る
- `flutter build web`が通る
- 公開HTTPSプレビューでスマホ幅表示が崩れない

## 15. 実装優先順位

1. 手書き制度金額の削除
2. 児童手当の公式ルール化
3. 医療費控除の公式ルール化
4. 明細スキャンの周期正規化
5. オンボーディング
6. 根拠付き候補詳細
7. 課金分離
8. 通知
9. レポート
10. 自治体制度拡張

この順番で進めれば、見た目だけの改善ではなく、クロエの低評価理由そのものを消せる。
