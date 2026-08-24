import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/family/family_sheets.dart';

/// Steps 1 and 2 of the onboarding artboards: the child's details, then the
/// pairing code their phone needs.
///
/// The artboard's "Their colour" picker is not here - a child's colour is
/// derived from their id so it stays the same everywhere, and there is no field
/// to persist a choice. The row in its place is gender, which the API does take.
class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

enum _Gender {
  boy('boy'),
  girl('girl'),
  other('other');

  const _Gender(this.apiValue);

  final String apiValue;
}

class _AddChildPageState extends State<AddChildPage> {
  final _name = TextEditingController();

  int _age = 8;
  _Gender? _gender;
  bool _submitting = false;
  String? _error;

  /// Set once the child exists; the screen then shows the pairing step.
  String? _createdName;
  String? _pairingCode;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSubmit => _name.text.trim().isNotEmpty && !_submitting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: DsScreenEntrance(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: 40 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: _createdName == null ? _details(context) : _pairing(context),
          ),
        ),
      ),
    );
  }

  // ── step 1 ──
  Widget _details(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        DsBackButton(onTap: () => context.router.maybePop(false)),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: SizedBox(
            width: 280,
            child: Text(s.whoAreWeSettingUp, style: AppText.title1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: Text(s.step1of2, style: AppText.bodyRegular),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsGroup(
                radius: AppRadius.card,
                verticalPadding: 4,
                shadow: AppShadows.cardSoft,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(s.name, style: AppText.field),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _name,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: AppColors.primary,
                            style: AppText.button.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: false,
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: s.nameHintExample,
                              hintStyle: AppText.button.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(s.ageFieldLabel, style: AppText.field),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '$_age',
                            style: AppText.button.copyWith(
                              fontWeight: FontWeight.w500,
                            ).nums,
                          ),
                        ),
                        DsStepper(
                          onLess: () =>
                              setState(() => _age = (_age - 1).clamp(2, 18)),
                          onMore: () =>
                              setState(() => _age = (_age + 1).clamp(2, 18)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DsCard(
                radius: AppRadius.card,
                shadow: AppShadows.cardSoft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DsOverlineText(s.genderOptional),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in _Gender.values)
                          DsCategoryChip(
                            label: _genderLabel(s, option),
                            selected: _gender == option,
                            restBackground: AppColors.fill,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 9,
                            ),
                            onTap: () => setState(
                              () => _gender = _gender == option ? null : option,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: AppText.metaSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.dangerDeep,
                  ),
                ),
              ],
              const SizedBox(height: 26),
              DsPrimaryButton(
                label: s.continueAction,
                enabled: _canSubmit,
                busy: _submitting,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ],
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DsStatusDot(online: false, color: AppColors.coin, size: 7),
              const SizedBox(width: 9),
              Text(
                s.waitingForPhone(name),
                style: AppText.chip.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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

  String _genderLabel(S s, _Gender option) => switch (option) {
    _Gender.boy => s.genderBoy,
    _Gender.girl => s.genderGirl,
    _Gender.other => s.genderOther,
  };

  Future<void> _submit() async {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();

    final cubit = context.read<ParentFamilyCubit>();
    final name = _name.text.trim();

    setState(() {
      _submitting = true;
      _error = null;
    });

    final failure = await cubit.createChild(
      nickname: name,
      age: _age,
      gender: _gender?.apiValue,
    );
    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _submitting = false;
        _error = _messageFor(failure);
      });
      return;
    }

    setState(() {
      _submitting = false;
      _createdName = name;
    });

    // The create call does not return the new child, so refresh and match on
    // the name to issue their pairing code.
    await cubit.loadCurrentFamily(refresh: true);
    if (!mounted) return;

    final child = cubit.state.family?.children
        .where((c) => c.nickname == name)
        .lastOrNull;
    if (child == null) return;

    final invite = await cubit.createChildInviteCode(child.id);
    if (!mounted) return;
    setState(() => _pairingCode = invite?.inviteCode);
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
