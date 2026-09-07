import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/data/services/app_block_service.dart';
import 'package:safini/features/child/presentation/cubit/app_block_cubit.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';

class ChildAppBlockGate extends StatefulWidget {
  final Widget child;
  const ChildAppBlockGate({super.key, required this.child});
  @override
  State<ChildAppBlockGate> createState() => _ChildAppBlockGateState();
}

class _ChildAppBlockGateState extends State<ChildAppBlockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getIt<AppBlockService>().setLanguage(
      Localizations.localeOf(context).languageCode,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ChildAppBlockCubit>().onResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ChildAppBlockCubit>();
    return BlocBuilder<ChildAppBlockCubit, AppBlockState>(
      builder: (context, state) {
        if (state.status == AppBlockStatus.unsupported ||
            state.status == AppBlockStatus.active) {
          return widget.child;
        }
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.shield_outlined, size: 56),
                const SizedBox(height: 20),
                Text(
                  s.limitsSetupTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(s.limitsSetupHint),
                const SizedBox(height: 24),
                ListTile(
                  title: Text(s.limitsUsageAccess),
                  trailing: Icon(
                    state.hasUsageAccess ? Icons.check_circle : Icons.settings,
                  ),
                  onTap: cubit.requestUsageAccess,
                ),
                ListTile(
                  title: Text(s.limitsOverlayAccess),
                  trailing: Icon(
                    state.hasOverlayPermission
                        ? Icons.check_circle
                        : Icons.settings,
                  ),
                  onTap: cubit.requestOverlayPermission,
                ),
                const SizedBox(height: 16),
                Text(s.limitsBatteryHint),
                TextButton(
                  onPressed: cubit.requestBatterySettings,
                  child: Text(s.limitsBattery),
                ),
                if (state.status == AppBlockStatus.error)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(s.limitsSetupError),
                  ),
                FilledButton(
                  onPressed: state.isChecking ? null : cubit.refreshPermissions,
                  child: state.isChecking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(s.limitsRetry),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
