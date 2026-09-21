import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/task_category.dart';

/// Localized task templates. A template only prefills the editor; the parent
/// can change every value before anything is created.
enum TaskIdea {
  makeBed('make-bed', '🛏️', TaskCategory.home, coins: 10, photoProof: true),
  brushTeeth(
    'brush-teeth',
    '🦷',
    TaskCategory.health,
    coins: 10,
    photoProof: true,
  ),
  tidyRoom('tidy-room', '🧹', TaskCategory.home, coins: 20, photoProof: true),
  putAwayToys('put-away-toys', '🧸', TaskCategory.home, coins: 10),
  homework(
    'homework',
    '✏️',
    TaskCategory.school,
    coins: 20,
    recurrence: 'weekly',
    recurrenceDays: weekdays,
  ),
  packSchoolBag(
    'pack-school-bag',
    '🎒',
    TaskCategory.school,
    coins: 10,
    recurrence: 'weekly',
    recurrenceDays: weekdays,
  ),
  read20('read-20', '📖', TaskCategory.learn, coins: 15),
  duolingo('duolingo', '🦉', TaskCategory.learn, coins: 20),
  practiceInstrument(
    'practice-instrument',
    '🎹',
    TaskCategory.learn,
    coins: 20,
    recurrence: 'weekly',
    recurrenceDays: weekdays,
  ),
  solvePuzzle('solve-puzzle', '🧩', TaskCategory.logic, coins: 15),
  exercise(
    'exercise',
    '🏃',
    TaskCategory.fitness,
    coins: 20,
    recurrence: 'weekly',
    recurrenceDays: mondayWednesdayFriday,
  ),
  feedPet('feed-pet', '🐕', TaskCategory.home, coins: 10),
  waterPlants(
    'water-plants',
    '🪴',
    TaskCategory.home,
    coins: 10,
    recurrence: 'weekly',
    recurrenceDays: mondayThursday,
  ),
  setTable('set-table', '🍽️', TaskCategory.home, coins: 10),
  putAwayLaundry(
    'put-away-laundry',
    '🧺',
    TaskCategory.home,
    coins: 15,
    recurrence: 'weekly',
    recurrenceDays: saturday,
  );

  const TaskIdea(
    this.key,
    this.emoji,
    this.category, {
    required this.coins,
    this.photoProof = false,
    this.recurrence = 'daily',
    this.recurrenceDays,
  });

  static const int weekdays = 1 | 2 | 4 | 8 | 16;
  static const int mondayWednesdayFriday = 1 | 4 | 16;
  static const int mondayThursday = 1 | 8;
  static const int saturday = 32;

  /// Saved as `metadata.idea` on a task added from this idea, so the list can
  /// tell which ideas are already on it.
  final String key;
  final String emoji;
  final TaskCategory category;
  final int coins;
  final bool photoProof;
  final String recurrence;
  final int? recurrenceDays;

  static const String metadataKey = 'idea';
  String title(S s) => switch (this) {
    TaskIdea.makeBed => s.taskIdeaMakeBedTitle,
    TaskIdea.brushTeeth => s.taskIdeaBrushTeethTitle,
    TaskIdea.tidyRoom => s.taskIdeaTidyRoomTitle,
    TaskIdea.putAwayToys => s.taskIdeaPutAwayToysTitle,
    TaskIdea.homework => s.taskIdeaHomeworkTitle,
    TaskIdea.packSchoolBag => s.taskIdeaPackSchoolBagTitle,
    TaskIdea.read20 => s.taskIdeaRead20Title,
    TaskIdea.duolingo => s.taskIdeaDuolingoTitle,
    TaskIdea.practiceInstrument => s.taskIdeaPracticeInstrumentTitle,
    TaskIdea.solvePuzzle => s.taskIdeaSolvePuzzleTitle,
    TaskIdea.exercise => s.taskIdeaExerciseTitle,
    TaskIdea.feedPet => s.taskIdeaFeedPetTitle,
    TaskIdea.waterPlants => s.taskIdeaWaterPlantsTitle,
    TaskIdea.setTable => s.taskIdeaSetTableTitle,
    TaskIdea.putAwayLaundry => s.taskIdeaPutAwayLaundryTitle,
  };

  String details(S s) => switch (this) {
    TaskIdea.makeBed => s.taskIdeaMakeBedDetails,
    TaskIdea.brushTeeth => s.taskIdeaBrushTeethDetails,
    TaskIdea.tidyRoom => s.taskIdeaTidyRoomDetails,
    TaskIdea.putAwayToys => s.taskIdeaPutAwayToysDetails,
    TaskIdea.homework => s.taskIdeaHomeworkDetails,
    TaskIdea.packSchoolBag => s.taskIdeaPackSchoolBagDetails,
    TaskIdea.read20 => s.taskIdeaRead20Details,
    TaskIdea.duolingo => s.taskIdeaDuolingoDetails,
    TaskIdea.practiceInstrument => s.taskIdeaPracticeInstrumentDetails,
    TaskIdea.solvePuzzle => s.taskIdeaSolvePuzzleDetails,
    TaskIdea.exercise => s.taskIdeaExerciseDetails,
    TaskIdea.feedPet => s.taskIdeaFeedPetDetails,
    TaskIdea.waterPlants => s.taskIdeaWaterPlantsDetails,
    TaskIdea.setTable => s.taskIdeaSetTableDetails,
    TaskIdea.putAwayLaundry => s.taskIdeaPutAwayLaundryDetails,
  };

  /// The idea a task was added from, or null for any other task.
  static TaskIdea? fromMetadata(Map<String, dynamic>? metadata) {
    final key = metadata?[metadataKey];
    for (final idea in values) {
      if (idea.key == key) return idea;
    }
    return null;
  }

  /// Templates stay available every time the chooser opens; parents may add
  /// the same routine again for a different child or schedule.
  static List<TaskIdea> offeredAlongside(Iterable<Map<String, dynamic>?> _) =>
      values;
}
