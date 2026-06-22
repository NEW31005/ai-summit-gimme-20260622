import 'package:flutter_test/flutter_test.dart';
import 'package:gimme/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Gimme opens with reclaim dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const GimmeApp());
    await tester.pumpAndSettle();

    expect(find.text('Gimme'), findsOneWidget);
    expect(find.text('今月の概算奪還候補'), findsOneWidget);
    expect(find.text('放置すると取り損ねる候補があります'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('次の奪還クエスト'), 240);
    expect(find.text('次の奪還クエスト'), findsOneWidget);
  });
}
