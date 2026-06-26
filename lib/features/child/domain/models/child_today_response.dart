import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

class ChildTodayResponse {
  final String childId;
  final String childNickname;
  final int remainingToday;
  final List<ParentTaskInstanceModel> tasks;

  const ChildTodayResponse({
    required this.childId,
    required this.childNickname,
    required this.remainingToday,
    required this.tasks,
  });

  factory ChildTodayResponse.fromJson(Map<String, dynamic> json) {
    final child = json['child'];
    final childMap = child is Map
        ? child.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};
    final summary = json['summary'];
    final summaryMap = summary is Map
        ? summary.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};
    final rawTasks = json['tasks'];
    final tasks = rawTasks is List
        ? rawTasks
            .whereType<Map>()
            .map((item) =>
                ParentTaskInstanceModel.fromJson(
                  item.map((k, v) => MapEntry(k.toString(), v)),
                ))
            .toList()
        : <ParentTaskInstanceModel>[];
    return ChildTodayResponse(
      childId: childMap['id']?.toString() ?? '',
      childNickname: childMap['nickname']?.toString() ?? '',
      remainingToday: summaryMap['remaining_today'] is int
          ? summaryMap['remaining_today'] as int
          : int.tryParse(summaryMap['remaining_today']?.toString() ?? '') ?? 0,
      tasks: tasks,
    );
  }
}
