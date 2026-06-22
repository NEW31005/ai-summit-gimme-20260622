import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import 'gimme_model.dart';

const gimmePlusProductId = 'gimme_plus_monthly';
const gimmePreviewEntitlementKey = 'premiumUnlocked';
const gimmeEntitlementSourceKey = 'entitlementSource';
const gimmeRemindersEnabledKey = 'remindersEnabled';

enum EntitlementSource { free, webPreview, store }

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.unlocked,
    required this.source,
    required this.detail,
  });

  const EntitlementSnapshot.free()
    : unlocked = false,
      source = EntitlementSource.free,
      detail = '無料版';

  final bool unlocked;
  final EntitlementSource source;
  final String detail;

  bool get isPreview => source == EntitlementSource.webPreview;

  String get badgeLabel {
    switch (source) {
      case EntitlementSource.free:
        return 'Free';
      case EntitlementSource.webPreview:
        return 'Web確認版 Plus';
      case EntitlementSource.store:
        return 'Store Plus';
    }
  }
}

class PreviewEntitlementRepository {
  const PreviewEntitlementRepository(this.preferences);

  final SharedPreferences preferences;

  Future<EntitlementSnapshot> load() async {
    final unlocked = preferences.getBool(gimmePreviewEntitlementKey) ?? false;
    final sourceName =
        preferences.getString(gimmeEntitlementSourceKey) ??
        EntitlementSource.free.name;
    final source = EntitlementSource.values.firstWhere(
      (item) => item.name == sourceName,
      orElse: () =>
          unlocked ? EntitlementSource.webPreview : EntitlementSource.free,
    );
    if (!unlocked) {
      return const EntitlementSnapshot.free();
    }
    return EntitlementSnapshot(
      unlocked: true,
      source: source == EntitlementSource.store
          ? EntitlementSource.store
          : EntitlementSource.webPreview,
      detail: source == EntitlementSource.store ? 'ストア購入で有効' : 'Web確認版のプレビュー権限',
    );
  }

  Future<EntitlementSnapshot> setPreviewUnlocked(bool value) async {
    await preferences.setBool(gimmePreviewEntitlementKey, value);
    await preferences.setString(
      gimmeEntitlementSourceKey,
      value ? EntitlementSource.webPreview.name : EntitlementSource.free.name,
    );
    if (!value) {
      return const EntitlementSnapshot.free();
    }
    return const EntitlementSnapshot(
      unlocked: true,
      source: EntitlementSource.webPreview,
      detail: 'Web確認版のプレビュー権限',
    );
  }

  Future<void> saveStoreEntitlement() async {
    await preferences.setBool(gimmePreviewEntitlementKey, true);
    await preferences.setString(
      gimmeEntitlementSourceKey,
      EntitlementSource.store.name,
    );
  }
}

class StoreEntitlementBridge {
  StoreEntitlementBridge({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  Future<bool> isStoreAvailable() {
    if (kIsWeb) {
      return Future.value(false);
    }
    return _inAppPurchase.isAvailable();
  }

  Future<ProductDetailsResponse> loadPlusProduct() {
    return _inAppPurchase.queryProductDetails({gimmePlusProductId});
  }

  Future<bool> startPlusPurchase() async {
    if (kIsWeb || !await _inAppPurchase.isAvailable()) {
      return false;
    }
    final products = await loadPlusProduct();
    if (products.productDetails.isEmpty) {
      return false;
    }
    final purchaseParam = PurchaseParam(
      productDetails: products.productDetails.first,
    );
    return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (kIsWeb || !await _inAppPurchase.isAvailable()) {
      return;
    }
    await _inAppPurchase.restorePurchases();
  }

  StreamSubscription<List<PurchaseDetails>> listenForPurchaseUpdates({
    required void Function(EntitlementSnapshot entitlement) onEntitlement,
    void Function(Object error)? onError,
  }) {
    return purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.productID != gimmePlusProductId) {
          continue;
        }
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          onEntitlement(
            const EntitlementSnapshot(
              unlocked: true,
              source: EntitlementSource.store,
              detail: 'ストア購入で有効',
            ),
          );
        }
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      }
    }, onError: onError);
  }
}

class ReminderSettingsRepository {
  const ReminderSettingsRepository(this.preferences);

  final SharedPreferences preferences;

  bool loadEnabled() {
    return preferences.getBool(gimmeRemindersEnabledKey) ?? false;
  }

  Future<void> setEnabled(bool value) {
    return preferences.setBool(gimmeRemindersEnabledKey, value);
  }
}

class NativeReminderBridge {
  NativeReminderBridge({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  bool get canUseNativeNotifications => !kIsWeb;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<bool> initialize() async {
    if (!canUseNativeNotifications) {
      return false;
    }
    if (_initialized) {
      return true;
    }
    timezone_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Gimme');
    final result = await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
      ),
    );
    _initialized = result != null;
    return _initialized;
  }

  Future<bool> requestPermissions() async {
    if (!await initialize()) {
      return false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted = await android?.requestNotificationsPermission();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    final macosGranted = await macos?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return androidGranted ?? iosGranted ?? macosGranted ?? true;
  }

  Future<int> scheduleReminders(List<GimmeReminder> reminders) async {
    if (!await requestPermissions()) {
      return 0;
    }
    await _plugin.cancelAll();
    var scheduledCount = 0;
    for (final reminder in reminders) {
      final scheduledAt = _scheduledDate(reminder.scheduledFor);
      await _plugin.zonedSchedule(
        id: reminder.id.hashCode & 0x7fffffff,
        title: reminder.title,
        body: reminder.reason,
        scheduledDate: scheduledAt,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'gimme_deadline_reminders',
            'Gimme deadline reminders',
            channelDescription: '申請期限と月初スキャンのリマインダー',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      scheduledCount++;
    }
    return scheduledCount;
  }

  Future<void> cancelReminders() async {
    if (!canUseNativeNotifications) {
      return;
    }
    await _plugin.cancelAll();
  }

  timezone.TZDateTime _scheduledDate(DateTime date) {
    final location = timezone.local;
    var scheduled = timezone.TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
      9,
    );
    final now = timezone.TZDateTime.now(location);
    if (!scheduled.isAfter(now)) {
      scheduled = now.add(const Duration(minutes: 5));
    }
    return scheduled;
  }
}
