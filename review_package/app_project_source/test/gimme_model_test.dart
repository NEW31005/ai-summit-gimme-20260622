import 'package:flutter_test/flutter_test.dart';
import 'package:gimme/gimme_model.dart';

void main() {
  final fixedNow = DateTime(2026, 6, 22);

  test('default household produces prioritized annualized opportunities', () {
    final opportunities = buildOpportunities(
      HouseholdProfile.demo,
      now: fixedNow,
    );

    expect(opportunities.length, greaterThanOrEqualTo(5));
    expect(annualizedPotential(opportunities), greaterThan(250000));
    expect(opportunities.first.id, isNotEmpty);
  });

  test(
    'deadlines are calculated from the current date instead of hardcoded',
    () {
      final opportunities = buildOpportunities(
        HouseholdProfile.demo,
        now: fixedNow,
      );
      final subscription = opportunities.firstWhere(
        (item) => item.id == 'subscription_leak',
      );
      final medical = opportunities.firstWhere(
        (item) => item.id == 'medical_deduction',
      );

      expect(formatDeadline(subscription.deadline), '2026/06/25');
      expect(subscription.daysLeft, 3);
      expect(formatDeadline(medical.deadline), '2027/03/15');
      expect(medical.daysLeft, greaterThan(200));
    },
  );

  test('city profile changes family support range and source label', () {
    final tokyo = buildOpportunities(
      HouseholdProfile.demo.copyWith(city: '東京都杉並区'),
      now: fixedNow,
    ).firstWhere((item) => item.id == 'family_support');
    final osaka = buildOpportunities(
      HouseholdProfile.demo.copyWith(city: '大阪府大阪市'),
      now: fixedNow,
    ).firstWhere((item) => item.id == 'family_support');
    final unknown = buildOpportunities(
      HouseholdProfile.demo.copyWith(city: '未対応市'),
      now: fixedNow,
    ).firstWhere((item) => item.id == 'family_support');

    expect(tokyo.sourceLabel, contains('杉並区'));
    expect(osaka.sourceLabel, contains('大阪市'));
    expect(tokyo.amountRange.high, greaterThan(osaka.amountRange.high));
    expect(unknown.sourceLabel, '全国共通制度');
  });

  test('free plan gates lower priority candidates and Plus unlocks all', () {
    final opportunities = buildOpportunities(
      HouseholdProfile.demo,
      now: fixedNow,
    );

    expect(
      visibleOpportunities(opportunities, premiumUnlocked: false),
      hasLength(freeVisibleOpportunityCount),
    );
    expect(
      lockedOpportunityCount(opportunities, premiumUnlocked: false),
      greaterThan(0),
    );
    expect(
      visibleOpportunities(opportunities, premiumUnlocked: true),
      hasLength(opportunities.length),
    );
    expect(lockedOpportunityCount(opportunities, premiumUnlocked: true), 0);
  });

  test(
    'subscription estimate uses contract count, unused count, and stale months',
    () {
      final range = subscriptionSavingRange(
        HouseholdProfile.demo.copyWith(
          monthlySubscriptions: 16000,
          subscriptionCount: 8,
          unusedSubscriptionCount: 2,
          unusedSubscriptionMonths: 5,
        ),
      );

      expect(range.low, 3000);
      expect(range.high, 6750);
    },
  );

  test('prepared amount and actual recovered amount are separated', () {
    final opportunities = buildOpportunities(
      HouseholdProfile.demo,
      now: fixedNow,
    );
    final opportunity = opportunities.first;
    final completed = <String>{
      for (var i = 0; i < opportunity.steps.length; i++)
        stepKey(opportunity.id, i),
    };

    expect(questProgress(opportunity, completed), 1);
    expect(
      preparedAmount([opportunity], completed),
      opportunity.annualizedAmount,
    );
    expect(
      actualRecoveredAmount({
        'family_support': 12000,
        'subscription_leak': 3800,
      }),
      15800,
    );
  });

  test('AI statement scan extracts recurring charges for profile updates', () {
    final result = analyzeSubscriptionStatement('''
Netflix 月額 1,980円
Adobe 年払い換算 6,480円 使ってない
ChatGPT Plus 3,000円
古いクラウド storage 1,200円 未使用
''');

    expect(result.items, hasLength(4));
    expect(result.monthlyTotal, 12660);
    expect(result.likelyUnusedCount, 2);

    final range = subscriptionSavingRange(
      HouseholdProfile.demo.copyWith(
        monthlySubscriptions: result.monthlyTotal,
        subscriptionCount: result.items.length,
        unusedSubscriptionCount: result.likelyUnusedCount,
        unusedSubscriptionMonths: 4,
      ),
    );
    expect(range.high, greaterThan(0));
  });

  test('yen formatters are stable', () {
    expect(formatYen(1234567), '1,234,567円');
    expect(
      formatYenRange(const AmountRange(low: 12000, high: 45000)),
      '12,000円〜45,000円',
    );
    expect(formatTeaserAmount(128000), '約13万円候補');
  });
}
