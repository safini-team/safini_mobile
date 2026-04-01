import 'package:safini/features/parent/domain/models/parent_task_model.dart';

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
  final String childName;
  final String level;
  final int timeCoins;
  final int stepsToday;
  final String stepsChange;
  final String lessonsToday;
  final String lessonsChange;
  final List<double> weeklyUsage;
  final List<Map<String, dynamic>> appLimits;

  const ParentMonitorLoaded({
    required this.childName,
    required this.level,
    required this.timeCoins,
    required this.stepsToday,
    required this.stepsChange,
    required this.lessonsToday,
    required this.lessonsChange,
    required this.weeklyUsage,
    required this.appLimits,
  });
}

class ParentMonitorError extends ParentMonitorState {
  final String message;
  const ParentMonitorError(this.message);
}
