import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/child/presentation/cubit/ios_screen_time_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';

/// Keeps policy current only while the child app is foreground. The native
/// monitor enforces the last downloaded rules independently of this widget.
class IosScreenTimeGate extends StatefulWidget {
  final Widget child;
  const IosScreenTimeGate({super.key, required this.child});
  @override
  State<IosScreenTimeGate> createState() => _IosScreenTimeGateState();
}

class _IosScreenTimeGateState extends State<IosScreenTimeGate>
    with WidgetsBindingObserver {
  final cubit = getIt<IosScreenTimeCubit>();
  Timer? _timer;
  bool _profileFailed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => cubit.refresh(),
    );
  }

  Future<void> _start() async {
    final profile = await getIt<ProfileController>().fetchMe();
    if (!mounted) return;
    final id = profile.fold((_) => null, (p) => p.childId);
    setState(() => _profileFailed = id == null);
    if (id != null) await cubit.start(id);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) {
      cubit.refresh();
      _timer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => cubit.refresh(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profileFailed) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: _start,
            child: Text(S.of(context).limitsRetry),
          ),
        ),
      );
    }
    return BlocBuilder<IosScreenTimeCubit, IosScreenTimeState>(
      bloc: cubit,
      builder: (context, state) => state.ready
          ? Column(
              children: [
                if (state.syncFailed)
                  Material(
                    child: SafeArea(
                      bottom: false,
                      child: ListTile(
                        title: Text(S.of(context).iosScreenTimeRetry),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: cubit.refresh,
                        ),
                      ),
                    ),
                  ),
                Expanded(child: widget.child),
              ],
            )
          : const IosScreenTimeScreen(setup: true),
    );
  }
}

class IosScreenTimeScreen extends StatelessWidget {
  final bool setup;
  const IosScreenTimeScreen({super.key, this.setup = false});
  @override
  Widget build(BuildContext context) {
    final cubit = getIt<IosScreenTimeCubit>();
    final s = S.of(context);
    return BlocBuilder<IosScreenTimeCubit, IosScreenTimeState>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(s.screenTime),
            actions: [
              if (setup)
                TextButton(
                  onPressed: state.busy
                      ? null
                      : () => context.read<AuthSessionCubit>().signOut(),
                  child: Text(s.logout),
                ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.shield_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  s.iosScreenTimeSetup,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(s.iosScreenTimeFamily),
                const SizedBox(height: 12),
                Text(s.iosScreenTimePrivacy),
                const SizedBox(height: 16),
                if (!state.authorized)
                  FilledButton(
                    onPressed: state.busy ? null : cubit.authorize,
                    child: Text(s.iosScreenTimeAllow),
                  ),
                if (state.authorized) ...[
                  Text(s.iosScreenTimeChoose),
                  for (final rule in state.rules)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(rule['display_name'] as String),
                      subtitle: Text(
                        state.mapped.contains(rule['app_slug'])
                            ? s.iosScreenTimeLinked
                            : s.iosScreenTimeSelect,
                      ),
                      trailing: Icon(
                        state.mapped.contains(rule['app_slug'])
                            ? Icons.check_circle_outline
                            : Icons.chevron_right,
                      ),
                      onTap:
                          state.busy || state.mapped.contains(rule['app_slug'])
                          ? null
                          : () => cubit.select(rule['app_slug'] as String),
                    ),
                  if (state.rules.isEmpty) Text(s.iosScreenTimeNoRules),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: state.busy
                        ? null
                        : () async {
                            try {
                              await cubit.native.showReport({
                                'title': s.screenTime,
                                'privacy': s.iosScreenTimePrivacy,
                                'today': s.tabToday,
                                'week': s.iosScreenTimeWeek,
                                'done': s.iosScreenTimeDone,
                              });
                            } catch (_) {
                              if (context.mounted) {
                                AppSnackBar.error(
                                  context,
                                  s.iosScreenTimeRetry,
                                );
                              }
                            }
                          },
                    child: Text(s.iosScreenTimeReport),
                  ),
                ],
                const SizedBox(height: 12),
                Text(s.iosScreenTimeSyncHint),
                if (state.syncFailed)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(s.iosScreenTimeRetry),
                  ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(state.error!),
                  ),
                TextButton(
                  onPressed: state.busy ? null : cubit.refresh,
                  child: Text(s.iosScreenTimeSync),
                ),
                if (state.busy) const LinearProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
