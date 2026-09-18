import 'dart:async';

import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/notifications/push_service.dart';

/// What the parent and the child shell each do with pushes.
///
/// While a shell is on screen its account is signed in, so that is when the
/// handset registers, in the app's current language, and it retries on every
/// resume. A tapped push switches to the tab it is about; the screen in that
/// tab takes the rest (which child, which task). A push meant for the other
/// kind of account, left in the tray from a previous sign-in, is dropped.
class PushShell {
  PushShell({
    required this.tabFor,
    required this.selectTab,
    this.consumedHere = const {},
  });

  /// The tab for a destination this shell owns, null for the other shell's.
  final int? Function(PushDestination destination) tabFor;
  final void Function(int index) selectTab;

  /// Destinations no screen inside the tab takes itself.
  final Set<PushDestination> consumedHere;

  StreamSubscription<PushTarget>? _targets;

  PushDeepLinks get _links => getIt<PushDeepLinks>();

  PushService? get _push =>
      getIt.isRegistered<PushService>() ? getIt<PushService>() : null;

  /// The tab to open on: where a tapped push is going, else [fallback].
  int initialTab(int fallback) {
    final target = _links.pending;
    return target == null ? fallback : _claim(target) ?? fallback;
  }

  void attach() => _targets = _links.stream.listen((target) {
    final tab = _claim(target);
    if (tab != null) selectTab(tab);
  });

  int? _claim(PushTarget target) {
    final tab = tabFor(target.destination);
    if (tab == null) {
      _links.clear();
    } else if (consumedHere.contains(target.destination)) {
      _links.take(target.destination);
    }
    return tab;
  }

  /// Registers, or re-registers when [languageCode] changed since last time.
  void register(String languageCode) {
    final push = _push;
    if (push != null) unawaited(push.start(locale: languageCode));
  }

  void resumed() {
    final push = _push;
    if (push != null) unawaited(push.start());
  }

  void dispose() => _targets?.cancel();
}
