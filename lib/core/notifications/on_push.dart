import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/notifications/push_service.dart';

/// Runs [onPush] when a push of one of [types] arrives while the app is open.
///
/// The companion of `OnAppResume`: a screen that refetches when the app comes
/// back also has to refetch when a push says its data just changed under it,
/// or the notification banner and the screen behind it disagree.
class OnPush extends StatefulWidget {
  const OnPush({
    super.key,
    required this.types,
    required this.onPush,
    required this.child,
    this.events,
  });

  final Set<PushType> types;
  final ValueChanged<PushEvent> onPush;
  final Widget child;

  /// Defaults to the app's [PushService]; absent in builds without Firebase.
  final Stream<PushEvent>? events;

  @override
  State<OnPush> createState() => _OnPushState();
}

class _OnPushState extends State<OnPush> {
  StreamSubscription<PushEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    final events =
        widget.events ??
        (getIt.isRegistered<PushService>()
            ? getIt<PushService>().events
            : null);
    _subscription = events?.listen((event) {
      if (mounted && widget.types.contains(event.type)) widget.onPush(event);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
