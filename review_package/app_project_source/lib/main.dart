import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gimme_model.dart';

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
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
  static const _medicalCostKey = 'medicalCost';
  static const _subscriptionsKey = 'subscriptions';
  static const _homeLoanKey = 'homeLoan';
  static const _caregivingKey = 'caregiving';
  static const _recentMoveKey = 'recentMove';
  static const _completedKey = 'completedSteps';
  static const _premiumKey = 'premiumUnlocked';

  HouseholdProfile _profile = HouseholdProfile.demo;
  Set<String> _completedSteps = <String>{};
  int _selectedIndex = 0;
  bool _loaded = false;
  bool _premiumUnlocked = false;
  SharedPreferences? _prefs;

  List<GimmeOpportunity> get _opportunities => buildOpportunities(_profile);

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _profile = HouseholdProfile(
        city: prefs.getString(_cityKey) ?? HouseholdProfile.demo.city,
        adults: prefs.getInt(_adultsKey) ?? HouseholdProfile.demo.adults,
        children: prefs.getInt(_childrenKey) ?? HouseholdProfile.demo.children,
        medicalCost:
            prefs.getInt(_medicalCostKey) ?? HouseholdProfile.demo.medicalCost,
        monthlySubscriptions:
            prefs.getInt(_subscriptionsKey) ??
            HouseholdProfile.demo.monthlySubscriptions,
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
      _premiumUnlocked = prefs.getBool(_premiumKey) ?? false;
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
    await prefs.setInt(_medicalCostKey, profile.medicalCost);
    await prefs.setInt(_subscriptionsKey, profile.monthlySubscriptions);
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

  Future<void> _setPremiumUnlocked(bool value) async {
    setState(() => _premiumUnlocked = value);
    await _prefs?.setBool(_premiumKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _DashboardPage(
        profile: _profile,
        opportunities: _opportunities,
        completedSteps: _completedSteps,
        onOpen: _openQuest,
        onPlanTap: _openPaywall,
      ),
      _OpportunitiesPage(
        opportunities: _opportunities,
        completedSteps: _completedSteps,
        onOpen: _openQuest,
      ),
      _HouseholdPage(
        profile: _profile,
        onChanged: _saveProfile,
        onPrivacyTap: _openPrivacy,
      ),
      _InsightsPage(
        opportunities: _opportunities,
        completedSteps: _completedSteps,
        premiumUnlocked: _premiumUnlocked,
        onPlanTap: _openPaywall,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: const _BrandTitle(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: () => setState(() => _selectedIndex = 2),
              icon: const Icon(Icons.group_outlined, size: 18),
              label: Text('${_profile.adults + _profile.children}人世帯'),
            ),
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
          completedSteps: _completedSteps,
          onStepChanged: _toggleStep,
        ),
      ),
    );
  }

  void _openPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaywallPage(
          unlocked: _premiumUnlocked,
          onUnlockChanged: _setPremiumUnlocked,
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
    required this.onOpen,
    required this.onPlanTap,
  });

  final HouseholdProfile profile;
  final List<GimmeOpportunity> opportunities;
  final Set<String> completedSteps;
  final ValueChanged<GimmeOpportunity> onOpen;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    final claimable = totalPotential(opportunities);
    final recovered = recoveredAmount(opportunities, completedSteps);
    final urgent = urgentCount(opportunities);
    final top = opportunities.first;

    return ListView(
      key: const ValueKey('dashboard'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        _HeroMoneyCard(
          claimable: claimable,
          recovered: recovered,
          urgent: urgent,
          onPlanTap: onPlanTap,
        ),
        const SizedBox(height: 14),
        _ShockCard(top: top, urgent: urgent),
        const SizedBox(height: 14),
        _HouseholdStrip(profile: profile),
        const SizedBox(height: 14),
        Text('次の奪還クエスト', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        _OpportunityCard(
          opportunity: top,
          progress: questProgress(top, completedSteps),
          onTap: () => onOpen(top),
          highlighted: true,
        ),
      ],
    );
  }
}

class _HeroMoneyCard extends StatelessWidget {
  const _HeroMoneyCard({
    required this.claimable,
    required this.recovered,
    required this.urgent,
    required this.onPlanTap,
  });

