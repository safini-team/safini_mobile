import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/version_gate/hard_update_gate.dart';
import 'package:safini/core/version_gate/soft_update_banner.dart';
import 'package:safini/core/version_gate/version_gate_cubit.dart';
import 'package:safini/core/version_gate/version_gate_state.dart';

/// Overlay on [MaterialApp.builder] so parent and child share one check.
/// Does not block first paint; refresh runs in the background and fails open.
class VersionGateHost extends StatefulWidget {
  const VersionGateHost({super.key, required this.child});

  final Widget child;

  @override
  State<VersionGateHost> createState() => _VersionGateHostState();
}

class _VersionGateHostState extends State<VersionGateHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(context.read<VersionGateCubit>().refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      unawaited(context.read<VersionGateCubit>().refresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersionGateCubit, VersionGateState>(
      builder: (context, gate) {
        return PopScope(
          canPop: !gate.blocksApp,
          child: ColoredBox(
            color: AppColors.bgParent,
            child: Column(
              children: [
                if (gate.showSoftBanner)
                  const SafeArea(bottom: false, child: SoftUpdateBanner()),
                Expanded(
                  child: Stack(
                    children: [
                      MediaQuery(
                        data: _childMedia(context, gate.showSoftBanner),
                        child: widget.child,
                      ),
                      if (gate.blocksApp)
                        const Positioned.fill(child: HardUpdateGate()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// When the banner owns the top safe inset, screens below it should not
  /// pad for the notch a second time.
  MediaQueryData _childMedia(BuildContext context, bool bannerVisible) {
    final media = MediaQuery.of(context);
    if (!bannerVisible) return media;
    return media.copyWith(
      padding: media.padding.copyWith(top: 0),
      viewPadding: media.viewPadding.copyWith(top: 0),
    );
  }
}
