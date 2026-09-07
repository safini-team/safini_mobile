import 'dart:async';

/// A protection alert the parent tapped, on its way to the Apps tab.
///
/// The link can arrive three ways - a cold start from a notification, a tap
/// while the app is backgrounded, or an `adb`/browser VIEW intent - so it is
/// held here rather than being handed straight to a screen that may not exist
/// yet. [pendingChildId] survives until a screen consumes it; [stream] covers
/// the case where the Apps tab is already on screen.
class PushDeepLinks {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  String? _pendingChildId;

  Stream<String> get stream => _controller.stream;

  bool get hasPending => _pendingChildId != null;

  void open(String childId) {
    _pendingChildId = childId;
    _controller.add(childId);
  }

  /// Returns the pending child id once, then forgets it.
  String? takeChildId() {
    final childId = _pendingChildId;
    _pendingChildId = null;
    return childId;
  }

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
