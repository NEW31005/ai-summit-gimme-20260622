const freeVisibleOpportunityCount = 2;
const childAllowanceSourceLabel = 'こども家庭庁 児童手当制度';
const childAllowanceSourceUrl =
    'https://www.cfa.go.jp/policies/kokoseido/jidouteate/faq/ippan';
const medicalDeductionSourceLabel = '国税庁 医療費控除';
const medicalDeductionSourceUrl =
    'https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1120.htm';

enum OpportunityPeriod {
  oneTime('単発'),
  monthly('月次'),
  yearly('年次');

  const OpportunityPeriod(this.label);

  final String label;
}

class HouseholdProfile {
  const HouseholdProfile({
    required this.city,
    required this.adults,
    required this.children,
    required this.supportedOlderChildren,
    required this.medicalCost,
    required this.monthlySubscriptions,
    required this.subscriptionCount,
    required this.unusedSubscriptionCount,
    required this.unusedSubscriptionMonths,
    required this.hasHomeLoan,
    required this.hasCaregiving,
    required this.recentMove,
  });

  final String city;
  final int adults;
  final int children;
  final int supportedOlderChildren;
  final int medicalCost;
  final int monthlySubscriptions;
  final int subscriptionCount;
  final int unusedSubscriptionCount;
  final int unusedSubscriptionMonths;
  final bool hasHomeLoan;
  final bool hasCaregiving;
  final bool recentMove;

  static const demo = HouseholdProfile(
    city: '東京都杉並区',
    adults: 2,
    children: 2,
    supportedOlderChildren: 1,
    medicalCost: 186000,
    monthlySubscriptions: 16400,
    subscriptionCount: 8,
    unusedSubscriptionCount: 3,
    unusedSubscriptionMonths: 5,
    hasHomeLoan: true,
    hasCaregiving: false,
    recentMove: true,
  );

  HouseholdProfile copyWith({
    String? city,
    int? adults,
    int? children,
    int? supportedOlderChildren,
    int? medicalCost,
    int? monthlySubscriptions,
    int? subscriptionCount,
    int? unusedSubscriptionCount,
    int? unusedSubscriptionMonths,
    bool? hasHomeLoan,
    bool? hasCaregiving,
    bool? recentMove,
  }) {
    return HouseholdProfile(
      city: city ?? this.city,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      supportedOlderChildren:
          supportedOlderChildren ?? this.supportedOlderChildren,
      medicalCost: medicalCost ?? this.medicalCost,
      monthlySubscriptions: monthlySubscriptions ?? this.monthlySubscriptions,
      subscriptionCount: subscriptionCount ?? this.subscriptionCount,
      unusedSubscriptionCount:
          unusedSubscriptionCount ?? this.unusedSubscriptionCount,
      unusedSubscriptionMonths:
          unusedSubscriptionMonths ?? this.unusedSubscriptionMonths,
      hasHomeLoan: hasHomeLoan ?? this.hasHomeLoan,
      hasCaregiving: hasCaregiving ?? this.hasCaregiving,
      recentMove: recentMove ?? this.recentMove,
    );
  }
}

class AmountRange {
  const AmountRange({required this.low, required this.high});

  final int low;
  final int high;

  int get midpoint => ((low + high) / 2).round();

  AmountRange operator *(int multiplier) {
    return AmountRange(low: low * multiplier, high: high * multiplier);
  }
}

class CityBenefitProfile {
  const CityBenefitProfile({
    required this.cityName,
    required this.keywords,
    required this.childSupport,
    required this.schoolPrep,
    required this.moveSupport,
    required this.sourceLabel,
  });

  final String cityName;
  final List<String> keywords;
  final AmountRange childSupport;
  final AmountRange schoolPrep;
  final AmountRange moveSupport;
  final String sourceLabel;
}