  final int claimable;
  final int recovered;
  final int urgent;
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
                '今月の概算奪還候補',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFD6E8E4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatYen(claimable),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '制度、控除、解約忘れを世帯単位でスキャンした概算中央値です。受給や返金を保証する金額ではありません。',
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
              _MetricPill(label: '準備済み', value: formatYen(recovered)),
              _MetricPill(label: '期限14日以内', value: '$urgent件'),
              const _MetricPill(label: '表示単位', value: 'レンジ推定'),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPlanTap,
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text('世帯プランで毎月監視'),
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
                    '放置すると取り損ねる候補があります',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '最優先は「${top.title}」。${formatYenRange(top.amountRange)}の範囲で確認価値があり、期限14日以内の候補が$urgent件あります。',
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE8F3F1),
              foregroundColor: Color(0xFF0F766E),
              child: Icon(Icons.home_work_outlined),
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
                    '大人${profile.adults}人 / 子ども${profile.children}人  |  医療費 ${formatYen(profile.medicalCost)}',
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
    required this.onOpen,
  });

  final List<GimmeOpportunity> opportunities;
  final Set<String> completedSteps;
  final ValueChanged<GimmeOpportunity> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('opportunities'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        Text('奪還候補', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '期限、見込み額、世帯条件から優先順位をつけています。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        ...opportunities.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OpportunityCard(
              opportunity: item,
              progress: questProgress(item, completedSteps),
              onTap: () => onOpen(item),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.opportunity,
    required this.progress,
    required this.onTap,
    this.highlighted = false,
  });

  final GimmeOpportunity opportunity;
  final double progress;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(opportunity.category);
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
                          opportunity.category,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 126,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatYenRange(opportunity.amountRange),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
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
                  _Tag(label: '概算レンジ'),
                  if (opportunity.urgent)
                    const _Tag(label: '期限近い', warning: true),
                  _Tag(label: '${opportunity.steps.length}ステップ'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestDetailPage extends StatelessWidget {
  const QuestDetailPage({
    super.key,
    required this.opportunity,
    required this.completedSteps,
    required this.onStepChanged,
  });

  final GimmeOpportunity opportunity;
  final Set<String> completedSteps;
  final Future<void> Function(String opportunityId, int index, bool value)
  onStepChanged;

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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Tag(label: opportunity.category),
                      const SizedBox(height: 12),
                      Text(
                        opportunity.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(opportunity.reason),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _BigStat(
                            label: '概算レンジ',
                            value: formatYenRange(opportunity.amountRange),
                          ),
                          _BigStat(
                            label: '期限',
                            value: '残り${opportunity.daysLeft}日',
                          ),
                          _BigStat(
                            label: '根拠強度',
                            value: opportunity.confidenceLabel,
                          ),
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
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('クエストを保存して戻る'),
                ),
                const SizedBox(height: 12),
                const _ComplianceNote(),
              ],
            ),
          ),
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

class _HouseholdPage extends StatelessWidget {
  const _HouseholdPage({
    required this.profile,
    required this.onChanged,
    required this.onPrivacyTap,
  });

