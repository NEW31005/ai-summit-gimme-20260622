const freeVisibleOpportunityCount = 3;

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
  final familyRange = _familySupportRange(profile, cityProfile);
  final homeLoanRange = profile.hasHomeLoan
      ? const AmountRange(low: 75000, high: 260000)
      : const AmountRange(low: 0, high: 35000);
  final medicalRange = medicalRefundEstimateRange(profile.medicalCost);
  final subscriptionRange = subscriptionSavingRange(profile);
  final movingRange = profile.recentMove
      ? cityProfile?.moveSupport ?? const AmountRange(low: 6000, high: 30000)
      : const AmountRange(low: 0, high: 9000);

  final opportunities = <GimmeOpportunity>[
    GimmeOpportunity(
      id: 'family_support',
      title: cityProfile == null
          ? '子育て世帯サポート確認'
          : '${cityProfile.cityName} 子育て支援差額',
      category: '子育て',
      summary: cityProfile == null
          ? '全国共通の児童関連支援と学校準備費の取りこぼし候補です。'
          : '${cityProfile.sourceLabel}から、世帯条件に合う候補を優先表示しています。',
      amountRange: familyRange,
      period: OpportunityPeriod.yearly,
      deadline: nextAnnualDeadline(asOf, 9, 30),
      asOf: asOf,
      confidence: confidenceFromInputs(
        base: cityProfile == null ? 52 : 72,
        signals: [
          profile.children > 0,
          cityProfile != null,
          profile.city.trim().isNotEmpty,
        ],
      ),
      reason: profile.children > 0
          ? '子ども${profile.children}人、居住地「${profile.city}」の条件で照合しています。'
          : '子ども情報が未登録のため、子育て支援は確認候補として扱います。',
      estimateBasis: cityProfile == null
          ? '居住地が地域テーブルに未登録のため、全国共通の児童関連支援と学校準備費を低めのレンジで表示しています。地域を登録済みエリアに変更すると自治体候補が反映されます。'
          : '${cityProfile.sourceLabel}をもとに、子どもの人数、学校準備費、年度内締切を反映した年次レンジです。所得条件と学年で対象可否が変わります。',
      sourceLabel: cityProfile?.sourceLabel ?? '全国共通制度',
      documents: const ['本人確認', '世帯情報', '振込口座', '学校/保育関連書類'],
      steps: const [
        QuestStep('世帯情報を確認', '子どもの年齢、学年、居住地が条件に合うか確認します。'),
        QuestStep('対象制度を選ぶ', '自治体ページで今年度の名称、所得条件、受付期限を確認します。'),
        QuestStep('必要書類をそろえる', '口座情報と世帯確認書類を準備します。'),
        QuestStep('申請前チェック', '入力漏れ、添付漏れ、提出期限を見直します。'),
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
          '医療費控除は支払った医療費がそのまま戻る制度ではありません。対象医療費から基準額を引いた控除額に、所得税率・住民税影響をかけた還付/軽減見込みを年次レンジで表示しています。',
      sourceLabel: '国税/確定申告',
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

AmountRange _familySupportRange(
  HouseholdProfile profile,
  CityBenefitProfile? cityProfile,
) {
  if (profile.children <= 0) {
    return const AmountRange(low: 0, high: 12000);
  }
  final nationalLow = 18000 * profile.children;
  final nationalHigh = 42000 * profile.children;
  if (cityProfile == null) {
    return AmountRange(low: nationalLow, high: nationalHigh);
  }
  return AmountRange(
    low:
        nationalLow + cityProfile.childSupport.low + cityProfile.schoolPrep.low,
    high:
        nationalHigh +
        cityProfile.childSupport.high +
        cityProfile.schoolPrep.high,
  );
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

AmountRange medicalRefundEstimateRange(int medicalCost) {
  if (medicalCost <= 100000) {
    return const AmountRange(low: 0, high: 9000);
  }
  final taxableDeduction = medicalCost - 100000;
  return AmountRange(
    low: (taxableDeduction * 0.05).round(),
    high: (taxableDeduction * 0.20).round(),
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

class SubscriptionScanItem {
  const SubscriptionScanItem({
    required this.name,
    required this.amount,
    required this.reason,
    required this.likelyUnused,
  });

  final String name;
  final int amount;
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
    r'(?:¥|￥)?\s*([0-9]{1,3}(?:,[0-9]{3})+|[0-9]{3,6})\s*(?:円|JPY)?',
  );
  final knownWords = RegExp(
    r'(netflix|spotify|youtube|icloud|dropbox|notion|canva|adobe|amazon|prime|chatgpt|claude|gemini|grok|apple|google|microsoft|slack|zoom|storage|サブスク|年払い|月額|定期|購読|subscription)',
    caseSensitive: false,
  );
  for (final line in lines) {
    final amountMatch = amountPattern.firstMatch(line);
    if (amountMatch == null || !knownWords.hasMatch(line)) {
      continue;
    }
    final amount = int.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      continue;
    }
    final name = _extractSubscriptionName(line);
    final likelyUnused = RegExp(
      r'(未使用|使ってない|解約|年払い|trial|トライアル|storage|old|放置)',
      caseSensitive: false,
    ).hasMatch(line);
    items.add(
      SubscriptionScanItem(
        name: name,
        amount: amount,
        reason: likelyUnused ? '未使用・年払い・放置の可能性あり' : '定期課金候補',
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
      .replaceAll(RegExp(r'(?:¥|￥)?\s*[0-9]{3,6}\s*(?:円|JPY)?'), '')
      .replaceAll(RegExp(r'[-_/|:：]+'), ' ')
      .trim();
  if (cleaned.isEmpty) {
    return '定期課金';
  }
  final parts = cleaned.split(RegExp(r'\s+'));
  return parts.take(3).join(' ');
}
