import 'package:flutter/foundation.dart';

/// `--dart-define=FINI_DEMO=true` swaps the Fini repository for a fake with
/// fixed fixtures, so the screenshot scripts can capture states the demo
/// account doesn't have without touching the production API.
///
/// Debug builds only, same as `IOS_CHILD_MODE_PREVIEW`: a release or profile
/// build ignores the define.
const bool _finiDemoDefine = bool.fromEnvironment('FINI_DEMO');

/// `--dart-define=FINI_DEMO_STATE=runningPlan` picks the fixture. Unknown or
/// empty falls back to the first state.
const String _finiDemoStateDefine = String.fromEnvironment('FINI_DEMO_STATE');

/// One fixture per state the Fini screens need. The fixtures themselves land
/// with the Fini repository (Fini 5) and are shared with the widget tests.
enum FiniDemoState {
  androidChildWithUsage,
  runningPlan,
  pendingTimeRequest,
  trialExpired,
}

/// Pure so the release gate is testable: tests always run in debug mode.
bool finiDemoEnabled({required bool debugBuild, required bool define}) =>
    debugBuild && define;

FiniDemoState finiDemoStateFrom(String name) => FiniDemoState.values
    .firstWhere((s) => s.name == name, orElse: () => FiniDemoState.values.first);

bool get isFiniDemo =>
    finiDemoEnabled(debugBuild: kDebugMode, define: _finiDemoDefine);

/// The fixture to serve, or null when the real repository is in use.
FiniDemoState? get finiDemoState =>
    isFiniDemo ? finiDemoStateFrom(_finiDemoStateDefine) : null;
