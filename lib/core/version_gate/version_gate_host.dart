import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          child: Stack(
            children: [
              widget.child,
              if (gate.showSoftBanner)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(bottom: false, child: SoftUpdateBanner()),
                ),
              if (gate.blocksApp)
                const Positioned.fill(child: HardUpdateGate()),
            ],
          ),
        );
      },
    );
  }
}
