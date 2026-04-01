import 'package:safini/features/child/presentation/cubit/quest_model.dart';

class QuestState {
  final List<QuestModel> quests;

  const QuestState({required this.quests});

  const QuestState.initial() : quests = const [];

  int get completedCount => quests.where((q) => q.isCompleted).length;
  int get totalCount => quests.length;

  QuestState copyWith({List<QuestModel>? quests}) {
    return QuestState(quests: quests ?? this.quests);
  }
}
