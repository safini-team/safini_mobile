import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/utils/widgets/language_sheet.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

/// Sign-in, laid out like the Welcome artboard: logo and wordmark up top, with
/// the public Google action and an optional debug/review email action below.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => const _LoginView();
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) => Localizations.override(
        context: context,
        locale: locale,
        delegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(builder: _build),
      ),
    );
  }

  Widget _build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<AuthSessionCubit, AuthSessionState>(
      listener: (context, state) {
        if (state.status == AuthSessionStatus.authenticated) {
          unawaited(_routeAuthenticated(context, state.accountType));
        }
        if (state.status == AuthSessionStatus.unauthenticated &&
            state.isUnauthorized) {
          AppSnackBar.error(context, state.errorMessage ?? s.signInError);
        }
        if (state.status == AuthSessionStatus.signInError) {
          AppSnackBar.error(context, state.errorMessage ?? s.signInError);
        }
        if (state.status == AuthSessionStatus.profileError) {
          AppSnackBar.error(context, state.errorMessage ?? s.networkError);
        }
      },
      builder: (context, state) {
        final loading =
            state.status == AuthSessionStatus.signingIn ||
            state.status == AuthSessionStatus.fetchingProfile;
        final supabaseBlocked = !SupabaseConfig.isSupabaseConfigured;
        final googleBlocked =
            supabaseBlocked || !SupabaseConfig.isGoogleConfigured;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: DsScreenEntrance(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Pressable(
                        onTap: () => showLanguageSheet(context),
                        scale: 0.94,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.fill,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            languageName(
                              Localizations.localeOf(context).languageCode,
                              s,
                            ),
                            style: AppText.chip,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fini alone - 'Safini' is set in the Text just below.
                          const Image(
                            image: AssetImage('assets/logo/safini-mascot.png'),
                            width: 96,
                            height: 96,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 18),
                          const Text('Safini', style: AppText.display),
                          const SizedBox(height: 18),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Text(s.loginSubtitle, style: AppText.lede),
                          ),
                        ],
                      ),
                    ),
                    if (!SupabaseConfig.isSupabaseConfigured)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          s.supabaseConfigMissing,
                          textAlign: TextAlign.center,
                          style: AppText.metaSm.copyWith(
                            color: AppColors.dangerDeep,
                          ),
                        ),
                      )
                    else if (!SupabaseConfig.isGoogleConfigured)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          s.googleClientIdMissing,
                          textAlign: TextAlign.center,
                          style: AppText.metaSm.copyWith(
                            color: AppColors.dangerDeep,
                          ),
                        ),
                      ),
                    if (!(state.status == AuthSessionStatus.profileError &&
                        state.isUnauthorized)) ...[
                      DsPrimaryButton(
                        label: loading ? s.signingIn : s.loginWithGoogle,
                        enabled: !googleBlocked,
                        busy: loading,
                        onTap: () =>
                            context.read<AuthSessionCubit>().signInWithGoogle(),
                      ),
                      if (SupabaseConfig.isEmailSignInEnabled) ...[
                        const SizedBox(height: 10),
                        DsPrimaryButton.secondary(
                          label: s.loginWithEmailTest,
                          enabled: !supabaseBlocked && !loading,
                          onTap: () => _showEmailSignInSheet(context),
                        ),
                      ],
                    ],
                    if (state.status == AuthSessionStatus.profileError &&
                        state.canRetry) ...[
                      const SizedBox(height: 10),
                      DsPrimaryButton.secondary(
                        label: s.retry,
                        onTap: () => context
                            .read<AuthSessionCubit>()
                            .retryFetchProfile(),
                      ),
                    ],
                    if (state.status == AuthSessionStatus.profileError &&
                        state.isUnauthorized) ...[
                      const SizedBox(height: 10),
                      DsPrimaryButton.secondary(
                        label: s.logout,
                        onTap: () => context.read<AuthSessionCubit>().signOut(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEmailSignInSheet(BuildContext context) {
    final auth = context.read<AuthSessionCubit>();
    return showDsSheet<void>(
      context: context,
      builder: (sheetContext) => _EmailSignInSheet(
        onSubmit: (email, password) {
          Navigator.of(sheetContext).pop();
          unawaited(auth.signInWithEmail(email: email, password: password));
        },
      ),
    );
  }

  Future<void> _routeAuthenticated(
    BuildContext context,
    String? accountType,
  ) async {
    switch (accountType) {
      case 'parent':
        await _routeParent(context);
      case 'child':
        if (!context.mounted) return;
        context.router.replace(const NamedRoute('childHome'));
      default:
        if (!context.mounted) return;
        context.router.replace(const NamedRoute('roleSelection'));
    }
  }

  Future<void> _routeParent(BuildContext context) async {
    await context.read<ParentFamilyCubit>().loadCurrentFamily(refresh: true);
    if (!context.mounted) return;

    final auth = context.read<AuthSessionCubit>().state;
    if (auth.status == AuthSessionStatus.unauthenticated) {
      context.router.replace(const NamedRoute('login'));
      return;
    }
    context.router.replace(const NamedRoute('parentHome'));
  }
}

class _EmailSignInSheet extends StatefulWidget {
  const _EmailSignInSheet({required this.onSubmit});

  final void Function(String email, String password) onSubmit;

  @override
  State<_EmailSignInSheet> createState() => _EmailSignInSheetState();
}

class _EmailSignInSheetState extends State<_EmailSignInSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.emailSignInTitle, style: AppText.title3),
          const SizedBox(height: 6),
          Text(s.emailSignInDescription, style: AppText.bodyRegular),
          const SizedBox(height: 20),
          DsGroup(
            color: AppColors.fillAlt,
            shadow: const [],
            radius: AppRadius.card,
            children: [
              DsFieldRow(
                label: s.emailLabel,
                labelWidth: 76,
                child: TextFormField(
                  controller: _emailController,
                  autofocus: true,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  cursorColor: AppColors.primary,
                  style: AppText.rowTitleLg,
                  decoration: DsFieldRow.decoration(s.emailHint),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty ||
                        !email.contains('@') ||
                        !email.contains('.')) {
                      return s.emailRequired;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
              ),
              DsFieldRow(
                label: s.passwordLabel,
                labelWidth: 76,
                child: TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  cursorColor: AppColors.primary,
                  style: AppText.rowTitleLg,
                  decoration: DsFieldRow.decoration(s.passwordHint).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? s.passwordRequired
                      : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DsPrimaryButton(label: s.signInAction, onTap: _submit),
        ],
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(_emailController.text.trim(), _passwordController.text);
  }
}
