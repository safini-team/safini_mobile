import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/onboarding/getting_started_card.dart';
import 'package:safini/features/onboarding/getting_started_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';

/// Hands Today's data to [GettingStartedCubit] and shows the card while it is
/// not hidden. Collapses to nothing, padding included, once it is.
class GettingStartedHost extends StatefulWidget {
  const GettingStartedHost({
    super.key,
    required this.familyId,
    required this.children,
    required this.selectedChildId,
    required this.hasTask,
    required this.hasLimit,
  });

  final String? familyId;
  final List<ChildSummaryModel> children;
  final String? selectedChildId;
  final bool hasTask;
  final bool hasLimit;

  @override
  State<GettingStartedHost> createState() => _GettingStartedHostState();
}

class _GettingStartedHostState extends State<GettingStartedHost> {
  @override
  void initState() {
    super.initState();
    _observeAfterFrame();
  }

  @override
  void didUpdateWidget(GettingStartedHost old) {
    super.didUpdateWidget(old);
    if (old.familyId != widget.familyId ||
        old.hasTask != widget.hasTask ||
        old.hasLimit != widget.hasLimit ||
        !listEquals(_paired(old.children), _paired(widget.children))) {
      _observeAfterFrame();
    }
  }

  static List<String> _paired(List<ChildSummaryModel> children) => [
    for (final child in children)
      '${child.id}:${(child.claimedByUserId ?? '').isNotEmpty}',
  ];

  // Not during build: the first emit would rebuild this subtree mid-frame.
  void _observeAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final familyId = widget.familyId;
      if (!mounted || familyId == null) return;
      context.read<GettingStartedCubit>().observe(
        familyId: familyId,
        childIds: [for (final child in widget.children) child.id],
        phoneConnected: widget.children.any(_isPaired),
        hasTask: widget.hasTask,
        hasLimit: widget.hasLimit,
      );
    });
  }

  static bool _isPaired(ChildSummaryModel child) =>
      (child.claimedByUserId ?? '').isNotEmpty;

  String get _kidName {
    final waiting = widget.children.where((c) => !_isPaired(c)).firstOrNull;
    final selected = widget.children
        .where((c) => c.id == widget.selectedChildId)
        .firstOrNull;
    return (waiting ?? selected ?? widget.children.firstOrNull)?.nickname ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GettingStartedCubit, GettingStarted>(
      builder: (context, state) => AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: AppMotion.spring,
        alignment: Alignment.topCenter,
        child: state.hidden || state.familyId != widget.familyId
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  14,
                  AppSpacing.gutter,
                  0,
                ),
                child: GettingStartedCard(
                  state: state,
                  kidName: _kidName,
                  onOpen: (step) => _open(context, step),
                  onHide: context.read<GettingStartedCubit>().hide,
                ),
              ),
      ),
    );
  }

  void _open(BuildContext context, SetupStep step) {
    final home = context.read<ParentHomeCubit>();
    switch (step) {
      case SetupStep.child:
        context.router.push(const NamedRoute('addChild'));
      case SetupStep.phone:
        home.selectTab(3);
      case SetupStep.task:
        home.selectTab(1);
      case SetupStep.limit:
        home.selectTab(2);
      case SetupStep.prize:
        home.openPrizes();
    }
  }
}
