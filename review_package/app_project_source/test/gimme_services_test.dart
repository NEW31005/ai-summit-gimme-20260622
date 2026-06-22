import 'package:flutter_test/flutter_test.dart';
import 'package:gimme/gimme_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('store entitlement is active only before its expiry', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = PreviewEntitlementRepository(prefs);
    final verifiedAt = DateTime(2026, 6, 1, 10);
    final expiresAt = DateTime(2026, 7, 3, 10);

    final saved = await repository.saveStoreEntitlement(
      verifiedAt: verifiedAt,
      expiresAt: expiresAt,
      purchaseId: 'purchase-001',
    );
    final loaded = await repository.load(now: DateTime(2026, 6, 20));

    expect(saved.unlocked, isTrue);
    expect(saved.source, EntitlementSource.store);
    expect(saved.expiresAt, expiresAt);
    expect(loaded.unlocked, isTrue);
    expect(loaded.purchaseId, 'purchase-001');
    expect(loaded.shouldRefreshStoreEntitlement(DateTime(2026, 6, 29)), isTrue);
  });

  test(
    'expired store entitlement is cleared instead of staying unlocked',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = PreviewEntitlementRepository(prefs);

      await repository.saveStoreEntitlement(
        verifiedAt: DateTime(2026, 6, 1, 10),
        expiresAt: DateTime(2026, 6, 30, 10),
      );
      final loaded = await repository.load(now: DateTime(2026, 7, 1));

      expect(loaded.unlocked, isFalse);
      expect(loaded.source, EntitlementSource.free);
      expect(prefs.getBool(gimmePreviewEntitlementKey), isFalse);
      expect(prefs.getInt(gimmeStoreExpiresAtKey), isNull);
    },
  );

  test('legacy store unlock without expiry is treated as unverified', () async {
    SharedPreferences.setMockInitialValues({
      gimmePreviewEntitlementKey: true,
      gimmeEntitlementSourceKey: 'store',
    });
    final prefs = await SharedPreferences.getInstance();
    final repository = PreviewEntitlementRepository(prefs);

    final loaded = await repository.load(now: DateTime(2026, 6, 20));

    expect(loaded.unlocked, isFalse);
    expect(loaded.detail, contains('期限確認'));
  });
}
