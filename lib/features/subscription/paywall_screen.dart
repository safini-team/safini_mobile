import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/subscription/family_plan.dart';
import 'package:safini/features/subscription/pro_cubit.dart';
import 'package:safini/features/subscription/pro_store.dart';
import 'package:url_launcher/url_launcher.dart';

/// Apple's subscriptions page, where only the subscriber can cancel.
const String appleManageSubscriptionsUrl =
    'https://apps.apple.com/account/subscriptions';

/// Settings → Safini Pro (SAF-213). What Pro adds, both plans priced by the
/// App Store, and everything App Review asks of a paywall (guideline 3.1.2):
/// name, length and price of each plan, auto-renew terms, Terms of Use,
/// Privacy Policy and Restore Purchases.
///
/// Only what the app actually does is listed. Pro lifts the free limits of
/// one child, three controlled apps and three recurring tasks (SAF-158).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key, this.cubit});

  /// Injected by tests; the app uses the shared one.
  final ProCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit ?? getIt<ProCubit>(),
      child: const _PaywallView(),
    );
  }
}

class _PaywallView extends StatefulWidget {
  const _PaywallView();

  @override
  State<_PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<_PaywallView> {
  ProPeriod _period = ProPeriod.year;

  @override
  void initState() {
    super.initState();
    final pro = context.read<ProCubit>();
    pro.refresh();
    if (pro.state.offers.isEmpty) pro.loadOffers();
  }

  void _onNotice(BuildContext context, ProState state) {
    final s = S.of(context);
    switch (state.notice) {
      case ProNotice.welcome:
        AppSnackBar.success(context, s.proWelcome);
      case ProNotice.restored:
        AppSnackBar.success(context, s.proRestored);
      case ProNotice.nothingToRestore:
        AppSnackBar.info(context, s.proNothingToRestore);
      case ProNotice.pending:
        AppSnackBar.info(context, s.proPending);
      case ProNotice.failed:
        AppSnackBar.error(context, s.proFailed);
      case ProNotice.otherFamily:
        AppSnackBar.error(context, s.proOtherFamily);
      case ProNotice.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: BlocConsumer<ProCubit, ProState>(
        listenWhen: (previous, next) => previous.noticeSeq != next.noticeSeq,
        listener: _onNotice,
        builder: (context, state) => Column(
          children: [
            DsNavBar(
              title: s.proTitle,
              backLabel: s.settings,
              onBack: () => context.router.maybePop(),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  12,
                  AppSpacing.gutter,
                  32 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                children: state.isPro
                    ? [_ActivePlan(plan: state.plan!)]
                    : [
                        Text(s.proHeadline, style: AppText.title1),
                        const SizedBox(height: 8),
                        Text(s.proLede, style: AppText.bodyRegular),
                        const SizedBox(height: 20),
                        const _Features(),
                        const SizedBox(height: 22),
                        _Plans(
                          state: state,
                          selected: _period,
                          onSelect: (period) =>
                              setState(() => _period = period),
                        ),
                        const SizedBox(height: 18),
                        DsPrimaryButton(
                          label: s.proSubscribe,
                          busy: state.busy,
                          enabled: state.offer(_period) != null && !state.busy,
                          onTap: () => context.read<ProCubit>().buy(_period),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          s.proLegal,
                          style: AppText.footnote,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        _LegalLinks(
                          onRestore: state.busy
                              ? null
                              : () => context.read<ProCubit>().restore(),
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

class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final features = [
      s.proFeatureChildren,
      s.proFeatureApps,
      s.proFeatureTasks,
      s.proFeatureParents,
    ];

    return DsCard(
      shadow: AppShadows.flat,
      radius: AppRadius.card,
      child: Column(
        children: [
          for (final (index, feature) in features.indexed)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    child: AppIcons.check(color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(feature, style: AppText.rowTitle)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Plans extends StatelessWidget {
  const _Plans({
    required this.state,
    required this.selected,
    required this.onSelect,
  });

  final ProState state;
  final ProPeriod selected;
  final ValueChanged<ProPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (state.offers.isEmpty) {
      if (state.offersFailed) {
        return DsCard(
          shadow: AppShadows.flat,
          child: Row(
            children: [
              Expanded(child: Text(s.proStoreUnavailable, style: AppText.body)),
              DsInlineButton.quiet(
                label: s.tryAgain,
                onTap: () => context.read<ProCubit>().loadOffers(),
              ),
            ],
          ),
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final saving = state.yearlySavingPercent;
    return Column(
      children: [
        for (final period in const [ProPeriod.year, ProPeriod.month])
          if (state.offer(period) case final offer?)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PlanTile(
                title: period == ProPeriod.year ? s.proYearly : s.proMonthly,
                price: period == ProPeriod.year
                    ? s.proPerYear(offer.price)
                    : s.proPerMonth(offer.price),
                badge: period == ProPeriod.year && saving != null
                    ? s.proSave(saving.toString())
                    : null,
                selected: selected == period,
                onTap: () => onSelect(period),
              ),
            ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        scale: 0.985,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryTint : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.strokeQuiet,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.rowTitleStrong),
                    const SizedBox(height: 3),
                    Text(price, style: AppText.body),
                  ],
                ),
              ),
              if (badge != null) DsPill.paid(label: badge!),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks({required this.onRestore});

  final VoidCallback? onRestore;

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    Widget link(String label, VoidCallback? onTap) => TextButton(
      onPressed: onTap,
      child: Text(label, style: AppText.link),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        link(s.proRestore, onRestore),
        link(s.proTerms, () => _open(AppConstants.termsOfUseUrl)),
        link(s.privacyPolicy, () => _open(AppConstants.privacyPolicyUrl)),
      ],
    );
  }
}

class _ActivePlan extends StatelessWidget {
  const _ActivePlan({required this.plan});

  final FamilyPlan plan;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final expires = plan.expiresAt;
    final date = expires == null
        ? null
        : DateFormat.yMMMd(locale).format(expires.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsCard.deep(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.proActiveTitle,
                style: AppText.title2.copyWith(color: AppColors.textOnPrimary),
              ),
              if (date != null) ...[
                const SizedBox(height: 6),
                Text(
                  plan.willRenew ? s.proRenewsOn(date) : s.proActiveUntil(date),
                  style: AppText.body.copyWith(color: AppColors.primaryPale),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _Features(),
        if (plan.source == 'apple') ...[
          const SizedBox(height: 18),
          DsPrimaryButton.secondary(
            label: s.proManage,
            onTap: () => launchUrl(
              Uri.parse(plan.manageUrl ?? appleManageSubscriptionsUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ],
    );
  }
}
