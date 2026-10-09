// Dev-only harness for checking the redesigned screens against the Claude
// Design artboards without going through the login gate.
//
//   flutter run -t lib/design_preview.dart
//
// Every screen here is fed the artboard's own sample data (the `state` object
// in Safini.dc.html), so what renders should match the design pixel for pixel.
// Not part of the shipped app - `main.dart` never imports it.
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/design_preview_data.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';
import 'package:safini/features/child/presentation/screens/home/child_today_view.dart';
import 'package:safini/features/child/presentation/screens/profile/child_me_view.dart';
import 'package:safini/features/child/presentation/screens/store/child_store_view.dart';
import 'package:safini/features/child/presentation/screens/tasks/child_tasks_view.dart';
import 'package:safini/features/onboarding/fini.dart';
import 'package:safini/features/onboarding/getting_started_card.dart';
import 'package:safini/features/onboarding/getting_started_cubit.dart';
import 'package:safini/features/onboarding/kid_hello.dart';
import 'package:safini/features/onboarding/kid_setup.dart';
import 'package:safini/features/onboarding/pairing_connected.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_view.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_view.dart';
import 'package:safini/features/subscription/family_plan.dart';
import 'package:safini/features/subscription/free_limit.dart';
import 'package:safini/features/subscription/paywall_screen.dart';
import 'package:safini/features/subscription/pro_cubit.dart';
import 'package:safini/features/subscription/pro_store.dart';

void main() => runApp(const DesignPreviewApp());

class DesignPreviewApp extends StatefulWidget {
  const DesignPreviewApp({super.key});

  @override
  State<DesignPreviewApp> createState() => _DesignPreviewAppState();
}

class _DesignPreviewAppState extends State<DesignPreviewApp> {
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safini design preview',
      theme: AppTheme.light,
      locale: _locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: _Gallery(
        locale: _locale,
        onCycleLocale: () => setState(() {
          const order = ['ru', 'en', 'ky', 'uz', 'kk'];
          final next =
              order[(order.indexOf(_locale.languageCode) + 1) % order.length];
          _locale = Locale(next);
        }),
      ),
    );
  }
}

/// Opens the free-plan sheet over an empty parent screen.
class _FreeLimitPreview extends StatefulWidget {
  const _FreeLimitPreview({required this.canBuy});

  final bool canBuy;

  @override
  State<_FreeLimitPreview> createState() => _FreeLimitPreviewState();
}

