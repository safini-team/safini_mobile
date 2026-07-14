import 'package:safini/features/models/domain/models/family_model.dart';

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

  final int stepsToday;
  final String stepsChange;
  final String lessonsToday;
  final String lessonsChange;
  final List<double> weeklyUsage;

  /// App limits for the currently selected child.
  final List<Map<String, dynamic>> appLimits;

  /// The selected child's chosen face emoji (null → default avatar).
  final String? faceEmoji;

  /// Steps / lessons / weekly-usage have no backend GET endpoint yet, so those
  /// widgets are hidden until the API exposes real data. Flip to `true` once
  /// the backend provides it.
  final bool hasActivityData;

  const ParentMonitorLoaded({
    required this.children,
    this.selectedIndex = 0,
    required this.stepsToday,
    required this.stepsChange,
    required this.lessonsToday,
    required this.lessonsChange,
    required this.weeklyUsage,
    required this.appLimits,
    this.hasActivityData = false,
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
    bool? hasActivityData,
    String? faceEmoji,
    bool clearFaceEmoji = false,
  }) {
    return ParentMonitorLoaded(
      children: children ?? this.children,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      stepsToday: stepsToday,
      stepsChange: stepsChange,
      lessonsToday: lessonsToday,
      lessonsChange: lessonsChange,
      weeklyUsage: weeklyUsage,
      appLimits: appLimits ?? this.appLimits,
      hasActivityData: hasActivityData ?? this.hasActivityData,
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
