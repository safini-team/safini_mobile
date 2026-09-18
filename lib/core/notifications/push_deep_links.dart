import 'dart:async';

import 'package:safini/core/notifications/push_event.dart';

/// A push the user tapped, on its way to the screen it is about.
///
/// A tap can arrive three ways - a cold start from a notification, a tap
/// while the app is backgrounded or open, or an `adb`/browser VIEW intent - so
/// it is held here rather than handed straight to a screen that may not exist
/// yet. [pending] survives until the screen for its destination takes it;
/// [stream] covers a shell that is already on screen.
class PushDeepLinks {
  final StreamController<PushTarget> _controller =
      StreamController<PushTarget>.broadcast();

  PushTarget? _pending;

  Stream<PushTarget> get stream => _controller.stream;

  PushTarget? get pending => _pending;

  bool get hasPending => _pending != null;

  void open(PushTarget target) {
    _pending = target;
    _controller.add(target);
  }

  /// The pending target, once, if it is for [destination]. A target for
  /// another screen stays pending for that screen.
  PushTarget? take(PushDestination destination) {
    final target = _pending;
    if (target == null || target.destination != destination) return null;
    _pending = null;
    return target;
  }

  /// Forget whatever is pending, e.g. on sign-out or a tap meant for the
  /// other kind of account.
  void clear() => _pending = null;

  /// `safini://children/<child id>/protection`, and nothing else.
  ///
  /// Anything that does not match returns null, so a malformed or hostile link
  /// cannot steer the app somewhere it should not go.
  static String? parseChildId(Uri uri) {
    if (uri.scheme != 'safini' || uri.host != 'children') return null;
    final segments = uri.pathSegments;
    if (segments.length != 2 || segments.last != 'protection') return null;
    final childId = segments.first;
    return childId.isEmpty ? null : childId;
  }

  Future<void> dispose() => _controller.close();
}
