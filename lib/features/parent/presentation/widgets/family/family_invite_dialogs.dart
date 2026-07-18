import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/models/domain/models/child_invite_code_model.dart';
import 'package:safini/features/models/domain/models/parent_invite_code_model.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ParentInviteCodeDialog extends StatelessWidget {
  final ParentInviteCodeModel inviteCode;

  const ParentInviteCodeDialog({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    final expiryLocal = inviteCode.inviteCodeExpiresAt.toLocal();
    final date = MaterialLocalizations.of(context).formatFullDate(expiryLocal);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(expiryLocal));

    return InviteCodeDialog(
      title: S.of(context).parentInviteCodeTitle,
      code: inviteCode.inviteCode,
      expiresLabel: S.of(context).expiresLabel(date, time),
      icon: Icons.supervisor_account_rounded,
    );
  }
}


class ChildInviteCodeDialog extends StatelessWidget {
  final ChildInviteCodeModel inviteCode;

  const ChildInviteCodeDialog({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    final expiryLocal = inviteCode.inviteCodeExpiresAt.toLocal();
    final date = MaterialLocalizations.of(context).formatFullDate(expiryLocal);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(expiryLocal));

    return InviteCodeDialog(
      title: S.of(context).childInviteCodeTitle,
      code: inviteCode.inviteCode,
      expiresLabel: S.of(context).expiresLabel(date, time),
      icon: Icons.child_care_rounded,
    );
  }
}

class InviteCodeDialog extends StatelessWidget {
  final String title;
  final String code;
  final String expiresLabel;
  final IconData icon;

  const InviteCodeDialog({super.key, 
    required this.title,
    required this.code,
    required this.expiresLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SelectableText(
                    code,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  expiresLabel,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        AppSnackBar.success(
                          context,
                          S.of(context).inviteCodeCopied,
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(S.of(context).copy),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(S.of(context).close),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

