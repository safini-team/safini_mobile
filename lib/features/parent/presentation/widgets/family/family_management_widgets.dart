import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ParentManagementCard extends StatelessWidget {
  final FamilyModel family;
  final bool isLoading;
  final VoidCallback? onCreateParentInviteCode;
  final void Function(ParentSummaryModel) onParentTap;

  const ParentManagementCard({super.key, 
    required this.family,
    required this.isLoading,
    required this.onCreateParentInviteCode,
    required this.onParentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).parents,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (family.parents.isEmpty)
             ParentListTile(displayName: S.of(context).parentAccount, role: S.of(context).admin, onTap: () {})
          else
            ...family.parents.map(
              (parent) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ParentListTile(
                  displayName: parent.displayName,
                  role: parent.role,
                  onTap: () => onParentTap(parent),
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreateParentInviteCode,
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(S.of(context).createParentInviteCode),
            ),
          ),
        ],
      ),
    );
  }
}


class ParentListTile extends StatelessWidget {
  final String displayName;
  final String role;
  final VoidCallback onTap;

  const ParentListTile({super.key, required this.displayName, required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'P';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
          CircleAvatar(radius: 18, child: Text(initials)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(role, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

