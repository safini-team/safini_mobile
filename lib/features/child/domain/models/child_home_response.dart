class ChildHomeResponse {
  final String childId;
  final String childNickname;
  final int doneToday;

  const ChildHomeResponse({
    required this.childId,
    required this.childNickname,
    required this.doneToday,
  });

  factory ChildHomeResponse.fromJson(Map<String, dynamic> json) {
    final child = json['child'];
    final childMap = child is Map
        ? child.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};
    final summary = json['summary'];
    final summaryMap = summary is Map
        ? summary.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};
    return ChildHomeResponse(
      childId: childMap['id']?.toString() ?? '',
      childNickname: childMap['nickname']?.toString() ?? '',
      doneToday: summaryMap['done_today'] is int
          ? summaryMap['done_today'] as int
          : int.tryParse(summaryMap['done_today']?.toString() ?? '') ?? 0,
    );
  }
}
