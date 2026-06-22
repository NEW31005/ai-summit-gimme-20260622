import 'package:flutter_test/flutter_test.dart';
import 'package:gimme/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Gimme opens with reclaim dashboard and AI scan tab', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const GimmeApp());
    await tester.pumpAndSettle();

    expect(find.text('Gimme'), findsWidgets);
    expect(find.text('世帯のもらい損ねを奪還'), findsOneWidget);
    expect(find.text('年間の取り戻し見込み'), findsOneWidget);
    expect(find.text('Plusで全候補を解放'), findsWidgets);

    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(find.text('AI明細スキャン'), findsOneWidget);

    await tester.tap(find.text('定期課金を抽出'));
    await tester.pumpAndSettle();

    expect(find.text('抽出結果'), findsOneWidget);
    expect(find.text('世帯条件に反映'), findsOneWidget);
  });
}
