class HouseholdProfile {
  const HouseholdProfile({
    required this.city,
    required this.adults,
    required this.children,
    required this.medicalCost,
    required this.monthlySubscriptions,
    required this.hasHomeLoan,
    required this.hasCaregiving,
    required this.recentMove,
  });

  final String city;
  final int adults;
  final int children;
  final int medicalCost;
  final int monthlySubscriptions;
  final bool hasHomeLoan;
  final bool hasCaregiving;
  final bool recentMove;

  static const demo = HouseholdProfile(
    city: '東京都杉並区',
    adults: 2,
    children: 2,
    medicalCost: 186000,
    monthlySubscriptions: 16400,
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
      hasHomeLoan: hasHomeLoan ?? this.hasHomeLoan,
      hasCaregiving: hasCaregiving ?? this.hasCaregiving,
      recentMove: recentMove ?? this.recentMove,
    );
  }
}

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
    required this.amount,
    required this.daysLeft,
    required this.confidence,
    required this.documents,
    required this.steps,
    required this.reason,
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final int amount;
  final int daysLeft;
  final int confidence;
  final List<String> documents;
  final List<QuestStep> steps;
  final String reason;

  bool get urgent => daysLeft <= 14;
}

List<GimmeOpportunity> buildOpportunities(HouseholdProfile profile) {
  final opportunities = <GimmeOpportunity>[
    GimmeOpportunity(
      id: 'family_support',
      title: '子育て世帯サポート差額',
      category: '子育て',
      summary: '児童関連の自治体支援と学校準備費の取りこぼし候補です。',
      amount: 62000 + profile.children * 18000,
      daysLeft: 9,
      confidence: profile.children > 0 ? 91 : 34,
      reason: profile.children > 0
          ? '子ども${profile.children}人の世帯条件に一致しています。'
          : '子ども情報が未登録のため優先度は低めです。',
      documents: const ['本人確認', '世帯情報', '振込口座', '学校/保育関連書類'],
      steps: const [
        QuestStep('世帯情報を確認', '子どもの年齢と居住地が条件に合うか確認します。'),
        QuestStep('対象制度を選ぶ', '自治体ページで今年度の名称と受付期限を確認します。'),
        QuestStep('必要書類をそろえる', '口座情報と世帯確認書類を準備します。'),
        QuestStep('申請前チェック', '入力漏れと期限を見直してから提出します。'),
      ],
    ),
    GimmeOpportunity(
      id: 'home_loan',
      title: '住宅ローン控除・省エネ補助確認',
      category: '住宅',
      summary: '住宅ローン控除と省エネ関連補助の見落とし候補です。',
      amount: profile.hasHomeLoan ? 184000 : 28000,
      daysLeft: 21,
      confidence: profile.hasHomeLoan ? 86 : 42,
      reason: profile.hasHomeLoan
          ? '住宅ローンありの条件から優先候補になっています。'
          : '住宅ローンなしのため関連補助だけを確認します。',
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
      amount: medicalDeductionEstimate(profile.medicalCost),
      daysLeft: 17,
      confidence: profile.medicalCost >= 100000 ? 82 : 45,
      reason: '年間医療費 ${profile.medicalCost}円 をもとに見込みを計算しています。',
      documents: const ['医療費明細', '交通費メモ', '薬局レシート', '源泉徴収票'],
      steps: const [
        QuestStep('医療費を分類', '病院、薬局、交通費を分けて集計します。'),
        QuestStep('対象外を除外', '美容目的など対象外の支出を外します。'),
        QuestStep('明細を作る', '家族別に医療費明細を作成します。'),
        QuestStep('申告準備', '控除額の見込みと提出書類を確認します。'),
      ],
    ),
    GimmeOpportunity(
      id: 'subscription_leak',
      title: '眠ったサブスク解約回収',
      category: '固定費',
      summary: '利用頻度の低いサブスクと年払い更新の見落としを洗い出します。',
      amount: profile.monthlySubscriptions * 4,
      daysLeft: 5,
      confidence: profile.monthlySubscriptions >= 10000 ? 88 : 59,
      reason: '月額サブスク ${profile.monthlySubscriptions}円 のうち、回収余地を推定しています。',
      documents: const ['カード明細', 'アプリ購読履歴', '年払い更新日'],
      steps: const [
        QuestStep('明細を眺める', '直近3か月のカード明細から定期課金を拾います。'),
        QuestStep('使っていないものを分ける', '最後に使った日が思い出せないものを候補化します。'),
        QuestStep('解約リンクを確認', '各サービスの解約ページを開ける状態にします。'),
        QuestStep('更新日前に止める', '期限が近いものから順に処理します。'),
      ],
    ),
    GimmeOpportunity(
      id: 'moving_rebate',
      title: '引越し後の住所変更・還付チェック',
      category: '生活',
      summary: '引越し後に残りやすい公共料金、保険、自治体手続きの返金候補です。',
      amount: profile.recentMove ? 36000 : 12000,
      daysLeft: 13,
      confidence: profile.recentMove ? 79 : 48,
      reason: profile.recentMove
          ? '最近の引越し条件があるため、還付候補を優先しています。'
          : '引越しなしのため一般的な住所変更確認に留めています。',
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
      const GimmeOpportunity(
        id: 'care_support',
        title: '介護用品・通院支援の申請確認',
        category: '介護',
        summary: '介護用品、通院交通、住宅改修などの支援候補です。',
        amount: 96000,
        daysLeft: 18,
        confidence: 84,
        reason: '介護ありの世帯条件に一致しています。',
        documents: ['介護認定情報', '通院記録', '用品領収書'],
        steps: [
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

int medicalDeductionEstimate(int medicalCost) {
  if (medicalCost <= 100000) {
    return 9000;
  }
  return ((medicalCost - 100000) * 0.18).round() + 18000;
}

int opportunityScore(GimmeOpportunity opportunity) {
  final urgencyBoost = (45 - opportunity.daysLeft).clamp(0, 45) * 1200;
  return opportunity.amount + urgencyBoost + opportunity.confidence * 400;
}

int totalPotential(List<GimmeOpportunity> opportunities) {
  return opportunities.fold(0, (sum, item) => sum + item.amount);
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

int recoveredAmount(
  List<GimmeOpportunity> opportunities,
  Set<String> completedKeys,
) {
  return opportunities
      .where((opportunity) => isQuestComplete(opportunity, completedKeys))
      .fold(0, (sum, opportunity) => sum + opportunity.amount);
}

int urgentCount(List<GimmeOpportunity> opportunities) {
  return opportunities.where((opportunity) => opportunity.urgent).length;
}

String stepKey(String opportunityId, int index) => '$opportunityId:$index';

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
