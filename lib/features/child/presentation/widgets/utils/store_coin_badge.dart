import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';

/// Reads coins from the root [CoinsCubit] — no parameter needed.
/// Always shows the current shared wallet balance.
class StoreCoinBadge extends StatelessWidget {
  const StoreCoinBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinsCubit, int>(
      builder: (context, coins) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 5),
              Text(
                '$coins',
                style: context.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'COINS',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

