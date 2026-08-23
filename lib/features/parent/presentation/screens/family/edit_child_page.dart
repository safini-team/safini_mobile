import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

/// Editing a child: the same form-card shape as "Add a child", pushed from the
/// child sheet on My family.
class EditChildPage extends StatefulWidget {
  const EditChildPage({super.key, required this.child});

  final ChildSummaryModel child;

  @override
  State<EditChildPage> createState() => _EditChildPageState();
}

enum _Gender {
  boy('boy'),
  girl('girl'),
  other('other');

  const _Gender(this.apiValue);

  final String apiValue;

  static _Gender? fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final option in _Gender.values) {
      if (option.apiValue == normalized) return option;
    }
    return null;
  }
}

class _EditChildPageState extends State<EditChildPage> {
  late final TextEditingController _name = TextEditingController(
    text: widget.child.nickname,
  );
  late int _age = widget.child.age;
  late _Gender? _gender = _Gender.fromApiValue(widget.child.gender);

  bool _submitting = false;
  String? _error;

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
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: Column(
        children: [
          DsNavBar(
            title: s.editName(widget.child.nickname),
            backLabel: s.myFamily,
            onBack: () => Navigator.of(context).pop(false),
          ),
          Expanded(
            child: DsScreenEntrance(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: 40 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                children: [
                  DsOverline(s.detailsSection, top: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: DsGroup(
                      radius: AppRadius.card,
                      verticalPadding: 4,
                      shadow: AppShadows.cardSoft,
                      children: [
                        DsFieldRow(
                          label: s.name,
                          labelWidth: 56,
                          child: TextField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: AppColors.primary,
                            style: AppText.rowTitleLg,
                            decoration: DsFieldRow.decoration(s.name),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 56,
                                child: Text(
                                  s.ageFieldLabel,
                                  style: AppText.field,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '$_age',
                                  style: AppText.rowTitleLg.nums,
                                ),
                              ),
                              DsStepper(
                                onLess: () => setState(
                                  () => _age = (_age - 1).clamp(2, 18),
                                ),
                                onMore: () => setState(
                                  () => _age = (_age + 1).clamp(2, 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DsOverline(s.genderOptional, top: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in _Gender.values)
                          DsCategoryChip(
                            label: _label(s, option),
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
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                      child: Text(
                        _error!,
                        style: AppText.metaSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.dangerDeep,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      26,
                      AppSpacing.gutter,
                      0,
                    ),
                    child: DsPrimaryButton(
                      label: s.save,
                      enabled: _canSubmit,
                      busy: _submitting,
                      onTap: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(S s, _Gender option) => switch (option) {
    _Gender.boy => s.genderBoy,
    _Gender.girl => s.genderGirl,
    _Gender.other => s.genderOther,
  };

  Future<void> _submit() async {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();

    final name = _name.text.trim();
    final currentGender = widget.child.gender?.trim();
    final gender = _gender?.apiValue;

    final changedName = name != widget.child.nickname ? name : null;
    final changedAge = _age != widget.child.age ? _age : null;
    final changedGender =
        gender != ((currentGender?.isEmpty ?? true) ? null : currentGender)
        ? gender
        : null;

    if (changedName == null && changedAge == null && changedGender == null) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final failure = await context.read<ParentFamilyCubit>().updateChild(
      widget.child.id,
      nickname: changedName,
      age: changedAge,
      gender: changedGender,
    );
    if (!mounted) return;

    setState(() => _submitting = false);

    if (failure == null) {
      AppSnackBar.success(context, S.of(context).childUpdatedSuccess);
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _error = _messageFor(failure));
  }

  String _messageFor(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Invalid or expired token. Please sign in again.';
    }
    if (failure is ValidationFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    return 'Unable to update the child right now. Please try again.';
  }
}
