import 'package:safini/features/parent/domain/models/parent_monitor_model.dart';

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
  final ParentMonitorModel monitorModel;

  const ParentMonitorLoaded(this.monitorModel);
}

class ParentMonitorNoChild extends ParentMonitorState {
  const ParentMonitorNoChild();
}

class ParentMonitorError extends ParentMonitorState {
  final String message;
  const ParentMonitorError(this.message);
}
