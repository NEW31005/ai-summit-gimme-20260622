import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gimme_model.dart';
import 'gimme_services.dart';

void main() {
  runApp(const GimmeApp());
}

class GimmeApp extends StatelessWidget {
  const GimmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Gimme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE6F4F1),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      home: const GimmeHome(),
    );
  }
}

class GimmeHome extends StatefulWidget {
  const GimmeHome({super.key});

  @override
  State<GimmeHome> createState() => _GimmeHomeState();
}

class _GimmeHomeState extends State<GimmeHome> {
  static const _cityKey = 'city';
  static const _adultsKey = 'adults';
  static const _childrenKey = 'children';
  static const _underThreeChildrenKey = 'underThreeChildren';
  static const _supportedOlderChildrenKey = 'supportedOlderChildren';
  static const _medicalCostKey = 'medicalCost';
  static const _medicalInsuranceReimbursementKey =
      'medicalInsuranceReimbursement';
  static const _totalIncomeKey = 'totalIncome';
  static const _subscriptionsKey = 'subscriptions';
  static const _subscriptionCountKey = 'subscriptionCount';
  static const _unusedSubscriptionCountKey = 'unusedSubscriptionCount';
  static const _unusedSubscriptionMonthsKey = 'unusedSubscriptionMonths';
  static const _homeLoanKey = 'homeLoan';
  static const _caregivingKey = 'caregiving';
  static const _recentMoveKey = 'recentMove';
  static const _completedKey = 'completedSteps';
  static const _actualRecoveredEntriesKey = 'actualRecoveredEntries';

  HouseholdProfile _profile = HouseholdProfile.demo;
  Set<String> _completedSteps = <String>{};
  Map<String, int> _actualRecovered = <String, int>{};
  int _selectedIndex = 0;
  bool _loaded = false;
  EntitlementSnapshot _entitlement = const EntitlementSnapshot.free();
  bool _remindersEnabled = false;
  SharedPreferences? _prefs;
  final StoreEntitlementBridge _storeEntitlementBridge =
      StoreEntitlementBridge();
  final NativeReminderBridge _nativeReminderBridge = NativeReminderBridge();
  StreamSubscription<dynamic>? _purchaseSubscription;

