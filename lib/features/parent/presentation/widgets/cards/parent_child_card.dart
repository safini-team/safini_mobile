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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: context.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      S.of(context).ageAndGender(age, gender),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
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
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;

              final viewButton = ElevatedButton.icon(
                onPressed: onViewAsKid,
                icon: const Icon(Icons.visibility),
                label: Text(S.of(context).viewAsKid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              );

              final editButton = OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.settings_outlined),
                label: Text(S.of(context).edit),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
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
                  Expanded(child: viewButton),
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
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );
  }
}
