import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/common/auth/presentation/widgets/buttons/google_sign_in_button.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginView();
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Localizations.override(
          context: context,
          locale: locale,
          delegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          child: Builder(
            builder: (context) {
              final s = S.of(context);
              return BlocConsumer<AuthSessionCubit, AuthSessionState>(
                listener: (context, state) {
                  // ── Authenticated → route by account_type ──────────────
                  if (state.status == AuthSessionStatus.authenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.signedInSuccess)),
                    );
                    _routeAuthenticated(context, state.accountType);
                  }

                  // 401 in profile fetch signs out and returns to login.
                  if (state.status == AuthSessionStatus.unauthenticated &&
                      state.isUnauthorized) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage ?? s.signInError),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final loading =
                      state.status == AuthSessionStatus.signingIn ||
                          state.status == AuthSessionStatus.fetchingProfile;

                  return Scaffold(
                    body: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF9B59D0),
                            Color(0xFF7B3FA0),
                            Color(0xFF6A35B0),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.language,
                                    color: Colors.white,
                                  ),
                                  onPressed: () =>
                                      _showLanguageDialog(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Image.asset(
                                'assets/logo/app_logo.png',
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s.loginTitle,
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.loginSubtitle,
                                style:
                                    context.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white
                                      .withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (!SupabaseConfig.isSupabaseConfigured)
                                Text(
                                  s.supabaseConfigMissing,
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white),
                                )
                              else if (!SupabaseConfig.isGoogleConfigured)
                                Text(
                                  s.googleClientIdMissing,
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white),
                                )
                              else ...[
                                GoogleSignInButton(
                                  label: s.loginWithGoogle,
                                  loadingLabel: s.signingIn,
                                  isLoading: loading,
                                  onPressed: () => context
                                      .read<AuthSessionCubit>()
                                      .signInWithGoogle(),
                                ),
                                // ── Sign-in error ──────────────────────
                                if (state.status ==
                                    AuthSessionStatus.signInError) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    state.errorMessage ?? s.signInError,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.red.shade100,
                                    ),
                                  ),
                                ],
                                if (state.status == AuthSessionStatus.unauthenticated &&
                                    state.isUnauthorized) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    state.errorMessage ?? s.signInError,
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: Colors.red.shade100,
                                    ),
                                  ),
                                ],
                                // ── Profile-fetch error (retryable) ───
                                if (state.status ==
                                        AuthSessionStatus.profileError &&
                                    state.canRetry &&
                                    !state.isUnauthorized) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    state.errorMessage ??
                                        s.networkError,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.red.shade100,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () => context
                                        .read<AuthSessionCubit>()
                                        .retryFetchProfile(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    child: Text(s.retry),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _routeAuthenticated(BuildContext context, String? accountType) {
    switch (accountType) {
      case 'parent':
        _routeParent(context);
        break;
      case 'child':
        context.router.replace(const NamedRoute('childHome'));
        break;
      default:
        context.router.replace(const NamedRoute('roleSelection'));
    }
  }

  void _routeParent(BuildContext context) {
    final familyState = context.read<ParentFamilyCubit>().state;

    if (familyState.hasFamily || familyState.isDashboard) {
      context.router.replace(const NamedRoute('parentHome'));
      return;
    }

    if (familyState.isCreate) {
      context.router.replace(const NamedRoute('createFamily'));
    } else if (familyState.isJoin) {
      context.router.replace(const NamedRoute('joinFamily'));
    } else {
      context.router.replace(const NamedRoute('familyDecision'));
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(s.english),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(s.russian),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('ru'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(s.kazakh),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('kk'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
