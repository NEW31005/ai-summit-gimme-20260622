import 'package:flutter_test/flutter_test.dart';
import 'package:gimme/gimme_model.dart';

void main() {
  test('default household produces strong claimable opportunities', () {
    final opportunities = buildOpportunities(HouseholdProfile.demo);

    expect(opportunities.length, greaterThanOrEqualTo(5));
    expect(totalPotential(opportunities), greaterThan(250000));
    expect(opportunities.first.id, isNotEmpty);
  });

  test('every opportunity exposes range and estimate basis', () {
    final opportunities = buildOpportunities(HouseholdProfile.demo);

    for (final opportunity in opportunities) {
      expect(
        opportunity.amountRange.high,
        greaterThanOrEqualTo(opportunity.amountRange.low),
      );
      expect(opportunity.amount, opportunity.amountRange.midpoint);
      expect(opportunity.estimateBasis, isNotEmpty);
    }
  });

  test('children condition changes family support confidence and range', () {
    final withChildren = buildOpportunities(
      HouseholdProfile.demo,
    ).firstWhere((item) => item.id == 'family_support');
    final withoutChildren = buildOpportunities(
      HouseholdProfile.demo.copyWith(children: 0),
    ).firstWhere((item) => item.id == 'family_support');

    expect(withChildren.confidence, greaterThan(withoutChildren.confidence));
    expect(
      withChildren.amountRange.low,
      greaterThan(withoutChildren.amountRange.low),
    );
    expect(withChildren.amount, greaterThan(withoutChildren.amount));
  });

  test('medical refund estimate uses a range and handles boundary', () {
    expect(medicalRefundEstimateRange(100000).low, 0);
    expect(medicalRefundEstimateRange(100000).high, 9000);

    final range = medicalRefundEstimateRange(186000);
    expect(range.low, 4300);
    expect(range.high, 17200);
    expect(medicalDeductionEstimate(186000), range.midpoint);
  });

  test('yen formatters are stable', () {
    expect(formatYen(1234567), '1,234,567円');
    expect(
      formatYenRange(const AmountRange(low: 12000, high: 45000)),
      '12,000円〜45,000円',
    );
  });

  test('quest progress and recovered amount use completed steps', () {
    final opportunities = buildOpportunities(HouseholdProfile.demo);
    final opportunity = opportunities.first;
    final completed = <String>{
      for (var i = 0; i < opportunity.steps.length; i++)
        stepKey(opportunity.id, i),
    };

    expect(questProgress(opportunity, completed), 1);
    expect(recoveredAmount([opportunity], completed), opportunity.amount);
  });
}
