import 'package:safini/core/translation/generated/l10n.dart';

/// The eight task categories, in the order the New Task sheet shows them.
///
/// There used to be two vocabularies for this one field: the backend seed
/// wrote `learn | fitness | logic | real_world` and the parent app's chips
/// wrote `home | school | health | outdoor`. Neither side validated, so both
/// ended up in the column and task lists printed whichever raw slug they
/// found, untranslated, in all three languages. The API now validates this
/// exact union (migration `20260824_0017`), and this is the client half of it.
///
/// `real_world` was folded into `home` by that migration; it is accepted on
/// read so a row written before the migration still renders.
enum TaskCategory {
  home('home', '🏠'),
  school('school', '🎓'),
  health('health', '🦷'),
  outdoor('outdoor', '⚽'),
  learn('learn', '📚'),
  fitness('fitness', '🏃'),
  logic('logic', '🧩'),
  other('other', '⭐');

  const TaskCategory(this.key, this.emoji);

  final String key;
  final String emoji;

  static const TaskCategory fallback = TaskCategory.other;

  /// Maps a server value onto a category. Unknown values become [other]
  /// rather than silently becoming the first chip, which is what used to
  /// rewrite a seeded task's category the moment a parent opened it.
  static TaskCategory? tryParse(String? raw) {
    final key = (raw ?? '').trim().toLowerCase();
    if (key.isEmpty) return null;
    if (key == 'real_world') return TaskCategory.home;
    for (final category in TaskCategory.values) {
      if (category.key == key) return category;
    }
    return TaskCategory.other;
  }

  String label(S s) => switch (this) {
    TaskCategory.home => s.catHome,
    TaskCategory.school => s.catSchool,
    TaskCategory.health => s.catHealth,
    TaskCategory.outdoor => s.catOutdoor,
    TaskCategory.learn => s.catLearn,
    TaskCategory.fitness => s.catFitness,
    TaskCategory.logic => s.catLogic,
    TaskCategory.other => s.catOther,
  };
}

/// The localized label for a raw category value, or empty when there is none.
///
/// Task rows used to print the slug itself, so a Russian parent read
/// "learn · 2026-08-23".
String taskCategoryLabel(S s, String? raw) =>
    TaskCategory.tryParse(raw)?.label(s) ?? '';
