import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/task_category.dart';

/// The ready-made tasks a parent can start from on the Tasks list.
///
/// None of them exists until the parent opens one and adds it. The API used
/// to create four tasks for every new child instead, always in English, and
/// they sat on the list whether the parent wanted them or not.
///
/// Each idea only fills in the New Task sheet, so the parent can change any of
/// it first. All of them repeat daily; brushing teeth is the one that asks for
/// a photo.
enum TaskIdea {
  duolingo('duolingo', '🦉', TaskCategory.learn, coins: 20),
  steps('steps', '👟', TaskCategory.fitness, coins: 20),
  nap('nap', '😴', TaskCategory.health, coins: 10),
  brushTeeth(
    'brush-teeth',
    '🦷',
    TaskCategory.health,
    coins: 10,
    photoProof: true,
  );

  const TaskIdea(
    this.key,
    this.emoji,
    this.category, {
    required this.coins,
    this.photoProof = false,
  });

  /// Saved as `metadata.idea` on a task added from this idea, so the list can
  /// tell which ideas are already on it.
  final String key;
  final String emoji;
  final TaskCategory category;
  final int coins;
  final bool photoProof;

  static const String metadataKey = 'idea';
  static const String recurrence = 'daily';

  String title(S s) => switch (this) {
    TaskIdea.duolingo => s.taskIdeaDuolingoTitle,
    TaskIdea.steps => s.taskIdeaStepsTitle,
    TaskIdea.nap => s.taskIdeaNapTitle,
    TaskIdea.brushTeeth => s.taskIdeaBrushTeethTitle,
  };

  String details(S s) => switch (this) {
    TaskIdea.duolingo => s.taskIdeaDuolingoDetails,
    TaskIdea.steps => s.taskIdeaStepsDetails,
    TaskIdea.nap => s.taskIdeaNapDetails,
    TaskIdea.brushTeeth => s.taskIdeaBrushTeethDetails,
  };

  /// The idea a task was added from, or null for any other task.
  static TaskIdea? fromMetadata(Map<String, dynamic>? metadata) {
    final key = metadata?[metadataKey];
    for (final idea in values) {
      if (idea.key == key) return idea;
    }
    return null;
  }

  /// Which ideas to offer next to tasks carrying [metadata]: every idea on an
  /// empty list, the ones not added yet while each task came from an idea, and
  /// none once the parent has made a task of their own.
  static List<TaskIdea> offeredAlongside(
    Iterable<Map<String, dynamic>?> metadata,
  ) {
    final added = <TaskIdea>{};
    for (final entry in metadata) {
      final idea = fromMetadata(entry);
      if (idea == null) return const [];
      added.add(idea);
    }
    return [
      for (final idea in values)
        if (!added.contains(idea)) idea,
    ];
  }
}
