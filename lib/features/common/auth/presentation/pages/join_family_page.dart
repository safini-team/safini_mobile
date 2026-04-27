import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

class JoinFamilyPage extends StatefulWidget {
  const JoinFamilyPage({super.key});

  @override
  State<JoinFamilyPage> createState() => _JoinFamilyPageState();
}

class _JoinFamilyPageState extends State<JoinFamilyPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Localizations.override(
          context: context,
          locale: locale,
          child: Builder(
            builder: (context) {
              if (!_initialized) {
                _initialized = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.read<ParentFamilyCubit>().markJoinFlow();
                  }
                });
              }

              final s = S.of(context);

              return BlocConsumer<ParentFamilyCubit, ParentFamilyState>(
                listener: (context, state) {
                  if (state.isDashboard && state.family != null) {
                    context.router.replace(const NamedRoute('parentHome'));
                  }
                },
                builder: (context, state) {
                  return Scaffold(
                    body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colorScheme.primary.withValues(alpha: 0.88),
                        context.colorScheme.primary,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () async {
                                  if (!await context.router.maybePop()) {
                                    context.router.replace(
                                      const NamedRoute('familyDecision'),
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: context.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.group_add_rounded,
                              color: context.colorScheme.onPrimary,
                              size: 72,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Join a family',
                              textAlign: TextAlign.center,
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: context.colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Enter the invite code shared by the family admin.',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: context.colorScheme.onPrimary.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 28),
                            TextFormField(
                              controller: _codeController,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              style: TextStyle(color: context.colorScheme.onPrimary),
                              decoration: InputDecoration(
                                labelText: 'Invite code',
                                labelStyle: TextStyle(
                                  color: context.colorScheme.onPrimary.withValues(alpha: 0.8),
                                ),
                                errorText: state.joinCodeError,
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an invite code.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 16),
                            if (state.errorMessage != null &&
                                state.stage != ParentFamilyStage.join) ...[
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.red.shade100,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            ElevatedButton(
                              onPressed: state.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colorScheme.onPrimary,
                                foregroundColor: context.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Join family'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () => context.read<ParentFamilyCubit>().joinFamily(
                                        _codeController.text,
                                      ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.colorScheme.onPrimary,
                                side: BorderSide(
                                  color: context.colorScheme.onPrimary.withValues(alpha: 0.8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(s.retry),
                            ),
                          ],
                        ),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.read<ParentFamilyCubit>().joinFamily(_codeController.text);
  }
}

