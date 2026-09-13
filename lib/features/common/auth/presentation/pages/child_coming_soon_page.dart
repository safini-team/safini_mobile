import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';

/// Where a child account lands on iOS instead of the child home, from any door:
/// sign-in, a restored session, or a deep link. See `isChildModeAvailable`.
class ChildComingSoonPage extends StatelessWidget {
  const ChildComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: DsScreenEntrance(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: ChildComingSoonMessage(s: s)),
                DsPrimaryButton.secondary(
                  label: s.logout,
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final router = context.router;
    await context.read<AuthSessionCubit>().signOut();
    router.replaceAll([const NamedRoute('login')]);
  }
}

/// Mascot, title and the "use the Android phone" line, shared by the page and
/// the sheet on role selection.
class ChildComingSoonMessage extends StatelessWidget {
  const ChildComingSoonMessage({
    super.key,
    required this.s,
    this.compact = false,
  });

  final S s;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/logo/safini-mascot.png',
          width: compact ? 64 : 96,
          height: compact ? 64 : 96,
          fit: BoxFit.contain,
        ),
        SizedBox(height: compact ? 12 : 18),
        Text(s.kidComingSoonIosTitle, style: AppText.title3),
        const SizedBox(height: 10),
        Text(s.kidComingSoonIosBody, style: AppText.bodyRegular),
      ],
    );
  }
}
