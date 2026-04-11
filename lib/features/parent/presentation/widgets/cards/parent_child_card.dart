import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/generated/l10n.dart';

class ParentChildCard extends StatelessWidget {
  final String name;
  final int age;
  final String gender;
  final int coins;
  final int quests;
  final int streak;
  final VoidCallback? onViewAsKid;
  final VoidCallback? onEdit;

  const ParentChildCard({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.coins,
    required this.quests,
    required this.streak,
    this.onViewAsKid,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: context.colorScheme.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: context.colorScheme.onSurface.withValues(alpha: 0.05),
                      child:
                          const Text('👦', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.colorScheme.onPrimary, width: 2),
                      ),
                      child: Text(
                        'Lv.5',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context).ageAndGender(age, gender),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildStat(
                          context,
                          coins.toString(),
                          S.of(context).coinsText,
                        ),
                        _buildStat(
                          context,
                          quests.toString(),
                          S.of(context).questsText,
                        ),
                        _buildStat(
                          context,
                          streak.toString(),
                          S.of(context).streakText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final viewButton = ElevatedButton.icon(
                onPressed: onViewAsKid,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text(S.of(context).viewAsKid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              );
              final editButton = OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: Text(S.of(context).edit),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorScheme.primary,
                  side: BorderSide(color: context.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              );
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    viewButton,
                    const SizedBox(height: 12),
                    editButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 2, child: viewButton),
                  const SizedBox(width: 12),
                  Expanded(child: editButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
