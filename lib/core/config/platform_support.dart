import 'package:flutter/foundation.dart';

/// A debug-only switch lets simulator QA exercise the iOS child flow while
/// release builds remain gated until a signed-device Screen Time test passes.
const bool _iosChildModePreview = bool.fromEnvironment(
  'IOS_CHILD_MODE_PREVIEW',
);

bool get isChildModeAvailable =>
    kIsWeb ||
    defaultTargetPlatform != TargetPlatform.iOS ||
    (kDebugMode && _iosChildModePreview);
