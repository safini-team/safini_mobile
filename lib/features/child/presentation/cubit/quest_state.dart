import 'package:safini/features/child/presentation/cubit/quest_model.dart';

class QuestState {
  final List<QuestModel> quests;
  final String? childNickname;
  final int? doneToday;
  final bool isLoading;

  const QuestState({
    required this.quests,
    this.childNickname,
    this.doneToday,
    this.isLoading = false,
  });

  const QuestState.initial()
      : quests = const [],
        childNickname = null,
        doneToday = null,
        isLoading = true;

  int get completedCount =>
      doneToday ?? quests.where((q) => q.isCompleted || q.isSubmitted).length;

  int get totalCount => quests.length;

  QuestState copyWith({
    List<QuestModel>? quests,
    String? childNickname,
    int? doneToday,
    bool? isLoading,
  }) {
    return QuestState(
      quests: quests ?? this.quests,
      childNickname: childNickname ?? this.childNickname,
      doneToday: doneToday ?? this.doneToday,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
