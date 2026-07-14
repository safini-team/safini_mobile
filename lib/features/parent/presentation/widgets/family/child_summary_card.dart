import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ChildSummaryCard extends StatelessWidget {
  final ChildSummaryModel child;
  final VoidCallback onCreateInviteCode;
  final VoidCallback onEditChild;

  const ChildSummaryCard({super.key, 
    required this.child,
    required this.onCreateInviteCode,
    required this.onEditChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  child.nickname.isNotEmpty
                      ? child.nickname[0].toUpperCase()
                      : 'C',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.nickname,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      S.of(context).ageLabel(child.age),
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Coins', style: context.textTheme.bodySmall),
                  Text(
                    child.coinsBalance.toString(),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: child.claimedByUserId == null
                  ? onCreateInviteCode
                  : onEditChild,
              child: Text(
                child.claimedByUserId == null
                    ? S.of(context).createChildInviteCode
                    : S.of(context).editChild,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

