import 'package:safini/features/child/presentation/screens/screen_time/ios_screen_time_screen.dart';
import 'package:safini/features/child/data/services/screen_time_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/child/data/services/app_block_service.dart';
import 'package:safini/features/child/presentation/cubit/app_block_cubit.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';
import 'package:safini/features/onboarding/kid_setup.dart';

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
    if (getIt<ScreenTimeService>().isSupported) {
      return IosScreenTimeGate(child: widget.child);
    }
    final cubit = context.read<ChildAppBlockCubit>();
    return BlocBuilder<ChildAppBlockCubit, AppBlockState>(
      builder: (context, state) {
        if (!state.showsSetup) {
          return widget.child;
        }
        return KidSetup(
          state: state,
          onRequest: (permission) => switch (permission) {
            KidPermission.usage => cubit.requestUsageAccess(),
            KidPermission.overlay => cubit.requestOverlayPermission(),
            KidPermission.admin => cubit.requestDeviceAdmin(),
          },
          onCheck: cubit.refreshPermissions,
          onBattery: () => showKidBatteryTips(
            context,
            onOpenSettings: cubit.requestBatterySettings,
          ),
        );
      },
    );
  }
}