  List<GimmeOpportunity> get _opportunities => buildOpportunities(_profile);
  bool get _premiumUnlocked => _entitlement.unlocked;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _purchaseSubscription = _storeEntitlementBridge.listenForPurchaseUpdates(
        onEntitlement: _handleStoreEntitlement,
      );
    }
    _loadState();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final entitlement = await PreviewEntitlementRepository(prefs).load();
    final remindersEnabled = ReminderSettingsRepository(prefs).loadEnabled();
    setState(() {
      _prefs = prefs;
      _profile = HouseholdProfile(
        city: prefs.getString(_cityKey) ?? HouseholdProfile.demo.city,
        adults: prefs.getInt(_adultsKey) ?? HouseholdProfile.demo.adults,
        children: prefs.getInt(_childrenKey) ?? HouseholdProfile.demo.children,
        underThreeChildren:
            prefs.getInt(_underThreeChildrenKey) ??
            HouseholdProfile.demo.underThreeChildren,
        supportedOlderChildren:
            prefs.getInt(_supportedOlderChildrenKey) ??
            HouseholdProfile.demo.supportedOlderChildren,
        medicalCost:
            prefs.getInt(_medicalCostKey) ?? HouseholdProfile.demo.medicalCost,
        medicalInsuranceReimbursement:
            prefs.getInt(_medicalInsuranceReimbursementKey) ??
            HouseholdProfile.demo.medicalInsuranceReimbursement,
        totalIncome:
            prefs.getInt(_totalIncomeKey) ?? HouseholdProfile.demo.totalIncome,
        monthlySubscriptions:
            prefs.getInt(_subscriptionsKey) ??
            HouseholdProfile.demo.monthlySubscriptions,
        subscriptionCount:
            prefs.getInt(_subscriptionCountKey) ??
            HouseholdProfile.demo.subscriptionCount,
        unusedSubscriptionCount:
            prefs.getInt(_unusedSubscriptionCountKey) ??
            HouseholdProfile.demo.unusedSubscriptionCount,
        unusedSubscriptionMonths:
            prefs.getInt(_unusedSubscriptionMonthsKey) ??
            HouseholdProfile.demo.unusedSubscriptionMonths,
        hasHomeLoan:
            prefs.getBool(_homeLoanKey) ?? HouseholdProfile.demo.hasHomeLoan,
        hasCaregiving:
            prefs.getBool(_caregivingKey) ??
            HouseholdProfile.demo.hasCaregiving,
        recentMove:
            prefs.getBool(_recentMoveKey) ?? HouseholdProfile.demo.recentMove,
      );
      _completedSteps = (prefs.getStringList(_completedKey) ?? <String>[])
          .toSet();
      _actualRecovered = _decodeActualRecovered(
        prefs.getStringList(_actualRecoveredEntriesKey) ?? <String>[],
      );
      _entitlement = entitlement;
      _remindersEnabled = remindersEnabled;
      _loaded = true;
    });
  }

  Future<void> _saveProfile(HouseholdProfile profile) async {
    final prefs = _prefs;
    setState(() => _profile = profile);
    if (prefs == null) {
      return;
    }
    await prefs.setString(_cityKey, profile.city);
    await prefs.setInt(_adultsKey, profile.adults);
    await prefs.setInt(_childrenKey, profile.children);
    await prefs.setInt(_underThreeChildrenKey, profile.underThreeChildren);
    await prefs.setInt(
      _supportedOlderChildrenKey,
      profile.supportedOlderChildren,
    );
    await prefs.setInt(_medicalCostKey, profile.medicalCost);
    await prefs.setInt(
      _medicalInsuranceReimbursementKey,
      profile.medicalInsuranceReimbursement,
    );
    await prefs.setInt(_totalIncomeKey, profile.totalIncome);
    await prefs.setInt(_subscriptionsKey, profile.monthlySubscriptions);
    await prefs.setInt(_subscriptionCountKey, profile.subscriptionCount);
    await prefs.setInt(
      _unusedSubscriptionCountKey,
      profile.unusedSubscriptionCount,
    );
    await prefs.setInt(
      _unusedSubscriptionMonthsKey,
      profile.unusedSubscriptionMonths,
    );
    await prefs.setBool(_homeLoanKey, profile.hasHomeLoan);
    await prefs.setBool(_caregivingKey, profile.hasCaregiving);
    await prefs.setBool(_recentMoveKey, profile.recentMove);
  }

  Future<void> _toggleStep(String opportunityId, int index, bool value) async {
    final key = stepKey(opportunityId, index);
    setState(() {
      if (value) {
        _completedSteps.add(key);
      } else {
        _completedSteps.remove(key);
      }
    });
    await _prefs?.setStringList(
      _completedKey,
      _completedSteps.toList()..sort(),
    );
  }

  Future<void> _setActualRecovered(String opportunityId, int amount) async {
    setState(() {
      if (amount <= 0) {
        _actualRecovered.remove(opportunityId);
      } else {
        _actualRecovered[opportunityId] = amount;
      }
    });
    await _prefs?.setStringList(
      _actualRecoveredEntriesKey,
      _actualRecovered.entries
          .map((entry) => '${entry.key}:${entry.value}')
          .toList()
        ..sort(),
    );
  }

  Future<void> _setPreviewEntitlement(bool value) async {
    if (!kIsWeb && value) {
      final started = await _storeEntitlementBridge.startPlusPurchase();
      if (!started) {
        return;
      }
      return;
    }
    final prefs = _prefs;
    if (prefs == null) {
      setState(
        () => _entitlement = value
            ? const EntitlementSnapshot(
                unlocked: true,
                source: EntitlementSource.webPreview,
                detail: 'Web確認版のプレビュー権限',
              )
            : const EntitlementSnapshot.free(),
      );
      return;
    }
    final next = await PreviewEntitlementRepository(
      prefs,
    ).setPreviewUnlocked(value);
    setState(() => _entitlement = next);
  }

  Future<void> _handleStoreEntitlement(EntitlementSnapshot entitlement) async {
    final prefs = _prefs;
    if (!mounted) {
      return;
    }
    setState(() => _entitlement = entitlement);
    if (prefs != null) {
      await PreviewEntitlementRepository(prefs).saveStoreEntitlement();
    }
  }

  Future<void> _restorePurchases() async {
    await _storeEntitlementBridge.restorePurchases();
  }

  Future<void> _setRemindersEnabled(bool value) async {
    final prefs = _prefs;
    setState(() => _remindersEnabled = value);
    if (prefs != null) {
      await ReminderSettingsRepository(prefs).setEnabled(value);
    }
    if (!kIsWeb) {
      if (value) {
        await _nativeReminderBridge.scheduleReminders(
          buildReminderPlan(_opportunities),
        );
      } else {
        await _nativeReminderBridge.cancelReminders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final opportunities = _opportunities;
    final reminderPlan = buildReminderPlan(opportunities);
    final pages = <Widget>[
      _DashboardPage(
        profile: _profile,
        opportunities: opportunities,
        completedSteps: _completedSteps,
        actualRecovered: _actualRecovered,
        premiumUnlocked: _premiumUnlocked,
        onOpen: _openQuest,
        onPlanTap: _openPaywall,
      ),
      _OpportunitiesPage(
        opportunities: opportunities,
        completedSteps: _completedSteps,
        premiumUnlocked: _premiumUnlocked,
        onOpen: _openQuest,
        onPlanTap: _openPaywall,
      ),
      AiScanPage(profile: _profile, onProfileChanged: _saveProfile),
      _HouseholdPage(
        profile: _profile,
        onChanged: _saveProfile,
        onPrivacyTap: _openPrivacy,
      ),
      _InsightsPage(
        opportunities: opportunities,
        reminderPlan: reminderPlan,
        completedSteps: _completedSteps,
        actualRecovered: _actualRecovered,
        premiumUnlocked: _premiumUnlocked,
        remindersEnabled: _remindersEnabled,
        onPlanTap: _openPaywall,
        onRemindersChanged: _setRemindersEnabled,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: const _BrandTitle(),
        actions: [
          Builder(
            builder: (context) {
              final compact = MediaQuery.sizeOf(context).width < 420;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: compact
                    ? IconButton.filledTonal(
                        onPressed: () => setState(() => _selectedIndex = 3),
                        icon: const Icon(Icons.group_outlined, size: 19),
                        tooltip:
                            '${_profile.adults + _profile.children + _profile.supportedOlderChildren}人世帯',
                      )
                    : FilledButton.tonalIcon(
                        onPressed: () => setState(() => _selectedIndex = 3),
                        icon: const Icon(Icons.group_outlined, size: 18),
                        label: Text(
                          '${_profile.adults + _profile.children + _profile.supportedOlderChildren}人世帯',
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: pages[_selectedIndex],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.find_in_page_outlined),
            selectedIcon: Icon(Icons.find_in_page),
            label: '候補',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.family_restroom_outlined),
            selectedIcon: Icon(Icons.family_restroom),
            label: '世帯',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: '成果',
          ),
        ],
      ),
    );
  }

  void _openQuest(GimmeOpportunity opportunity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuestDetailPage(
          opportunity: opportunity,
          locked: !_premiumUnlocked,
          completedSteps: _completedSteps,
          actualRecovered: _actualRecovered[opportunity.id] ?? 0,
          onStepChanged: _toggleStep,
          onActualRecoveredChanged: _setActualRecovered,
          onPlanTap: _openPaywall,
        ),
      ),
    );
  }

  void _openPaywall() {
    final reminderPlan = buildReminderPlan(_opportunities);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaywallPage(
          entitlement: _entitlement,
          remindersEnabled: _remindersEnabled,
          reminderPlan: reminderPlan,
          onUnlockChanged: _setPreviewEntitlement,
          onRestorePurchases: _restorePurchases,
          onRemindersChanged: _setRemindersEnabled,
        ),
      ),
    );
  }

  void _openPrivacy() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()));
  }
}