class _FreeLimitPreviewState extends State<_FreeLimitPreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showFreeLimitSheet(
        context,
        FreeLimit.children,
        canBuy: widget.canBuy,
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class _Entry {
  const _Entry(this.label, this.background, this.builder);

  final String label;
  final Color background;
  final WidgetBuilder builder;
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.locale, required this.onCycleLocale});

  final Locale locale;
  final VoidCallback onCycleLocale;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 0;
  bool _switcherOpen = false;

  static final List<_Entry> _entries = [
    _Entry(
      'Safini Pro · paywall',
      AppColors.bgParent,
      (context) => PaywallScreen(cubit: _PreviewPro.free),
    ),
    _Entry(
      'Safini Pro · active',
      AppColors.bgParent,
      (context) => PaywallScreen(cubit: _PreviewPro.active),
    ),
    _Entry(
      'Free limit · iPhone',
      AppColors.bgParent,
      (context) => const _FreeLimitPreview(canBuy: true),
    ),
    _Entry(
      'Free limit · Android',
      AppColors.bgParent,
      (context) => const _FreeLimitPreview(canBuy: false),
    ),
    _Entry(
      'Parent Today',
      AppColors.bgParent,
      (context) => ParentTodayView(
        data: SampleData.parentToday,
        onSelectKid: (_) {},
        onOpenSettings: () {},
        onOpenReview: (_) {},
        onApproveReview: (_) {},
        onOpenLimits: () {},
      ),
    ),
    _Entry(
      'Parent Tasks',
      AppColors.bgParent,
      (context) => ParentTasksView(
        data: SampleData.parentTasks(S.of(context)),
        onSelectScope: (_) {},
        onSelectLane: (_) {},
        onOpenTask: (_) {},
        onNewTask: () {},
      ),
    ),
    _Entry(
      'Parent Limits',
      AppColors.bgParent,
      (context) => ParentLimitsView(
        data: SampleData.parentLimits,
        onSelectKid: (_) {},
        onOpenApp: (_) {},
        onAddApp: () {},
      ),
    ),
    _Entry(
      'Parent Family',
      AppColors.bgParent,
      (context) => ParentFamilyView(
        data: SampleData.parentFamily,
        onOpenParent: (_) {},
        onInviteParent: () {},
        onOpenChild: (_) {},
        onAddChild: () {},
        onOpenSettings: () {},
      ),
    ),
    _Entry(
      'Kid Today',
      AppColors.bgChild,
      (context) => ChildTodayView(
        data: SampleData.kidToday(S.of(context)),
        onOpenStore: () {},
        onOpenTasks: () {},
        onOpenQuest: (_) {},
        onSendQuest: (_) {},
      ),
    ),
    _Entry(
      'Kid Tasks',
      AppColors.bgChild,
      (context) => ChildTasksView(
        data: SampleData.kidTasks(S.of(context)),
        onSelectCategory: (_) {},
        onOpenTask: (_) {},
      ),
    ),
    _Entry(
      'Kid Store',
      AppColors.bgChild,
      (context) => ChildStoreView(
        data: SampleData.kidStore(S.of(context)),
        onSelectTab: (_) {},
        onOpenCard: (_) {},
      ),
    ),
    _Entry(
      'Kid Me',
      AppColors.bgChild,
      (context) => ChildMeView(
        data: SampleData.kidMe(S.of(context)),
        onChangeAvatar: () {},
        onEditName: () {},
      ),
    ),
    _Entry(
      'Parent Today · getting started',
      AppColors.bgParent,
      (context) => ParentTodayView(
        data: SampleData.parentToday,
        onSelectKid: (_) {},
        onOpenSettings: () {},
        onOpenReview: (_) {},
        onApproveReview: (_) {},
        onOpenLimits: () {},
        banner: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: GettingStartedCard(
            state: const GettingStarted(
              familyId: 'preview',
              done: {SetupStep.child, SetupStep.task},
              hidden: false,
            ),
            kidName: 'Amir',
            onOpen: (_) {},
            onHide: () {},
          ),
        ),
      ),
    ),
    _Entry(
      'Getting started · all done',
      AppColors.bgParent,
      (context) => ParentTodayView(
        data: SampleData.parentToday,
        onSelectKid: (_) {},
        onOpenSettings: () {},
        onOpenReview: (_) {},
        onApproveReview: (_) {},
        onOpenLimits: () {},
        banner: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: GettingStartedCard(
            state: GettingStarted(
              familyId: 'preview',
              done: SetupStep.values.toSet(),
              hidden: false,
            ),
            kidName: 'Amir',
            onOpen: (_) {},
            onHide: () {},
          ),
        ),
      ),
    ),
    _Entry(
      'Kid setup · step 1',
      AppColors.bgChild,
      (context) => KidSetup(
        state: const AppBlockState(status: AppBlockStatus.needsPermissions),
        onRequest: (_) {},
        onCheck: () {},
        onBattery: () => showKidBatteryTips(context, onOpenSettings: () {}),
      ),
    ),
    _Entry(
      'Kid setup · step 3',
      AppColors.bgChild,
      (context) => KidSetup(
        state: const AppBlockState(
          status: AppBlockStatus.needsPermissions,
          hasUsageAccess: true,
          hasOverlayPermission: true,
        ),
        onRequest: (_) {},
        onCheck: () {},
        onBattery: () {},
      ),
    ),
    _Entry(
      'Kid hello',
      AppColors.bgChild,
      (context) => Center(
        child: TextButton(
          onPressed: () => showKidHello(context),
          child: const Text('Say hi'),
        ),
      ),
    ),
    _Entry(
      'Fini poses',
      AppColors.bgParent,
      (context) => SafeArea(
        child: SizedBox.expand(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final pose in FiniPose.values) Fini(size: 150, pose: pose),
            ],
          ),
        ),
      ),
    ),
    _Entry(
      'Pairing · waiting',
      AppColors.bgParent,
      (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: FiniSays(
            size: 64,
            pose: FiniPose.wait,
            text: S.of(context).waitingForPhone('Amir'),
          ),
        ),
      ),
    ),
    _Entry(
      'Pairing · connected',
      AppColors.bgParent,
      (context) => SafeArea(
        child: PairingConnected(name: 'Amir', onDone: () {}),
      ),
    ),
    _Entry(
      'Parent Today · empty',
      AppColors.bgParent,
      (context) => ParentTodayView(
        data: SampleData.parentTodayEmptyReviews,
        onSelectKid: (_) {},
        onOpenSettings: () {},
        onOpenReview: (_) {},
        onApproveReview: (_) {},
        onOpenLimits: () {},
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final entry = _entries[_index];

    return Scaffold(
      backgroundColor: entry.background,
      extendBody: true,
      body: Stack(
        children: [
          KeyedSubtree(key: ValueKey(_index), child: entry.builder(context)),
          Positioned(
            right: 12,
            bottom: 120,
            child: _Switcher(
              open: _switcherOpen,
              label: '${entry.label}  ·  ${widget.locale.languageCode}',
              onCycleLocale: widget.onCycleLocale,
              entries: _entries,
              index: _index,
              onToggle: () => setState(() => _switcherOpen = !_switcherOpen),
              onPick: (i) => setState(() {
                _index = i;
                _switcherOpen = false;
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final s = S.of(context);
          return DsTabBar(
            currentIndex: 0,
            onTap: (_) {},
            items: [
              DsTabItem(
                label: s.tabToday,
                builder: (color) => AppIcons.tabHome(color: color),
              ),
              DsTabItem(
                label: s.tabTasks,
                builder: (color) => AppIcons.tabTasksParent(color: color),
                badge: 2,
              ),
              DsTabItem(
                label: s.tabLimits,
                builder: (color) => AppIcons.tabLimits(color: color),
              ),
              DsTabItem(
                label: s.tabFamily,
                builder: (color) => AppIcons.tabFamily(color: color),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Switcher extends StatelessWidget {
  const _Switcher({
    required this.open,
    required this.label,
    required this.entries,
    required this.index,
    required this.onToggle,
    required this.onPick,
    required this.onCycleLocale,
  });

  final VoidCallback onCycleLocale;
  final bool open;
  final String label;
  final List<_Entry> entries;
  final int index;
  final VoidCallback onToggle;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (open)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: const BoxConstraints(maxWidth: 240),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330C231C),
                  offset: Offset(0, 10),
                  blurRadius: 30,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Pressable.row(
                    onTap: () => onPick(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entries[i].label,
                              style: AppText.rowTitle.copyWith(
                                color: i == index
                                    ? AppColors.primary
                                    : AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Pressable(
          onTap: onToggle,
          onLongPress: onCycleLocale,
          scale: 0.94,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.primaryDeep,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              label,
              style: AppText.chip.copyWith(color: AppColors.textOnPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

/// App Store prices as App Store Connect has them (SAF-212), without StoreKit.
class _PreviewStore implements ProStore {
  @override
  Stream<List<StoreUpdate>> get updates => const Stream.empty();

  @override
  Future<List<ProOffer>> offers() async => const [
    ProOffer(
      productId: ProProducts.monthly,
      price: r'$6.99',
      rawPrice: 6.99,
      currencyCode: 'USD',
      trial: ProTrial(1, ProTrialUnit.week),
    ),
    ProOffer(
      productId: ProProducts.yearly,
      price: r'$66.99',
      rawPrice: 66.99,
      currencyCode: 'USD',
      trial: ProTrial(1, ProTrialUnit.month),
    ),
  ];

  @override
  Future<void> buy(ProOffer offer, {required String accountToken}) async {}

  @override
  Future<void> restore() async {}

  @override
  Future<List<StoreUpdate>> unfinished() async => const [];

  @override
  Future<void> finish(StoreUpdate update) async {}
}

class _PreviewPlans extends PlanApi {
  _PreviewPlans(this.plan) : super(Dio());

  final FamilyPlan plan;

  @override
  Future<FamilyPlan> current() async => plan;
}

class _PreviewPro {
  static final ProCubit free = ProCubit(
    api: _PreviewPlans(FamilyPlan.free),
    store: _PreviewStore(),
  );

  static final ProCubit active = ProCubit(
    api: _PreviewPlans(
      FamilyPlan(
        isPro: true,
        status: 'active',
        source: 'apple',
        productId: ProProducts.yearly,
        willRenew: true,
        expiresAt: DateTime(2027, 10, 8),
      ),
    ),
    store: _PreviewStore(),
  );
}