const cityBenefitProfiles = <CityBenefitProfile>[
  CityBenefitProfile(
    cityName: '東京都杉並区',
    keywords: ['杉並', '東京都杉並区', '東京'],
    childSupport: AmountRange(low: 42000, high: 92000),
    schoolPrep: AmountRange(low: 18000, high: 54000),
    moveSupport: AmountRange(low: 8000, high: 36000),
    sourceLabel: '杉並区・東京都の子育て/転居関連制度',
  ),
  CityBenefitProfile(
    cityName: '神奈川県横浜市',
    keywords: ['横浜', '神奈川'],
    childSupport: AmountRange(low: 36000, high: 82000),
    schoolPrep: AmountRange(low: 16000, high: 48000),
    moveSupport: AmountRange(low: 6000, high: 30000),
    sourceLabel: '横浜市・神奈川県の子育て/住まい関連制度',
  ),
  CityBenefitProfile(
    cityName: '大阪府大阪市',
    keywords: ['大阪'],
    childSupport: AmountRange(low: 32000, high: 78000),
    schoolPrep: AmountRange(low: 14000, high: 44000),
    moveSupport: AmountRange(low: 6000, high: 28000),
    sourceLabel: '大阪市・大阪府の子育て/転居関連制度',
  ),
  CityBenefitProfile(
    cityName: '北海道札幌市',
    keywords: ['札幌', '北海道'],
    childSupport: AmountRange(low: 28000, high: 72000),
    schoolPrep: AmountRange(low: 12000, high: 40000),
    moveSupport: AmountRange(low: 5000, high: 26000),
    sourceLabel: '札幌市・北海道の子育て/生活支援制度',
  ),
  CityBenefitProfile(
    cityName: '福岡県福岡市',
    keywords: ['福岡'],
    childSupport: AmountRange(low: 30000, high: 76000),
    schoolPrep: AmountRange(low: 13000, high: 42000),
    moveSupport: AmountRange(low: 5000, high: 27000),
    sourceLabel: '福岡市・福岡県の子育て/生活支援制度',
  ),
];

class QuestStep {
  const QuestStep(this.title, this.detail);

  final String title;
  final String detail;
}