Map<String, int> _decodeActualRecovered(List<String> entries) {
  final result = <String, int>{};
  for (final entry in entries) {
    final separator = entry.lastIndexOf(':');
    if (separator <= 0) {
      continue;
    }
    final amount = int.tryParse(entry.substring(separator + 1));
    if (amount != null && amount > 0) {
      result[entry.substring(0, separator)] = amount;
    }
  }
  return result;
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.savings_outlined,
            color: Colors.white,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gimme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text('世帯のもらい損ねを奪還', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    required this.profile,
    required this.opportunities,
    required this.completedSteps,
    required this.actualRecovered,
    required this.premiumUnlocked,
    required this.onOpen,
    required this.onPlanTap,
  });

  final HouseholdProfile profile;
  final List<GimmeOpportunity> opportunities;
  final Set<String> completedSteps;
  final Map<String, int> actualRecovered;
  final bool premiumUnlocked;
  final ValueChanged<GimmeOpportunity> onOpen;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    final annualRange = annualizedPotentialRange(opportunities);
    final prepared = preparedAmount(opportunities, completedSteps);
    final actual = actualRecoveredAmount(actualRecovered);
    final urgent = urgentCount(opportunities);
    final top = visibleOpportunities(
      opportunities,
      premiumUnlocked: premiumUnlocked,
    ).first;
    final nextDeadline = opportunities.reduce(
      (a, b) => a.daysLeft <= b.daysLeft ? a : b,
    );

    return ListView(
      key: const ValueKey('dashboard'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        _HeroMoneyCard(
          annualRange: annualRange,
          prepared: prepared,
          actualRecovered: actual,
          urgent: urgent,
          premiumUnlocked: premiumUnlocked,
          onPlanTap: onPlanTap,
        ),
        const SizedBox(height: 14),
        _ShockCard(top: nextDeadline, urgent: urgent),
        const SizedBox(height: 14),
        _HouseholdStrip(profile: profile),
        const SizedBox(height: 14),
        Text('次の奪還クエスト', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        _OpportunityCard(
          opportunity: top,
          progress: questProgress(top, completedSteps),
          lockedPreview: !premiumUnlocked,
          onTap: () => onOpen(top),
          highlighted: true,
        ),
      ],
    );
  }
}

class _HeroMoneyCard extends StatelessWidget {
  const _HeroMoneyCard({
    required this.annualRange,
    required this.prepared,
    required this.actualRecovered,
    required this.urgent,
    required this.premiumUnlocked,
    required this.onPlanTap,
  });

  final AmountRange annualRange;
  final int prepared;
  final int actualRecovered;
  final int urgent;
  final bool premiumUnlocked;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF12312E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFFF2C94C),
              ),
              const SizedBox(width: 8),
              Text(
                '年間の取り戻し見込み',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFD6E8E4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            premiumUnlocked
                ? formatYenRange(annualRange)
                : formatTeaserAmount(annualRange.midpoint),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            premiumUnlocked
                ? '制度、控除、サブスク、還付候補を年次換算で統合しています。'
                : '無料版では金額の概要のみ表示します。内訳と手順はPlusで解放されます。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFC8D8D5)),
          ),
          const SizedBox(height: 12),
          const _HeroDisclaimer(),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(label: '申請準備完了', value: formatYen(prepared)),
              _MetricPill(label: '実回収', value: formatYen(actualRecovered)),
              _MetricPill(label: '期限14日以内', value: '$urgent件'),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPlanTap,
            icon: Icon(
              premiumUnlocked
                  ? Icons.verified_outlined
                  : Icons.workspace_premium_outlined,
            ),
            label: Text(premiumUnlocked ? 'Gimme Plus 有効' : 'Plusで全候補を解放'),
          ),
        ],
      ),
    );
  }
}

