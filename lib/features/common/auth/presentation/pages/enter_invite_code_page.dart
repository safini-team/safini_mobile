import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_state.dart';

class EnterInviteCodePage extends StatefulWidget {
  const EnterInviteCodePage({super.key});

  @override
  State<EnterInviteCodePage> createState() => _EnterInviteCodePageState();
}

class _EnterInviteCodePageState extends State<EnterInviteCodePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _inviteCodeController;

  @override
  void initState() {
    super.initState();
    _inviteCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChildClaimCubit, ChildClaimState>(
      listener: (context, state) {
        if (state.status == ChildClaimStatus.success && state.child != null) {
          _handleClaimSuccess();
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ChildClaimStatus.loading;

        return Scaffold(
          appBar: AppBar(title: const Text('Enter Invite Code')),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Continue as Child',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the invite code provided by your parent to claim your child profile.',
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _inviteCodeController,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Invite Code',
                        hintText: 'SAFE2026',
                      ),
                      validator: (value) {
                        final code = value?.trim() ?? '';
                        if (code.isEmpty) {
                          return 'Invite code is required.';
                        }
                        if (code.length < 4 || code.length > 16) {
                          return 'Invite code must be 4-16 characters.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(isLoading),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: context.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(isLoading),
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
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

  Future<void> _submit(bool isLoading) async {
    if (isLoading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final code = _inviteCodeController.text.trim().toUpperCase();

    await context.read<ChildClaimCubit>().claimChild(code);
  }

  Future<void> _handleClaimSuccess() async {
    final authCubit = context.read<AuthSessionCubit>();
    await authCubit.retryFetchProfile();
    if (!mounted) return;

    final authState = authCubit.state;
    if (authState.status == AuthSessionStatus.authenticated &&
        authState.accountType == 'child') {
      context.router.replace(const NamedRoute('childHome'));
      return;
    }

    if (authState.status == AuthSessionStatus.unauthenticated &&
        authState.isUnauthorized) {
      return;
    }

    // Backend may take a moment to reflect account_type updates.
    // The claim itself succeeded, so allow the child to continue.
    context.router.replace(const NamedRoute('childHome'));
  }
}
