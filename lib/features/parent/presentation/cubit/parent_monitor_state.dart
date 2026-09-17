import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/screen_time_model.dart';

abstract class ParentMonitorState {
  const ParentMonitorState();
}

class ParentMonitorInitial extends ParentMonitorState {
  const ParentMonitorInitial();
}

class ParentMonitorLoading extends ParentMonitorState {
  const ParentMonitorLoading();
}

class ParentMonitorLoaded extends ParentMonitorState {
  /// All children in the family; the progress card is swipeable across them.
  final List<ChildSummaryModel> children;
  final int selectedIndex;

  /// App limits for the currently selected child.
  final List<Map<String, dynamic>> appLimits;

  /// The selected child's whole-device daily budget. The screen-time ring
  /// reads this; before it existed the ring drew usage against the sum of the
  /// per-app limits, which is not a budget anyone can spend.
  final ScreenTimeModel screenTime;

  /// Every app the selected child used today, rule or not. Null while it
  /// loads or when the request failed; the list then falls back to
  /// [appLimits].
  final DeviceUsage? deviceUsage;

  /// The selected child's chosen face emoji (null → default avatar).
  final String? faceEmoji;

  const ParentMonitorLoaded({
    required this.children,
    this.selectedIndex = 0,
    required this.appLimits,
    this.screenTime = ScreenTimeModel.none,
    this.deviceUsage,
    this.faceEmoji,
  });

  ChildSummaryModel? get selectedChild =>
      (selectedIndex >= 0 && selectedIndex < children.length)
          ? children[selectedIndex]
          : null;

  ParentMonitorLoaded copyWith({
    List<ChildSummaryModel>? children,
    int? selectedIndex,
    List<Map<String, dynamic>>? appLimits,
    ScreenTimeModel? screenTime,
    DeviceUsage? deviceUsage,
    bool clearDeviceUsage = false,
    String? faceEmoji,
    bool clearFaceEmoji = false,
  }) {
    return ParentMonitorLoaded(
      children: children ?? this.children,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      appLimits: appLimits ?? this.appLimits,
      screenTime: screenTime ?? this.screenTime,
      deviceUsage: clearDeviceUsage ? null : (deviceUsage ?? this.deviceUsage),
      faceEmoji: clearFaceEmoji ? null : (faceEmoji ?? this.faceEmoji),
    );
  }
}

/// The family has no child profile yet — the screen shows an empty state.
class ParentMonitorNoChild extends ParentMonitorState {
  const ParentMonitorNoChild();
}

class ParentMonitorError extends ParentMonitorState {
  final String message;
  const ParentMonitorError(this.message);
}