class _ShockCard extends StatelessWidget {
  const _ShockCard({required this.top, required this.urgent});

  final GimmeOpportunity top;
  final int urgent;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFBEB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFDE68A),
              foregroundColor: Color(0xFF92400E),
              child: Icon(Icons.priority_high_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '次の締切は実日付で追跡中',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '最短は「${top.title}」。締切 ${formatDeadline(top.deadline)}、残り${top.daysLeft}日。期限14日以内の候補が$urgent件あります。',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDisclaimer extends StatelessWidget {
  const _HeroDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFFD6E8E4)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '正式申請前に自治体・税務署・契約先の一次情報で確認します。Gimmeは見落とし候補を早く発見するための確認アシスタントです。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFD6E8E4),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFAFC8C3), fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HouseholdStrip extends StatelessWidget {
  const _HouseholdStrip({required this.profile});

  final HouseholdProfile profile;

  @override
  Widget build(BuildContext context) {
    final cityMatched = cityProfileFor(profile.city) != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cityMatched
                  ? const Color(0xFFE8F3F1)
                  : const Color(0xFFF1F5F9),
              foregroundColor: cityMatched
                  ? const Color(0xFF0F766E)
                  : const Color(0xFF64748B),
              child: const Icon(Icons.home_work_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.city,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${cityMatched ? '地域公式ページ確認対象' : '全国共通のみ'}  |  サブスク${profile.subscriptionCount}本 / 未使用候補${profile.unusedSubscriptionCount}本',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _OpportunitiesPage extends StatelessWidget {
  const _OpportunitiesPage({
    required this.opportunities,
    required this.completedSteps,
    required this.premiumUnlocked,
    required this.onOpen,
    required this.onPlanTap,
  });

  final List<GimmeOpportunity> opportunities;
  final Set<String> completedSteps;
  final bool premiumUnlocked;
  final ValueChanged<GimmeOpportunity> onOpen;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    final visible = visibleOpportunities(
      opportunities,
      premiumUnlocked: premiumUnlocked,
    );
    final lockedCount = lockedOpportunityCount(
      opportunities,
      premiumUnlocked: premiumUnlocked,
    );
    return ListView(
      key: const ValueKey('opportunities'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        Text('奪還候補', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          premiumUnlocked
              ? '地域、期限、期間単位、世帯条件から全候補を優先順位づけしています。'
              : '無料版では上位$freeVisibleOpportunityCount件まで表示します。金額内訳と手順はPlusで解放されます。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        ...visible.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OpportunityCard(
              opportunity: item,
              progress: questProgress(item, completedSteps),
              lockedPreview: !premiumUnlocked,
              onTap: () => onOpen(item),
            ),
          ),
        ),
        if (lockedCount > 0)
          _LockedCandidatesCard(count: lockedCount, onPlanTap: onPlanTap),
      ],
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.opportunity,
    required this.progress,
    required this.lockedPreview,
    required this.onTap,
    this.highlighted = false,
  });

  final GimmeOpportunity opportunity;
  final double progress;
  final bool lockedPreview;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(opportunity.category);
    final amountText = lockedPreview
        ? formatTeaserAmount(opportunity.annualizedAmount)
        : formatYenRange(opportunity.amountRange);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(highlighted ? 18 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _categoryIcon(opportunity.category),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${opportunity.category} / ${opportunity.period.label} / ${opportunity.sourceLabel}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 116,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountText,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '残り${opportunity.daysLeft}日',
                          style: TextStyle(
                            color: opportunity.urgent
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(opportunity.summary),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: '根拠 ${opportunity.confidenceLabel}'),
                  _Tag(label: '締切 ${formatDeadline(opportunity.deadline)}'),
                  if (lockedPreview) const _Tag(label: 'Plusで内訳解放'),
                  if (opportunity.urgent)
                    const _Tag(label: '期限近い', warning: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedCandidatesCard extends StatelessWidget {
  const _LockedCandidatesCard({required this.count, required this.onPlanTap});

  final int count;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFECFDF5),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'まだ見えていない候補があります',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('$count件の候補、制度名、手順、書類リスト、通知予定はPlusで解放されます。'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onPlanTap,
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Plusで全候補を解放'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestDetailPage extends StatelessWidget {
  const QuestDetailPage({
    super.key,
    required this.opportunity,
    required this.locked,
    required this.completedSteps,
    required this.actualRecovered,
    required this.onStepChanged,
    required this.onActualRecoveredChanged,
    required this.onPlanTap,
  });

  final GimmeOpportunity opportunity;
  final bool locked;
  final Set<String> completedSteps;
  final int actualRecovered;
  final Future<void> Function(String opportunityId, int index, bool value)
  onStepChanged;
  final Future<void> Function(String opportunityId, int amount)
  onActualRecoveredChanged;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    final progress = questProgress(opportunity, completedSteps);
    final color = _categoryColor(opportunity.category);
    return Scaffold(
      appBar: AppBar(title: const Text('奪還クエスト')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _QuestHeader(
                  opportunity: opportunity,
                  locked: locked,
                  progress: progress,
                  color: color,
                ),
                const SizedBox(height: 16),
                if (locked)
                  _LockedDetailCard(onPlanTap: onPlanTap)
                else ...[
                  _EstimateBasisCard(opportunity: opportunity),
                  const SizedBox(height: 16),
                  Text('必要なもの', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: opportunity.documents
                        .map((doc) => _Tag(label: doc))
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '申請準備ステップ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(opportunity.steps.length, (index) {
                    final step = opportunity.steps[index];
                    final key = stepKey(opportunity.id, index);
                    final checked = completedSteps.contains(key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: CheckboxListTile(
                          value: checked,
                          onChanged: (value) => onStepChanged(
                            opportunity.id,
                            index,
                            value ?? false,
                          ),
                          title: Text(
                            step.title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(step.detail),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    );
                  }),
                  _ActualRecoveredCard(
                    amount: actualRecovered,
                    onEdit: () => _showRecoveredDialog(context),
                  ),
                ],
                const SizedBox(height: 12),
                const _ComplianceNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showRecoveredDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: actualRecovered > 0 ? actualRecovered.toString() : '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('実際に戻った金額'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: '円',
            helperText: '申請準備額ではなく、実際に戻った/節約できた金額だけを入力します。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(0),
            child: const Text('削除'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pop(int.tryParse(controller.text.replaceAll(',', '')) ?? 0);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      await onActualRecoveredChanged(opportunity.id, result);
    }
  }
}

class _QuestHeader extends StatelessWidget {
  const _QuestHeader({
    required this.opportunity,
    required this.locked,
    required this.progress,
    required this.color,
  });

  final GimmeOpportunity opportunity;
  final bool locked;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: opportunity.category),
              _Tag(label: opportunity.period.label),
              if (locked) const _Tag(label: 'Plus詳細'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            opportunity.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(opportunity.reason),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BigStat(
                label: locked ? '概算' : '概算レンジ',
                value: locked
                    ? formatTeaserAmount(opportunity.annualizedAmount)
                    : formatYenRange(opportunity.amountRange),
              ),
              _BigStat(
                label: '締切',
                value: formatDeadline(opportunity.deadline),
              ),
              _BigStat(label: '残り', value: '${opportunity.daysLeft}日'),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: color,
              backgroundColor: const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedDetailCard extends StatelessWidget {
  const _LockedDetailCard({required this.onPlanTap});

  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFECFDF5),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plusで解放される詳細',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text('制度名、必要書類、申請手順、推定根拠、通知予定、実回収額の記録を解放します。'),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onPlanTap,
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Gimme Plusを見る'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstimateBasisCard extends StatelessWidget {
  const _EstimateBasisCard({required this.opportunity});

  final GimmeOpportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined, color: Color(0xFF0F766E)),
                const SizedBox(width: 8),
                Text(
                  '推定根拠',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(opportunity.estimateBasis),
            const SizedBox(height: 10),
            Text(
              '表示額は候補発見用の幅です。実際の受給額・還付額・節約額は、申請先の条件、所得、契約、提出時期で変わります。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActualRecoveredCard extends StatelessWidget {
  const _ActualRecoveredCard({required this.amount, required this.onEdit});

  final int amount;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE8F3F1),
              foregroundColor: Color(0xFF0F766E),
              child: Icon(Icons.payments_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '実回収額',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(amount > 0 ? formatYen(amount) : 'まだ記録なし'),
                ],
              ),
            ),
            TextButton(onPressed: onEdit, child: const Text('記録')),
          ],
        ),
      ),
    );
  }
}

