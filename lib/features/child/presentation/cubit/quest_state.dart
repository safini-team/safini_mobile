import 'package:safini/features/child/presentation/cubit/quest_model.dart';

class QuestState {
  final List<QuestModel> quests;
  final String? childNickname;
  final int? doneToday;

  const QuestState({
    required this.quests,
    this.childNickname,
    this.doneToday,
  });

  const QuestState.initial()
      : quests = const [],
        childNickname = null,
        doneToday = null;

  int get completedCount =>
      doneToday ?? quests.where((q) => q.isCompleted || q.isSubmitted).length;

  int get totalCount => quests.length;

  QuestState copyWith({
    List<QuestModel>? quests,
    String? childNickname,
    int? doneToday,
  }) {
    return QuestState(
      quests: quests ?? this.quests,
      childNickname: childNickname ?? this.childNickname,
      doneToday: doneToday ?? this.doneToday,
    );
  }
}