class GimmeOpportunity {
  const GimmeOpportunity({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.amountRange,
    required this.period,
    required this.deadline,
    required this.asOf,
    required this.confidence,
    required this.documents,
    required this.steps,
    required this.reason,
    required this.estimateBasis,
    required this.sourceLabel,
    this.plusOnly = false,
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final AmountRange amountRange;
  final OpportunityPeriod period;
  final DateTime deadline;
  final DateTime asOf;
  final int confidence;
  final List<String> documents;
  final List<QuestStep> steps;
  final String reason;
  final String estimateBasis;
  final String sourceLabel;
  final bool plusOnly;

  int get amount => amountRange.midpoint;

  AmountRange get annualizedRange {
    if (period == OpportunityPeriod.monthly) {
      return amountRange * 12;
    }
    return amountRange;
  }

  int get annualizedAmount => annualizedRange.midpoint;

  int get daysLeft {
    final start = DateTime(asOf.year, asOf.month, asOf.day);
    final end = DateTime(deadline.year, deadline.month, deadline.day);
    return end.difference(start).inDays;
  }

  bool get urgent => daysLeft >= 0 && daysLeft <= 14;

  String get confidenceLabel {
    if (confidence >= 82) {
      return '高';
    }
    if (confidence >= 64) {
      return '中';
    }
    return '要確認';
  }
}

List<GimmeOpportunity> buildOpportunities(
  HouseholdProfile profile, {
  DateTime? now,
}) {
  final asOf = _dateOnly(now ?? DateTime.now());
  final cityProfile = cityProfileFor(profile.city);
  final familyRange = childAllowanceAnnualRange(profile);
  final homeLoanRange = profile.hasHomeLoan
      ? const AmountRange(low: 75000, high: 260000)
      : const AmountRange(low: 0, high: 35000);
  final medicalRange = medicalRefundEstimateRange(profile.medicalCost);
  final subscriptionRange = subscriptionSavingRange(profile);
  final monthlyGuardRange = monthlyContinuityRange(profile, subscriptionRange);
  final movingRange = profile.recentMove
      ? cityProfile?.moveSupport ?? const AmountRange(low: 6000, high: 30000)
      : const AmountRange(low: 0, high: 9000);

  final opportunities = <GimmeOpportunity>[
    GimmeOpportunity(
      id: 'family_support',
      title: '児童手当・第3子判定チェック',
      category: '子育て',
      summary: '18〜22歳の生計負担ありの上の子も数え、第3子以降の児童手当増額を見落とさないように確認します。',
      amountRange: familyRange,
      period: OpportunityPeriod.yearly,
      deadline: nextAnnualDeadline(asOf, 9, 30),
      asOf: asOf,
      confidence: confidenceFromInputs(
        base: 72,
        signals: [
          profile.children > 0,
          profile.supportedOlderChildren > 0,
          profile.city.trim().isNotEmpty,
        ],
      ),
      reason: profile.children > 0
          ? '高校生年代までの子ども${profile.children}人、18〜22歳の生計負担あり${profile.supportedOlderChildren}人として、第3子以降の判定を入れています。'
          : '子ども情報が未登録のため、子育て支援は確認候補として扱います。',
      estimateBasis:
          'こども家庭庁の児童手当ルールを基準に、高校生年代までの支給対象児童を年額化しています。第3子以降の判定では、18歳到達後最初の3月31日後から22歳到達後最初の3月31日までの子で、監護相当・生計費負担がある場合も数えます。3歳未満かどうかは未入力のため、第1子・第2子は月1万円〜1万5千円のレンジで表示します。',
      sourceLabel: childAllowanceSourceLabel,
      documents: const ['本人確認', '世帯情報', '振込口座', '監護相当・生計費負担の確認書'],
      steps: const [
        QuestStep('子どもの数え方を確認', '高校生年代までの子と、18〜22歳で生計費を負担している上の子を分けて確認します。'),
        QuestStep('第3子以降の該当を確認', '上の子を含めた出生順で、月3万円の対象になる子がいるか見ます。'),
        QuestStep('確認書を準備', '該当する場合は監護相当・生計費負担の確認書を用意します。'),
        QuestStep('自治体へ提出', '居住地の自治体手続きページで提出期限と添付書類を確認します。'),
      ],
    ),
    GimmeOpportunity(
      id: 'subscription_leak',
      title: '眠ったサブスク解約回収',
      category: '固定費',
      summary: '使っていない定期課金を、契約本数と最終利用月から見つけます。',
      amountRange: subscriptionRange,
      period: OpportunityPeriod.monthly,
      deadline: nextMonthlyDeadline(asOf, 25),
      asOf: asOf,
      confidence: confidenceFromInputs(
        base: 50,
        signals: [
          profile.monthlySubscriptions > 0,
          profile.subscriptionCount > 0,
          profile.unusedSubscriptionCount > 0,
          profile.unusedSubscriptionMonths >= 2,
        ],
      ),
      reason:
          '月額合計${formatYen(profile.monthlySubscriptions)}、契約${profile.subscriptionCount}本、未使用候補${profile.unusedSubscriptionCount}本で算定しています。',
      estimateBasis:
          '月額合計を契約本数で割った平均額に、未使用候補本数を掛けて月次節約レンジを出しています。最終利用から${profile.unusedSubscriptionMonths}か月以上なら優先度を上げます。',
      sourceLabel: 'カード明細/購読履歴',
      documents: const ['カード明細', 'アプリ購読履歴', '年払い更新日', '最終利用メモ'],
      steps: const [
        QuestStep('明細を取り込む', 'カード明細や購読履歴をAI明細スキャンへ貼り付けます。'),
        QuestStep('未使用候補を確認', '最後に使った月、家族利用、仕事利用の有無を確認します。'),
        QuestStep('解約リンクを確認', '各サービスの解約ページを開ける状態にします。'),
        QuestStep('更新日前に止める', '次回課金日が近いものから順に処理します。'),
      ],
    ),
    GimmeOpportunity(
      id: 'monthly_guard',
      title: 'Plus 毎月の取りこぼし監視',
      category: 'Plus',
      summary: '明細スキャン、期限通知、家族共有レポートを毎月回して、翌月以降の固定費漏れを拾い続けます。',
      amountRange: monthlyGuardRange,
      period: OpportunityPeriod.monthly,
      deadline: nextMonthlyDeadline(asOf, 5),
      asOf: asOf,
      confidence: confidenceFromInputs(
        base: 58,
        signals: [
          profile.monthlySubscriptions > 0,
          profile.subscriptionCount >= 3,
          profile.unusedSubscriptionCount > 0,
          profile.children > 0 || profile.hasHomeLoan || profile.hasCaregiving,
        ],
      ),
      reason: '固定費、申請期限、家族イベントを毎月の点検対象にして、単発回収で終わらない継続価値にします。',
      estimateBasis:
          'サブスク削減見込みの一部と、期限通知による申請漏れ防止を月次価値として控えめにレンジ化しています。Plusでは候補追加、通知、証跡保存、家族共有を有料境界にします。',
      sourceLabel: 'Gimme Plus 継続監視',
      plusOnly: true,
      documents: const ['カード明細', 'アプリ購読履歴', '申請期限メモ', '家族共有メモ'],
      steps: const [
        QuestStep('月初スキャン', '明細と購読履歴を取り込み、新規課金と値上げを確認します。'),
        QuestStep('締切通知', '今月中に動くべき申請、解約、更新を通知に並べます。'),
        QuestStep('家族レポート', '誰が何を使っているかを一枚で確認できる状態にします。'),
        QuestStep('成果を記録', '実際に止めた額と申請した額を回収実績へ保存します。'),
      ],
    ),
    GimmeOpportunity(
      id: 'home_loan',
      title: '住宅ローン控除・省エネ補助確認',
      category: '住宅',
      summary: '住宅ローン控除と省エネ関連補助の見落とし候補です。',
      amountRange: homeLoanRange,
      period: OpportunityPeriod.yearly,
      deadline: nextAnnualDeadline(asOf, 12, 31),
      asOf: asOf,
      confidence: confidenceFromInputs(
        base: profile.hasHomeLoan ? 64 : 34,
        signals: [profile.hasHomeLoan, profile.city.trim().isNotEmpty],
      ),
      reason: profile.hasHomeLoan
          ? '住宅ローンありの条件から年末調整/確定申告候補になっています。'
          : '住宅ローンなしのため、関連補助だけを低優先で確認します。',
      estimateBasis:
          '住宅ローン有無、年末の提出期限、省エネ設備の可能性から年次レンジを表示しています。購入年、残高、所得、設備証明で大きく変動します。',
      sourceLabel: '国税/住宅関連制度',
      documents: const ['住宅ローン残高証明', '売買契約書', '省エネ設備の領収書'],
      steps: const [
        QuestStep('住宅条件を確認', '購入年とローン残高の有無を整理します。'),
        QuestStep('控除対象を照合', '控除と補助の両方を重複なく確認します。'),
        QuestStep('証明書を集める', '残高証明と領収書を1か所にまとめます。'),
        QuestStep('提出先を決める', '年末調整か確定申告かを確認します。'),
      ],
    ),
    GimmeOpportunity(
      id: 'medical_deduction',
      title: '医療費控除リカバリー',
      category: '医療',
      summary: '家族の医療費から控除対象になりそうな支出を整理します。',
      amountRange: medicalRange,
      period: OpportunityPeriod.yearly,
      deadline: nextAnnualDeadline(asOf, 3, 15),
      asOf: asOf,
      confidence: confidenceFromInputs(
        base: 42,
        signals: [
          profile.medicalCost > 0,
          profile.medicalCost >= 100000,
          profile.adults + profile.children > 1,
        ],
      ),
      reason:
          '年間医療費 ${formatYen(profile.medicalCost)} をもとに、戻る可能性のある税額を概算しています。',
      estimateBasis:
          '医療費控除は支払った医療費がそのまま戻る制度ではありません。支払医療費から保険金などの補填額と10万円、または総所得200万円未満なら総所得の5%を差し引いた控除額に、所得税率と住民税軽減の目安をかけた年次レンジです。',
      sourceLabel: medicalDeductionSourceLabel,
      documents: const ['医療費明細', '交通費メモ', '薬局レシート', '源泉徴収票'],
      steps: const [
        QuestStep('医療費を分類', '病院、薬局、交通費を分けて集計します。'),
        QuestStep('対象外を除外', '美容目的など対象外の支出を外します。'),
        QuestStep('明細を作る', '家族別に医療費明細を作成します。'),
        QuestStep('申告準備', '控除額の見込みと提出書類を確認します。'),
      ],
    ),
    GimmeOpportunity(
      id: 'moving_rebate',
      title: '引越し後の住所変更・還付チェック',
      category: '生活',
      summary: '引越し後に残りやすい公共料金、保険、自治体手続きの返金候補です。',
      amountRange: movingRange,
      period: OpportunityPeriod.oneTime,
      deadline: nextAnnualDeadline(asOf, 8, 31),
      asOf: asOf,
      confidence: confidenceFromInputs(
        base: profile.recentMove ? 58 : 35,
        signals: [profile.recentMove, cityProfile != null],
      ),
      reason: profile.recentMove
          ? '最近の引越し条件と居住地「${profile.city}」から、還付候補を優先しています。'
          : '引越しなしのため、住所変更確認として低優先で表示しています。',
      estimateBasis: cityProfile == null
          ? '旧住所契約の重複請求、公共料金の日割り返金、保険・通信の住所変更漏れから起きやすい幅を置いています。'
          : '${cityProfile.sourceLabel}と旧住所契約の精算可能性を合わせた単発レンジです。契約先の精算ルールで上下します。',
      sourceLabel: cityProfile?.sourceLabel ?? '契約先精算',
      documents: const ['旧住所の契約情報', '新住所の公共料金', '保険証券'],
      steps: const [
        QuestStep('旧契約を確認', '旧住所に残っている契約を洗い出します。'),
        QuestStep('返金条件を見る', '日割り返金や重複支払いを確認します。'),
        QuestStep('住所変更をまとめる', '保険、銀行、通信、行政の変更を進めます。'),
      ],
    ),
  ];

  if (profile.hasCaregiving) {
    opportunities.add(
      GimmeOpportunity(
        id: 'care_support',
        title: '介護用品・通院支援の申請確認',
        category: '介護',
        summary: '介護用品、通院交通、住宅改修などの支援候補です。',
        amountRange: const AmountRange(low: 24000, high: 96000),
        period: OpportunityPeriod.yearly,
        deadline: nextMonthlyDeadline(asOf, 10),
        asOf: asOf,
        confidence: confidenceFromInputs(
          base: 65,
          signals: [profile.hasCaregiving, profile.city.trim().isNotEmpty],
        ),
        reason: '介護ありの世帯条件に一致しています。',
        estimateBasis:
            '介護区分、通院頻度、用品購入、住宅改修の有無で変動するため、申請可能性のある支援額を年次レンジで表示しています。',
        sourceLabel: '自治体/介護保険',
        documents: const ['介護認定情報', '通院記録', '用品領収書'],
        steps: const [
          QuestStep('介護区分を確認', '認定区分と利用中サービスを整理します。'),
          QuestStep('支援対象を選ぶ', '用品、通院、住宅改修の候補を分けます。'),
          QuestStep('領収書をまとめる', '月ごとの支出を写真またはPDFでまとめます。'),
        ],
      ),
    );
  }

  opportunities.sort(
    (a, b) => opportunityScore(b).compareTo(opportunityScore(a)),
  );
  return opportunities;
}

CityBenefitProfile? cityProfileFor(String city) {
  final normalized = city.trim();
  if (normalized.isEmpty) {
    return null;
  }
  for (final profile in cityBenefitProfiles) {
    if (profile.keywords.any(normalized.contains)) {
      return profile;
    }
  }
  return null;
}

AmountRange childAllowanceAnnualRange(HouseholdProfile profile) {
  if (profile.children <= 0) {
    return const AmountRange(low: 0, high: 0);
  }
  var low = 0;
  var high = 0;
  for (var index = 1; index <= profile.children; index++) {
    final birthOrder = profile.supportedOlderChildren + index;
    if (birthOrder >= 3) {
      low += 30000 * 12;
      high += 30000 * 12;
    } else {
      low += 10000 * 12;
      high += 15000 * 12;
    }
  }
  return AmountRange(low: low, high: high);
}

AmountRange subscriptionSavingRange(HouseholdProfile profile) {
  if (profile.monthlySubscriptions <= 0 ||
      profile.subscriptionCount <= 0 ||
      profile.unusedSubscriptionCount <= 0) {
    return const AmountRange(low: 0, high: 0);
  }
  final subscriptionCount = profile.subscriptionCount.clamp(1, 80);
  final unusedCount = profile.unusedSubscriptionCount.clamp(
    0,
    subscriptionCount,
  );
  final averageMonthly = (profile.monthlySubscriptions / subscriptionCount)
      .round();
  final base = averageMonthly * unusedCount;
  final staleBoost = profile.unusedSubscriptionMonths >= 4 ? 1.25 : 1.0;
  return AmountRange(
    low: (base * 0.75).round(),
    high: (base * staleBoost * 1.35).round(),
  );
}

AmountRange monthlyContinuityRange(
  HouseholdProfile profile,
  AmountRange subscriptionRange,
) {
  final subscriptionFloor = (subscriptionRange.low * 0.25).round();
  final subscriptionCeiling = (subscriptionRange.high * 0.55).round();
  final eventBoost =
      (profile.children > 0 ? 1200 : 0) +
      (profile.hasHomeLoan ? 900 : 0) +
      (profile.hasCaregiving ? 900 : 0) +
      (profile.recentMove ? 700 : 0);
  final low = subscriptionFloor + (eventBoost * 0.6).round();
  final high = subscriptionCeiling + eventBoost + 1800;
  return AmountRange(
    low: low.clamp(0, 50000).toInt(),
    high: high.clamp(0, 80000).toInt(),
  );
}

int medicalDeductionAmount(
  int medicalCost, {
  int insuranceReimbursement = 0,
  int? totalIncome,
}) {
  final netMedicalCost = (medicalCost - insuranceReimbursement)
      .clamp(0, 1 << 31)
      .toInt();
  final floor = totalIncome != null && totalIncome < 2000000
      ? (totalIncome * 0.05).round()
      : 100000;
  return (netMedicalCost - floor).clamp(0, 2000000).toInt();
}

AmountRange medicalRefundEstimateRange(
  int medicalCost, {
  int insuranceReimbursement = 0,
  int? totalIncome,
}) {
  final taxableDeduction = medicalDeductionAmount(
    medicalCost,
    insuranceReimbursement: insuranceReimbursement,
    totalIncome: totalIncome,
  );
  if (taxableDeduction <= 0) {
    return const AmountRange(low: 0, high: 0);
  }
  return AmountRange(
    low: (taxableDeduction * 0.15).round(),
    high: (taxableDeduction * 0.33).round(),
  );
}

int medicalDeductionEstimate(int medicalCost) {
  return medicalRefundEstimateRange(medicalCost).midpoint;
}

int confidenceFromInputs({required int base, required List<bool> signals}) {
  final score = base + signals.where((signal) => signal).length * 8;
  return score.clamp(20, 96);
}

DateTime nextAnnualDeadline(DateTime now, int month, int day) {
  final current = DateTime(now.year, month, day);
  if (!current.isBefore(_dateOnly(now))) {
    return current;
  }
  return DateTime(now.year + 1, month, day);
}

DateTime nextMonthlyDeadline(DateTime now, int day) {
  final targetDay = day.clamp(1, 28);
  final current = DateTime(now.year, now.month, targetDay);
  if (!current.isBefore(_dateOnly(now))) {
    return current;
  }
  final nextMonth = now.month == 12
      ? DateTime(now.year + 1, 1, targetDay)
      : DateTime(now.year, now.month + 1, targetDay);
  return nextMonth;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

int opportunityScore(GimmeOpportunity opportunity) {
  final urgencyBoost = (45 - opportunity.daysLeft).clamp(0, 45) * 1200;
  final sourceBoost = opportunity.sourceLabel == '全国共通制度' ? 0 : 12000;
  return opportunity.annualizedAmount +
      urgencyBoost +
      opportunity.confidence * 400 +
      sourceBoost;
}

List<GimmeOpportunity> visibleOpportunities(
  List<GimmeOpportunity> opportunities, {
  required bool premiumUnlocked,
}) {
  if (premiumUnlocked) {
    return opportunities;
  }
  return opportunities.take(freeVisibleOpportunityCount).toList();
}

int lockedOpportunityCount(
  List<GimmeOpportunity> opportunities, {
  required bool premiumUnlocked,
}) {
  if (premiumUnlocked) {
    return 0;
  }
  return (opportunities.length - freeVisibleOpportunityCount).clamp(0, 999);
}

AmountRange annualizedPotentialRange(List<GimmeOpportunity> opportunities) {
  return opportunities.fold(
    const AmountRange(low: 0, high: 0),
    (sum, item) => AmountRange(
      low: sum.low + item.annualizedRange.low,
      high: sum.high + item.annualizedRange.high,
    ),
  );
}

int annualizedPotential(List<GimmeOpportunity> opportunities) {
  return annualizedPotentialRange(opportunities).midpoint;
}

int preparedAmount(
  List<GimmeOpportunity> opportunities,
  Set<String> completedKeys,
) {
  return opportunities
      .where((opportunity) => isQuestComplete(opportunity, completedKeys))
      .fold(0, (sum, opportunity) => sum + opportunity.annualizedAmount);
}

int actualRecoveredAmount(Map<String, int> actualRecovered) {
  return actualRecovered.values.fold(0, (sum, amount) => sum + amount);
}

double questProgress(GimmeOpportunity opportunity, Set<String> completedKeys) {
  if (opportunity.steps.isEmpty) {
    return 0;
  }
  final completed = Iterable<int>.generate(opportunity.steps.length)
      .where((index) => completedKeys.contains(stepKey(opportunity.id, index)))
      .length;
  return completed / opportunity.steps.length;
}

bool isQuestComplete(GimmeOpportunity opportunity, Set<String> completedKeys) {
  return questProgress(opportunity, completedKeys) >= 1;
}

int urgentCount(List<GimmeOpportunity> opportunities) {
  return opportunities.where((opportunity) => opportunity.urgent).length;
}

String stepKey(String opportunityId, int index) => '$opportunityId:$index';

String actualRecoveredKey(String opportunityId) =>
    'actualRecovered:$opportunityId';

String formatYen(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final reverseIndex = text.length - i;
    buffer.write(text[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return '$buffer円';
}

String formatYenRange(AmountRange range) {
  if (range.low == range.high) {
    return formatYen(range.low);
  }
  return '${formatYen(range.low)}〜${formatYen(range.high)}';
}

String formatTeaserAmount(int amount) {
  if (amount >= 10000) {
    return '約${(amount / 10000).round()}万円候補';
  }
  return '約${(amount / 1000).round()}千円候補';
}

String formatDeadline(DateTime deadline) {
  return '${deadline.year}/${deadline.month.toString().padLeft(2, '0')}/${deadline.day.toString().padLeft(2, '0')}';
}

enum SubscriptionBillingPeriod { monthly, yearly, weekly, quarterly, unknown }

class SubscriptionScanItem {
  const SubscriptionScanItem({
    required this.name,
    required this.amount,
    required this.rawAmount,
    required this.periodLabel,
    required this.confidence,
    required this.reason,
    required this.likelyUnused,
  });

  final String name;
  final int amount;
  final int rawAmount;
  final String periodLabel;
  final int confidence;
  final String reason;
  final bool likelyUnused;
}

class SubscriptionScanResult {
  const SubscriptionScanResult({
    required this.items,
    required this.monthlyTotal,
    required this.likelyUnusedCount,
  });

  final List<SubscriptionScanItem> items;
  final int monthlyTotal;
  final int likelyUnusedCount;

  bool get hasData => items.isNotEmpty;
}

SubscriptionScanResult analyzeSubscriptionStatement(String text) {
  final lines = text
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  final items = <SubscriptionScanItem>[];
  final amountPattern = RegExp(
    r'(?:¥|￥)?\s*([0-9]{1,3}(?:,[0-9]{3})+|[0-9]{3,7})\s*(?:円|JPY)?',
  );
  for (final line in lines) {
    final amountMatch = amountPattern.firstMatch(line);
    if (amountMatch == null) {
      continue;
    }
    final rawAmount =
        int.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0;
    if (rawAmount <= 0 || rawAmount > 600000) {
      continue;
    }
    final name = _extractSubscriptionName(line);
    if (name.length < 2 || _looksLikeNonSubscription(line)) {
      continue;
    }
    final period = _detectSubscriptionBillingPeriod(line);
    final knownMerchant = _looksLikeKnownSubscription(line);
    final amount = _monthlyEquivalent(rawAmount, period, knownMerchant);
    if (amount <= 0) {
      continue;
    }
    final likelyUnused = RegExp(
      r'(未使用|使ってない|解約|年払い|trial|トライアル|storage|old|放置)',
      caseSensitive: false,
    ).hasMatch(line);
    final confidence =
        (knownMerchant ? 72 : 54) +
        (period == SubscriptionBillingPeriod.unknown ? 0 : 12) +
        (likelyUnused ? 8 : 0);
    items.add(
      SubscriptionScanItem(
        name: name,
        amount: amount,
        rawAmount: rawAmount,
        periodLabel: _periodLabel(period),
        confidence: confidence.clamp(30, 96).toInt(),
        reason: likelyUnused
            ? '未使用・年払い・放置の可能性あり。月換算で確認してください。'
            : period == SubscriptionBillingPeriod.unknown
            ? '周期未確定の定期課金候補。前後月で継続性を確認してください。'
            : '${_periodLabel(period)}の定期課金候補',
        likelyUnused: likelyUnused,
      ),
    );
  }
  final monthlyTotal = items.fold(0, (sum, item) => sum + item.amount);
  final likelyUnusedCount = items.where((item) => item.likelyUnused).length;
  return SubscriptionScanResult(
    items: items,
    monthlyTotal: monthlyTotal,
    likelyUnusedCount: likelyUnusedCount,
  );
}

String _extractSubscriptionName(String line) {
  final cleaned = line
      .replaceAll(
        RegExp(r'(?:¥|￥)?\s*[0-9]{1,3}(?:,[0-9]{3})+\s*(?:円|JPY)?'),
        '',
      )
      .replaceAll(RegExp(r'(?:¥|￥)?\s*[0-9]{3,7}\s*(?:円|JPY)?'), '')
      .replaceAll(RegExp(r'[-_/|:：]+'), ' ')
      .trim();
  if (cleaned.isEmpty) {
    return '定期課金';
  }
  final parts = cleaned.split(RegExp(r'\s+'));
  return parts.take(3).join(' ');
}

bool _looksLikeKnownSubscription(String line) {
  return RegExp(
    r'(netflix|spotify|youtube|icloud|dropbox|notion|canva|adobe|amazon|prime|chatgpt|claude|gemini|grok|apple|google|microsoft|slack|zoom|storage|subscription|サブスク|定期|購読|月額|年額|年払い)',
    caseSensitive: false,
  ).hasMatch(line);
}

bool _looksLikeNonSubscription(String line) {
  return RegExp(
    r'(スーパー|コンビニ|ガソリン|交通系|suica|pasmo|icoca|食料品|レストラン|現金|振込|給与|返金)',
    caseSensitive: false,
  ).hasMatch(line);
}

SubscriptionBillingPeriod _detectSubscriptionBillingPeriod(String line) {
  if (RegExp(
    r'(年額|年払い|年間|annual|annually|yearly)',
    caseSensitive: false,
  ).hasMatch(line)) {
    return SubscriptionBillingPeriod.yearly;
  }
  if (RegExp(r'(週額|weekly|week)', caseSensitive: false).hasMatch(line)) {
    return SubscriptionBillingPeriod.weekly;
  }
  if (RegExp(
    r'(四半期|3か月|3ヶ月|quarter|quarterly)',
    caseSensitive: false,
  ).hasMatch(line)) {
    return SubscriptionBillingPeriod.quarterly;
  }
  if (RegExp(
    r'(月額|月払い|毎月|monthly|month)',
    caseSensitive: false,
  ).hasMatch(line)) {
    return SubscriptionBillingPeriod.monthly;
  }
  return SubscriptionBillingPeriod.unknown;
}

int _monthlyEquivalent(
  int rawAmount,
  SubscriptionBillingPeriod period,
  bool knownMerchant,
) {
  switch (period) {
    case SubscriptionBillingPeriod.yearly:
      return (rawAmount / 12).round();
    case SubscriptionBillingPeriod.weekly:
      return (rawAmount * 52 / 12).round();
    case SubscriptionBillingPeriod.quarterly:
      return (rawAmount / 3).round();
    case SubscriptionBillingPeriod.monthly:
      return rawAmount;
    case SubscriptionBillingPeriod.unknown:
      return knownMerchant || rawAmount <= 50000 ? rawAmount : 0;
  }
}

String _periodLabel(SubscriptionBillingPeriod period) {
  switch (period) {
    case SubscriptionBillingPeriod.monthly:
      return '月額';
    case SubscriptionBillingPeriod.yearly:
      return '年額を月換算';
    case SubscriptionBillingPeriod.weekly:
      return '週額を月換算';
    case SubscriptionBillingPeriod.quarterly:
      return '四半期を月換算';
    case SubscriptionBillingPeriod.unknown:
      return '周期未確定';
  }
}