class AiScanPage extends StatefulWidget {
  const AiScanPage({
    super.key,
    required this.profile,
    required this.onProfileChanged,
  });

  final HouseholdProfile profile;
  final ValueChanged<HouseholdProfile> onProfileChanged;

  @override
  State<AiScanPage> createState() => _AiScanPageState();
}

class _AiScanPageState extends State<AiScanPage> {
  late final TextEditingController _controller;
  SubscriptionScanResult? _result;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text:
          'Netflix 月額 1,980円\nAdobe 年払い換算 6,480円 使ってない\nChatGPT Plus 3,000円\n古いクラウド storage 1,200円 未使用',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return ListView(
      key: const ValueKey('ai-scan'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        Text('AI明細スキャン', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'カード明細や購読一覧を貼り付けると、定期課金候補を抽出し、世帯条件へ反映します。確認版はローカル解析、正式版はAI APIへ差し替え可能な設計です。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  minLines: 7,
                  maxLines: 11,
                  decoration: const InputDecoration(
                    labelText: '明細テキスト',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _result = analyzeSubscriptionStatement(
                          _controller.text,
                        );
                      });
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('定期課金を抽出'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: 14),
          _ScanResultCard(
            result: result,
            onApply: result.hasData
                ? () {
                    widget.onProfileChanged(
                      widget.profile.copyWith(
                        monthlySubscriptions: result.monthlyTotal,
                        subscriptionCount: result.includedMonthlyCount,
                        unusedSubscriptionCount: result.likelyUnusedCount,
                        unusedSubscriptionMonths: result.likelyUnusedCount > 0
                            ? 4
                            : 1,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('サブスク条件へ反映しました')),
                    );
                  }
                : null,
          ),
        ],
      ],
    );
  }
}

