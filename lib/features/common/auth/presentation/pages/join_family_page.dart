import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

/// A second parent joining an existing family, using the Join family artboard's
/// code boxes.
class JoinFamilyPage extends StatefulWidget {
  const JoinFamilyPage({super.key});

  @override
  State<JoinFamilyPage> createState() => _JoinFamilyPageState();
}

class _JoinFamilyPageState extends State<JoinFamilyPage> {
  final _code = TextEditingController();
  static const int _codeLength = 4;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool get _canSubmit => _code.text.trim().length == _codeLength;

  void _submit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    context.read<ParentFamilyCubit>().joinFamily(_code.text.trim());
  }

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
                    child: SizedBox(
                      width: 280,
                      child: Text(
                        s.typeCodeFromOtherParent,
                        style: AppText.title1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                    child: DsCodeField(
                      controller: _code,
                      length: _codeLength,
                      enabled: !state.isLoading,
                      onCompleted: (_) => _submit(),
                    ),
                  ),
                  if (state.joinCodeError != null || state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                      child: Text(
                        state.joinCodeError ?? state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppText.metaSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.dangerDeep,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
                    child: DsPrimaryButton(
                      label: s.joinFamilyAction,
                      enabled: _canSubmit,
                      busy: state.isLoading,
                      onTap: _submit,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                    child: Text(
                      s.noCodeAskThem,
                      textAlign: TextAlign.center,
                      style: AppText.meta.copyWith(
                        color: AppColors.textTertiary,
                      ),
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
}
