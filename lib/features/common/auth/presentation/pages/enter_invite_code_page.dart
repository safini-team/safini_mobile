import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_state.dart';

/// The Join family artboard: the code the parent read out, nothing else. No
/// sign-up wall on the kid side.
class EnterInviteCodePage extends StatefulWidget {
  const EnterInviteCodePage({super.key});

  @override
  State<EnterInviteCodePage> createState() => _EnterInviteCodePageState();
}

class _EnterInviteCodePageState extends State<EnterInviteCodePage> {
  final _code = TextEditingController();

  /// The backend issues four-character codes without ambiguous characters.
  static const int _length = 4;

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

  bool get _canSubmit => _code.text.trim().length == _length;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChildClaimCubit, ChildClaimState>(
      listener: (context, state) {
        if (state.status == ChildClaimStatus.success && state.child != null) {
          _onClaimed();
        }
      },
      builder: (context, state) {
        final s = S.of(context);
        final loading = state.status == ChildClaimStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.bgParent,
          resizeToAvoidBottomInset: true,
          body: DsScreenEntrance(
            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 270),
                        child: Text(
                          s.typeCodeFromParent,
                          style: AppText.title1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                      child: DsCodeField(
                        controller: _code,
                        length: _length,
                        enabled: !loading,
                        onCompleted: (_) => _submit(loading),
                      ),
                    ),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                        child: Text(
                          state.errorMessage!,
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
                        busy: loading,
                        onTap: () => _submit(loading),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                      child: Text(
                        s.noCodeAskParent,
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
        );
      },
    );
  }

  Future<void> _submit(bool loading) async {
    if (loading || !_canSubmit) return;
    FocusScope.of(context).unfocus();
    await context.read<ChildClaimCubit>().claimChild(
      _code.text.trim().toUpperCase(),
    );
  }

  Future<void> _onClaimed() async {
    final authCubit = context.read<AuthSessionCubit>();
    final router = context.router;

    // PRD v4 §9.3: the child app defaults to Uzbek. Skipped if the user has
    // already picked a language for themselves.
    await context.read<LocaleCubit>().applyChildDefault();
    if (!mounted) return;

    await authCubit.retryFetchProfile();
    if (!mounted) return;

    final auth = authCubit.state;
    if (auth.status == AuthSessionStatus.unauthenticated &&
        auth.isUnauthorized) {
      return;
    }

    // The backend can lag on `account_type`, but the claim itself succeeded,
    // so let the child through either way.
    router.replace(const NamedRoute('childHome'));
  }
}
