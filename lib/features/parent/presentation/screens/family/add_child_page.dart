import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/notifications/on_push.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_cubit.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_page.dart';
import 'package:safini/features/onboarding/fini.dart';
import 'package:safini/features/onboarding/pairing_connected.dart';
import 'package:safini/features/onboarding/pairing_watch.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/family/family_sheets.dart';
import 'package:safini/features/subscription/free_limit.dart';

/// Adding a child: the Fini onboarding (boards A to E, SAF-272), then the
/// pairing code their phone needs.
///
/// Board A creates the child, so leaving later still keeps them; the Fini tab
/// picks the rest up from board B.
class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  late final _onboarding = FiniOnboardingCubit(
    repo: getIt<FiniRepository>(),
    createChild: _createChild,
  );

  /// Set once board A has created the child.
  String? _createdName;

  /// Set after board E; the screen then shows the pairing step.
  bool _onboarded = false;
  String? _pairingCode;

  /// Flips the waiting line to the connected screen once the kid's phone
  /// uses the code, from a poll or the `child_connected` push.
  PairingWatch? _watch;
  bool _connected = false;

  @override
  void dispose() {
    _watch?.stop();
    _onboarding.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnPush(
      types: const {PushType.childConnected},
      onPush: (_) => _watch?.checkNow(),
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) {
    if (!_onboarded) {
      return BlocProvider.value(
        value: _onboarding,
        child: FiniOnboardingFlow(
          onDone: () => setState(() => _onboarded = true),
          onLeave: () => context.router.maybePop(_createdName != null),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: DsScreenEntrance(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: 40 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: _connected
                ? _connectedView(context)
                : _pairing(context),
          ),
        ),
      ),
    );
  }

  // ── step 2 ──
  Widget _pairing(BuildContext context) {
    final s = S.of(context);
    final name = _createdName!;
    final code = _pairingCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
          child: SizedBox(
            width: 290,
            child: Text(s.codeIsReady(name), style: AppText.title1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: Text(s.step2of2, style: AppText.bodyRegular),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
          child: code == null
              ? DsCard(
                  radius: AppRadius.code,
                  shadow: AppShadows.flat,
                  padding: const EdgeInsets.symmetric(vertical: 34),
                  child: const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                )
              : DsCodePanel(
                  caption: s.pairingCodeCaption,
                  code: code,
                  codeSize: 40,
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
          child: DsGroup(
            radius: AppRadius.card,
            verticalPadding: 6,
            shadow: AppShadows.cardSoft,
            dividerIndent: 36,
            children: [
              _Step(index: 1, text: s.pairStepInstall(name)),
              _Step(index: 2, text: s.pairStepTap),
              _Step(index: 3, text: s.pairStepAllow),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: FiniSays(
            key: const ValueKey('pairing-waiting'),
            size: 64,
            pose: FiniPose.wait,
            text: s.waitingForPhone(name),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          child: DsPrimaryButton(
            label: s.goToMyFamily,
            onTap: () => context.router.maybePop(true),
          ),
        ),
      ],
    );
  }

  // ── connected ──
  Widget _connectedView(BuildContext context) => PairingConnected(
    name: _createdName!,
    onDone: () => context.router.maybePop(true),
  );

  void _watchPairing(ParentFamilyCubit cubit, String childId) {
    _watch?.stop();
    _watch = PairingWatch(
      isConnected: () async {
        await cubit.loadCurrentFamily(refresh: true);
        return cubit.state.family?.children.any(
              (c) => c.id == childId && (c.claimedByUserId ?? '').isNotEmpty,
            ) ??
            false;
      },
      onConnected: () {
        if (mounted) setState(() => _connected = true);
      },
    )..start();
  }

  /// Board A's Continue: creates the child, issues their pairing code and
  /// starts watching for the phone while the parent goes through B to E.
  Future<String> _createChild({
    required String name,
    required int age,
    String? gender,
  }) async {
    final cubit = context.read<ParentFamilyCubit>();
    final failure = await cubit.createChild(
      nickname: name,
      age: age,
      gender: gender,
    );
    // The Safini Pro sheet already explains a free-plan limit.
    if (failure is FreeLimitFailure) throw const QuietFailure();
    if (failure != null) throw _messageFor(failure);

    // The create call does not return the new child, so refresh and match on
    // the name to issue their pairing code.
    await cubit.loadCurrentFamily(refresh: true);
    final child = cubit.state.family?.children
        .where((c) => c.nickname == name)
        .lastOrNull;
    if (child == null) throw '';
    if (mounted) setState(() => _createdName = name);

    final invite = await cubit.createChildInviteCode(child.id);
    if (mounted) {
      setState(() => _pairingCode = invite?.inviteCode);
      if (invite != null) _watchPairing(cubit, child.id);
    }
    return child.id;
  }

  String _messageFor(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Session expired. Please sign in again.';
    }
    if (failure is ValidationFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    return 'Unable to create the child right now. Please try again.';
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
