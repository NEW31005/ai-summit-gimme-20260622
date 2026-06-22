import 'package:flutter_test/flutter_test.dart';
import 'package:gimme/gimme_model.dart';

void main() {
  test('default household produces strong claimable opportunities', () {
    final opportunities = buildOpportunities(HouseholdProfile.demo);

    expect(opportunities.length, greaterThanOrEqualTo(5));
    expect(totalPotential(opportunities), greaterThan(250000));
    expect(opportunities.first.id, isNotEmpty);
  });

  test('children condition changes family support confidence', () {
    final withChildren = buildOpportunities(
      HouseholdProfile.demo,
    ).firstWhere((item) => item.id == 'family_support');
    final withoutChildren = buildOpportunities(
      HouseholdProfile.demo.copyWith(children: 0),
    ).firstWhere((item) => item.id == 'family_support');

    expect(withChildren.confidence, greaterThan(withoutChildren.confidence));
    expect(withChildren.amount, greaterThan(withoutChildren.amount));
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
