import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

/// Naming the family, in the same form-card shape as "Add a child".
class CreateFamilyPage extends StatefulWidget {
  const CreateFamilyPage({super.key});

  @override
  State<CreateFamilyPage> createState() => _CreateFamilyPageState();
}

class _CreateFamilyPageState extends State<CreateFamilyPage> {
  final _name = TextEditingController();
  bool _hasAppliedDefaultName = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasAppliedDefaultName) return;
    _hasAppliedDefaultName = true;
    _name.text = S.of(context).myFamily;
    _name.selection = TextSelection.collapsed(offset: _name.text.length);
  }

  bool get _canSubmit => _name.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) => Localizations.override(
        context: context,
        locale: locale,
        child: Builder(builder: _build),
      ),
    );
  }

  Widget _build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<ParentFamilyCubit, ParentFamilyState>(
      listenWhen: (prev, curr) => curr.hasFamily && !prev.hasFamily,
      listener: (context, _) =>
          context.router.replace(const NamedRoute('parentHome')),
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.bgParent,
        body: DsScreenEntrance(
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: 40 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const DsBackButton(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: Text(s.createFamilyAction, style: AppText.title1),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: Text(s.nameYourFamily, style: AppText.bodyRegular),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                    child: DsGroup(
                      radius: AppRadius.card,
                      verticalPadding: 4,
                      shadow: AppShadows.cardSoft,
                      children: [
                        DsFieldRow(
                          label: s.familyLabel,
                          labelWidth: 62,
                          child: TextField(
                            controller: _name,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: AppColors.primary,
                            style: AppText.rowTitleLg,
                            decoration: DsFieldRow.decoration(s.myFamily),
                            onSubmitted: (_) => _submit(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                      child: Text(
                        state.errorMessage!,
                        style: AppText.metaSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.dangerDeep,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
                    child: DsPrimaryButton(
                      label: s.createFamilyAction,
                      enabled: _canSubmit,
                      busy: state.isLoading,
                      onTap: () => _submit(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    context.read<ParentFamilyCubit>().createFamily(name: _name.text.trim());
  }
}