  final HouseholdProfile profile;
  final ValueChanged<HouseholdProfile> onChanged;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('household'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        Text('世帯プロファイル', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '条件を変えると、奪還候補と見込み額が変わります。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  initialValue: profile.city,
                  decoration: const InputDecoration(
                    labelText: '居住地',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  onChanged: (value) =>
                      onChanged(profile.copyWith(city: value)),
                ),
                const SizedBox(height: 14),
                _StepperRow(
                  label: '大人',
                  value: profile.adults,
                  min: 1,
                  max: 4,
                  onChanged: (value) =>
                      onChanged(profile.copyWith(adults: value)),
                ),
                _StepperRow(
                  label: '子ども',
                  value: profile.children,
                  min: 0,
                  max: 5,
                  onChanged: (value) =>
                      onChanged(profile.copyWith(children: value)),
                ),
                const Divider(height: 28),
                _AmountSlider(
                  label: '年間医療費',
                  value: profile.medicalCost,
                  min: 0,
                  max: 420000,
                  divisions: 42,
                  onChanged: (value) =>
                      onChanged(profile.copyWith(medicalCost: value)),
                ),
                _AmountSlider(
                  label: '月額サブスク',
                  value: profile.monthlySubscriptions,
                  min: 0,
                  max: 50000,
                  divisions: 50,
                  onChanged: (value) =>
                      onChanged(profile.copyWith(monthlySubscriptions: value)),
                ),
                SwitchListTile(
                  value: profile.hasHomeLoan,
                  onChanged: (value) =>
                      onChanged(profile.copyWith(hasHomeLoan: value)),
                  title: const Text('住宅ローンあり'),
                ),
                SwitchListTile(
                  value: profile.hasCaregiving,
                  onChanged: (value) =>
                      onChanged(profile.copyWith(hasCaregiving: value)),
                  title: const Text('介護関連の支出あり'),
                ),
                SwitchListTile(
                  value: profile.recentMove,
                  onChanged: (value) =>
                      onChanged(profile.copyWith(recentMove: value)),
                  title: const Text('最近引越しをした'),
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
            onTap: onPrivacyTap,
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
  });

  final String label;
  final int value;
  final int min;
  final int max;
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
          SizedBox(width: 46, child: Center(child: Text('$value人'))),
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
    required this.completedSteps,
    required this.premiumUnlocked,
    required this.onPlanTap,
  });

  final List<GimmeOpportunity> opportunities;
  final Set<String> completedSteps;
  final bool premiumUnlocked;
  final VoidCallback onPlanTap;

  @override
  Widget build(BuildContext context) {
    final claimable = totalPotential(opportunities);
    final recovered = recoveredAmount(opportunities, completedSteps);
    final monthlyValue = (claimable / 12).round();
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
                  '世帯監視プラン仮説',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  '今月の概算中央値 ${formatYen(claimable)} に対して、月額1,480円の監視プランを提案できます。',
                ),
                const SizedBox(height: 14),
                _PlanRow(label: '申請準備済み', value: formatYen(recovered)),
                _PlanRow(label: '月あたり期待値', value: formatYen(monthlyValue)),
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ネイティブ版で伸ばす導線',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _NativeReadyItem(
                  icon: Icons.notifications_active_outlined,
                  title: '期限通知',
                  text: '申請期限と制度更新をプッシュ通知で届ける。',
                ),
                _NativeReadyItem(
                  icon: Icons.widgets_outlined,
                  title: 'ホーム画面ウィジェット',
                  text: '今月の取り戻せる金額を常時表示する。',
                ),
                _NativeReadyItem(
                  icon: Icons.group_add_outlined,
                  title: '家族共有',
                  text: '配偶者や親の条件を同意つきで追加する。',
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

class PaywallPage extends StatelessWidget {
  const PaywallPage({
    super.key,
    required this.unlocked,
    required this.onUnlockChanged,
  });

  final bool unlocked;
  final Future<void> Function(bool value) onUnlockChanged;

  @override
  Widget build(BuildContext context) {
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
                      const _Tag(label: 'Native-ready subscription'),
                      const SizedBox(height: 14),
                      const Text(
                        '毎月、取り損ねを先回りで見つける',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '制度更新、期限通知、家族共有、書類チェックをまとめて監視します。',
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
                          icon: Icons.notification_important_outlined,
                          title: '期限と制度更新の監視',
                          text: '住んでいる地域と世帯条件から、期限前に候補を出します。',
                        ),
                        const _PlanFeature(
                          icon: Icons.document_scanner_outlined,
                          title: '書類の抜け漏れチェック',
                          text: '提出前に必要書類と入力漏れをクエスト単位で確認します。',
                        ),
                        const _PlanFeature(
                          icon: Icons.family_restroom_outlined,
                          title: '家族共有',
                          text: '配偶者、親、子どもの条件を同意つきで管理します。',
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
                                        ? '確認版でGimme Plusを有効にしました'
                                        : '確認版でGimme Plusを無効にしました',
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
                            unlocked ? '確認版の有効状態を解除' : '確認版でPlusを有効化',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Web確認版では購入をシミュレートします。Android/iOS正式版ではGoogle Play Billing / StoreKitの商品IDに接続します。',
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
                      'このWeb確認版では、世帯人数、医療費、サブスク額、チェックリストの進捗を端末内の保存領域にのみ保存します。外部サーバーへ送信しません。',
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
    default:
      return Icons.receipt_long_outlined;
  }
}
