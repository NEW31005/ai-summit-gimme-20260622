import 'package:flutter_test/flutter_test.dart';
import 'package:gimme/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Gimme opens with reclaim dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const GimmeApp());
    await tester.pumpAndSettle();

    expect(find.text('Gimme'), findsOneWidget);
    expect(find.text('今月の奪還候補'), findsOneWidget);
    expect(find.text('次の奪還クエスト'), findsOneWidget);
  });
}