class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({required this.result, required this.onApply});

  final SubscriptionScanResult result;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('抽出結果', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _PlanRow(label: '月額合計', value: formatYen(result.monthlyTotal)),
            _PlanRow(label: '月額に反映', value: '${result.includedMonthlyCount}件'),
            _PlanRow(
              label: '周期確認待ち',
              value: '${result.confirmationRequiredCount}件',
            ),
            _PlanRow(label: '未使用候補', value: '${result.likelyUnusedCount}件'),
            const SizedBox(height: 8),
            ...result.items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item.requiresConfirmation
                      ? Icons.help_outline
                      : item.likelyUnused
                      ? Icons.warning_amber_outlined
                      : Icons.receipt_long_outlined,
                  color: item.requiresConfirmation
                      ? const Color(0xFF7C3AED)
                      : item.likelyUnused
                      ? const Color(0xFFC2410C)
                      : const Color(0xFF0F766E),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${item.periodLabel} / 元金額 ${formatYen(item.rawAmount)} / 確信度 ${item.confidence}%\n${item.reason}',
                ),
                trailing: Text(
                  item.includedInMonthlyTotal ? formatYen(item.amount) : '確認待ち',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.sync_alt),
              label: const Text('世帯条件に反映'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseholdPage extends StatefulWidget {
  const _HouseholdPage({
    required this.profile,
    required this.onChanged,
    required this.onPrivacyTap,
  });

  final HouseholdProfile profile;
  final ValueChanged<HouseholdProfile> onChanged;
  final VoidCallback onPrivacyTap;

  @override
  State<_HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<_HouseholdPage> {
  late HouseholdProfile _draft;
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _draft = widget.profile;
    _cityController = TextEditingController(text: _draft.city);
  }

  @override
  void didUpdateWidget(covariant _HouseholdPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _draft = widget.profile;
      _cityController.text = widget.profile.city;
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('household'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        Text('世帯プロファイル', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '保存した条件だけが候補計算に反映されます。地域名は公式制度ページを探す手がかりで、未確認の自治体金額は加算しません。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: '居住地',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    helperText: '例: 東京都杉並区 / 横浜市 / 大阪市 / 札幌市 / 福岡市',
                  ),
                  onChanged: (value) => _draft = _draft.copyWith(city: value),
                ),
                const SizedBox(height: 14),
                _StepperRow(
                  label: '大人',
                  value: _draft.adults,
                  min: 1,
                  max: 4,
                  onChanged: (value) =>
                      setState(() => _draft = _draft.copyWith(adults: value)),
                ),
                _StepperRow(
                  label: '子ども',
                  value: _draft.children,
                  min: 0,
                  max: 5,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(
                      children: value,
                      underThreeChildren: _draft.underThreeChildren
                          .clamp(0, value)
                          .toInt(),
                    ),
                  ),
                ),
                _StepperRow(
                  label: '3歳未満の子',
                  value: _draft.underThreeChildren
                      .clamp(0, _draft.children)
                      .toInt(),
                  min: 0,
                  max: _draft.children,
                  unit: '人',
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(underThreeChildren: value),
                  ),
                ),
                _StepperRow(
                  label: '18〜22歳の生計負担あり',
                  value: _draft.supportedOlderChildren,
                  min: 0,
                  max: 6,
                  unit: '人',
                  onChanged: (value) => setState(
                    () =>
                        _draft = _draft.copyWith(supportedOlderChildren: value),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '児童手当の第3子以降判定に使います。大学生年代などで監護相当・生計費負担がある子だけ入れてください。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ),
                const Divider(height: 28),
                _AmountSlider(
                  label: '年間医療費',
                  value: _draft.medicalCost,
                  min: 0,
                  max: 420000,
                  divisions: 42,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(medicalCost: value),
                  ),
                ),
                _AmountSlider(
                  label: '保険金などの補填',
                  value: _draft.medicalInsuranceReimbursement,
                  min: 0,
                  max: 420000,
                  divisions: 42,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(
                      medicalInsuranceReimbursement: value,
                    ),
                  ),
                ),
                _AmountSlider(
                  label: '総所得金額等',
                  value: _draft.totalIncome,
                  min: 0,
                  max: 12000000,
                  divisions: 120,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(totalIncome: value),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '医療費控除は「医療費 - 保険金等 - 10万円等」に所得税率と住民税目安を掛けて表示します。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ),
                _AmountSlider(
                  label: '月額サブスク合計',
                  value: _draft.monthlySubscriptions,
                  min: 0,
                  max: 50000,
                  divisions: 50,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(monthlySubscriptions: value),
                  ),
                ),
                _StepperRow(
                  label: '契約本数',
                  value: _draft.subscriptionCount,
                  min: 0,
                  max: 30,
                  unit: '本',
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(subscriptionCount: value),
                  ),
                ),
                _StepperRow(
                  label: '未使用候補',
                  value: _draft.unusedSubscriptionCount,
                  min: 0,
                  max: 30,
                  unit: '本',
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(
                      unusedSubscriptionCount: value,
                    ),
                  ),
                ),
                _StepperRow(
                  label: '最終利用から',
                  value: _draft.unusedSubscriptionMonths,
                  min: 0,
                  max: 24,
                  unit: 'か月',
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(
                      unusedSubscriptionMonths: value,
                    ),
                  ),
                ),
                SwitchListTile(
                  value: _draft.hasHomeLoan,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(hasHomeLoan: value),
                  ),
                  title: const Text('住宅ローンあり'),
                ),
                SwitchListTile(
                  value: _draft.hasCaregiving,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(hasCaregiving: value),
                  ),
                  title: const Text('介護関連の支出あり'),
                ),
                SwitchListTile(
                  value: _draft.recentMove,
                  onChanged: (value) => setState(
                    () => _draft = _draft.copyWith(recentMove: value),
                  ),
                  title: const Text('最近引越しをした'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      widget.onChanged(
                        _draft.copyWith(city: _cityController.text),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('世帯条件を保存しました')),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('世帯条件を保存'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text(
              'プライバシーとデータの扱い',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('この確認版では世帯情報を端末内に保存し、外部送信しません。'),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onPrivacyTap,
          ),
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit = '人',
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton.filledTonal(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(width: 70, child: Center(child: Text('$value$unit'))),
          IconButton.filledTonal(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _AmountSlider extends StatelessWidget {
  const _AmountSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int divisions;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(
                formatYen(value),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions,
            label: formatYen(value),
            onChanged: (next) => onChanged(next.round()),
          ),
        ],
      ),
    );
  }
}

class _InsightsPage extends StatelessWidget {
  const _InsightsPage({
    required this.opportunities,
    required this.reminderPlan,
    required this.completedSteps,
    required this.actualRecovered,
    required this.premiumUnlocked,
    required this.remindersEnabled,
    required this.onPlanTap,
    required this.onRemindersChanged,
  });

  final List<GimmeOpportunity> opportunities;
  final List<GimmeReminder> reminderPlan;
  final Set<String> completedSteps;
  final Map<String, int> actualRecovered;
  final bool premiumUnlocked;
  final bool remindersEnabled;
  final VoidCallback onPlanTap;
  final Future<void> Function(bool value) onRemindersChanged;

  @override
  Widget build(BuildContext context) {
    final annualRange = annualizedPotentialRange(opportunities);
    final prepared = preparedAmount(opportunities, completedSteps);
    final actual = actualRecoveredAmount(actualRecovered);
    return ListView(
      key: const ValueKey('insights'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        Text('成果とプラン', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '成果サマリー',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _PlanRow(label: '年間見込み', value: formatYenRange(annualRange)),
                _PlanRow(label: '申請準備完了額', value: formatYen(prepared)),
                _PlanRow(label: '実回収額', value: formatYen(actual)),
                _PlanRow(
                  label: '期限14日以内',
                  value: '${urgentCount(opportunities)}件',
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onPlanTap,
                  icon: Icon(
                    premiumUnlocked
                        ? Icons.verified_outlined
                        : Icons.workspace_premium_outlined,
                  ),
                  label: Text(
                    premiumUnlocked ? 'Gimme Plus 有効' : 'Gimme Plusを見る',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ReminderPlanCard(
          reminderPlan: reminderPlan,
          premiumUnlocked: premiumUnlocked,
          remindersEnabled: remindersEnabled,
          onPlanTap: onPlanTap,
          onChanged: onRemindersChanged,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Plusで継続する理由',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 10),
                _NativeReadyItem(
                  icon: Icons.notifications_active_outlined,
                  title: '通知予定',
                  text: '実締切日から逆算した通知予定を保存し、正式モバイル版ではローカル通知へ接続します。',
                ),
                _NativeReadyItem(
                  icon: Icons.lock_open_outlined,
                  title: '詳細解放',
                  text: '無料ではぼかした金額を、Plusでは制度名・手順・書類まで解放します。',
                ),
                _NativeReadyItem(
                  icon: Icons.family_restroom_outlined,
                  title: '家族共有',
                  text: '配偶者や親の条件を同意つきで追加し、世帯全体を監視します。',
                ),
              ],
            ),
          ),
        ),
        const _ComplianceNote(),
      ],
    );
  }
}

class _ReminderPlanCard extends StatelessWidget {
  const _ReminderPlanCard({
    required this.reminderPlan,
    required this.premiumUnlocked,
    required this.remindersEnabled,
    required this.onPlanTap,
    required this.onChanged,
  });

  final List<GimmeReminder> reminderPlan;
  final bool premiumUnlocked;
  final bool remindersEnabled;
  final VoidCallback onPlanTap;
  final Future<void> Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = premiumUnlocked && remindersEnabled;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '通知予定',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: premiumUnlocked
                      ? (value) async => onChanged(value)
                      : (_) => onPlanTap(),
                ),
              ],
            ),
            Text(
              premiumUnlocked
                  ? enabled
                        ? 'この端末に通知予定を保存しています。正式モバイル版ではOS通知に接続します。'
                        : 'Plusで通知予定を使うにはスイッチを有効にしてください。'
                  : 'Plusで締切前の通知予定を保存できます。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            ...reminderPlan
                .take(4)
                .map(
                  (reminder) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_available_outlined),
                    title: Text(
                      reminder.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(reminder.reason),
                    trailing: Text(
                      formatDeadline(reminder.scheduledFor),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class PaywallPage extends StatelessWidget {
  const PaywallPage({
    super.key,
    required this.entitlement,
    required this.remindersEnabled,
    required this.reminderPlan,
    required this.onUnlockChanged,
    required this.onRestorePurchases,
    required this.onRemindersChanged,
  });

  final EntitlementSnapshot entitlement;
  final bool remindersEnabled;
  final List<GimmeReminder> reminderPlan;
  final Future<void> Function(bool value) onUnlockChanged;
  final Future<void> Function() onRestorePurchases;
  final Future<void> Function(bool value) onRemindersChanged;

  @override
  Widget build(BuildContext context) {
    final unlocked = entitlement.unlocked;
    return Scaffold(
      appBar: AppBar(title: const Text('Gimme Plus')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12312E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Tag(label: 'Android/iOS store-ready'),
                      const SizedBox(height: 14),
                      const Text(
                        '取り損ねを毎月の習慣に戻す',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '全候補、制度名、必要書類、通知予定、実回収記録、AI明細スキャンを解放します。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFD6E8E4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '¥1,480',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '/月',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: const Color(0xFFD6E8E4)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Plusで解放するもの',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        const _PlanFeature(
                          icon: Icons.lock_open_outlined,
                          title: '候補の全件表示',
                          text: '無料版で隠れている候補と金額レンジ、制度名、推定根拠を解放します。',
                        ),
                        const _PlanFeature(
                          icon: Icons.notification_important_outlined,
                          title: '通知予定の保存',
                          text: '実締切日から逆算した予定を保存し、正式モバイル版ではOS通知へ接続します。',
                        ),
                        const _PlanFeature(
                          icon: Icons.auto_awesome_outlined,
                          title: 'AI明細スキャン',
                          text: '明細テキストから定期課金を抽出し、サブスク回収額に反映します。',
                        ),
                        const SizedBox(height: 12),
                        _PlanRow(label: '権限状態', value: entitlement.badgeLabel),
                        _PlanRow(
                          label: '通知予定',
                          value: '${reminderPlan.length}件',
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: unlocked && remindersEnabled,
                          onChanged: unlocked
                              ? (value) async {
                                  await onRemindersChanged(value);
                                }
                              : null,
                          title: const Text(
                            'Plus通知予定を有効化',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: const Text(
                            'Web確認版では予定保存、正式版ではローカル通知へ接続します。',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () async {
                            await onUnlockChanged(!unlocked);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    !unlocked
                                        ? 'Web確認版のPlusプレビューを有効にしました'
                                        : 'Web確認版のPlusプレビューを解除しました',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            unlocked
                                ? Icons.lock_open_outlined
                                : Icons.workspace_premium_outlined,
                          ),
                          label: Text(
                            unlocked
                                ? 'Plusプレビューを解除'
                                : kIsWeb
                                ? 'Web確認版でPlusを試す'
                                : 'ストアでPlusを開始',
                          ),
                        ),
                        if (!kIsWeb) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: onRestorePurchases,
                            icon: const Icon(Icons.restore_outlined),
                            label: const Text('購入を復元'),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          kIsWeb
                              ? '商品ID: $gimmePlusProductId。Web確認版では購入を発生させず、Android/iOS正式版ではアプリ内課金ブリッジからGoogle Play Billing / StoreKitへ接続します。'
                              : '商品ID: $gimmePlusProductId。購入更新と復元が確認できた時だけStore Plusとして有効化します。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プライバシー')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
              children: const [
                _PolicySection(
                  title: '確認版のデータ保存',
                  text:
                      'このWeb確認版では、世帯人数、医療費、サブスク額、チェックリスト、実回収額を端末内の保存領域にのみ保存します。外部サーバーへ送信しません。',
                ),
                _PolicySection(
                  title: '正式版で追加される可能性',
                  text:
                      'Android/iOS正式版では、制度データ更新、通知、家族共有、課金管理のためにサーバー連携を追加する可能性があります。その場合は送信項目、保存期間、削除方法を明記します。',
                ),
                _PolicySection(
                  title: '金額表示について',
                  text:
                      '表示額は見落とし候補を発見するための概算レンジです。税務、法律、行政手続きの助言ではありません。申請前には一次情報と専門家情報を確認してください。',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  const _PlanFeature({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _NativeReadyItem extends StatelessWidget {
  const _NativeReadyItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.warning = false});

  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFF1E7) : const Color(0xFFEFF6F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: warning ? const Color(0xFF9A3412) : const Color(0xFF0F766E),
        ),
      ),
    );
  }
}

class _ComplianceNote extends StatelessWidget {
  const _ComplianceNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        '表示内容は確認用のデモです。実際の申請前には自治体・税務署・専門家の情報で確認してください。',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
      ),
    );
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case '子育て':
      return const Color(0xFF2563EB);
    case '住宅':
      return const Color(0xFF7C3AED);
    case '医療':
      return const Color(0xFFDC2626);
    case '固定費':
      return const Color(0xFF0F766E);
    case '介護':
      return const Color(0xFFB45309);
    case '生活':
      return const Color(0xFF0891B2);
    case 'Plus':
      return const Color(0xFF0F766E);
    default:
      return const Color(0xFF475569);
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case '子育て':
      return Icons.child_care_outlined;
    case '住宅':
      return Icons.house_outlined;
    case '医療':
      return Icons.medical_services_outlined;
    case '固定費':
      return Icons.credit_card_outlined;
    case '介護':
      return Icons.elderly_outlined;
    case '生活':
      return Icons.move_down_outlined;
    case 'Plus':
      return Icons.workspace_premium_outlined;
    default:
      return Icons.receipt_long_outlined;
  }
}
