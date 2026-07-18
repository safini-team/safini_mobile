import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class FamilyEmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const FamilyEmptyState({super.key, required this.onCreate, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Icon(
              Icons.family_restroom_rounded,
              size: 72,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(S.of(context).noFamilySetupYet, style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              S.of(context).createOrJoinFamily,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyChildrenState extends StatelessWidget {
  final VoidCallback onAddChild;

  const EmptyChildrenState({super.key, required this.onAddChild});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.child_care_rounded, size: 40),
          const SizedBox(height: 12),
          Text(S.of(context).noChildrenFoundYet, style: context.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            S.of(context).inviteChildOrRefresh,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAddChild, child: Text(S.of(context).addChild)),
        ],
      ),
    );
  }
}

class InlineErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorBanner({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class FamilyErrorState extends StatelessWidget {
  final String message;
  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const FamilyErrorState({super.key, 
    required this.message,
    required this.canRetry,
    required this.onRetry,
    required this.onCreate,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (canRetry)
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

