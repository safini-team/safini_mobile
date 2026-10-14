import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/domain/fini_models.dart';

/// How a goal tile looks: the board "Add a goal" icons on the category
/// colours.
class GoalLook {
  const GoalLook(this.icon, this.color, this.background);

  /// Inner SVG markup on a 24px grid, drawn in [color].
  final String icon;
  final Color color;
  final Color background;
}

GoalLook goalLook(GoalIntent intent) => switch (intent) {
  GoalIntent.games => const GoalLook(
    '<path d="M6 9h12a4 4 0 0 1 4 4v1a3 3 0 0 1-5.4 1.8L15 14H9l-1.6 1.8A3 3 0 0 1 2 14v-1a4 4 0 0 1 4-4z"/><path d="M7 11.5v3M5.5 13h3"/>',
    AppColors.catLogic,
    AppColors.catLogicBg,
  ),
  GoalIntent.scrolling => const GoalLook(
    '<rect x="6" y="2.5" width="12" height="19" rx="2.5"/><path d="m9.5 10 2.5-2.5 2.5 2.5M9.5 14.5l2.5 2.5 2.5-2.5"/>',
    AppColors.catFitness,
    AppColors.catFitnessBg,
  ),
  GoalIntent.video => const GoalLook(
    '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="m10 9 5 3-5 3z"/>',
    AppColors.catChore,
    AppColors.catChoreBg,
  ),
  GoalIntent.homework => const GoalLook(
    '<path d="M4 4.5A1.5 1.5 0 0 1 5.5 3H19v15H5.5A1.5 1.5 0 0 0 4 19.5zM4 19.5A1.5 1.5 0 0 0 5.5 21H19"/>',
    AppColors.catLearn,
    AppColors.catLearnBg,
  ),
  GoalIntent.bedtime => const GoalLook(
    '<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"/>',
    AppColors.inkSoft,
    AppColors.fill,
  ),
  GoalIntent.school => const GoalLook(
    '<path d="M4 21V10l8-6 8 6v11M9 21v-6h6v6"/>',
    AppColors.primary,
    AppColors.primaryTint,
  ),
  GoalIntent.dinner => const GoalLook(
    '<path d="M7 3v8a3 3 0 0 0 6 0V3M10 3v18M17 3c-1.7 0-3 2.2-3 5s1.3 4 3 4v9"/>',
    AppColors.catFitness,
    AppColors.catFitnessBg,
  ),
  GoalIntent.learning => const GoalLook(
    '<path d="M12 3a6 6 0 0 0-4 10.5V17h8v-3.5A6 6 0 0 0 12 3zM9.5 20.5h5"/>',
    AppColors.catLearn,
    AppColors.catLearnBg,
  ),
  GoalIntent.custom => const GoalLook(
    '<path d="M4 20h4L19 9l-4-4L4 16z"/>',
    AppColors.inkSoft,
    AppColors.fill,
  ),
};

String goalTitle(S s, GoalIntent intent) => switch (intent) {
  GoalIntent.games => s.goalGames,
  GoalIntent.scrolling => s.goalScrolling,
  GoalIntent.video => s.goalVideo,
  GoalIntent.homework => s.goalHomework,
  GoalIntent.bedtime => s.goalBedtime,
  GoalIntent.school => s.goalSchool,
  GoalIntent.dinner => s.goalDinner,
  GoalIntent.learning => s.goalLearning,
  GoalIntent.custom => s.finiAddGoal,
};

/// The goal's icon in its rounded tile.
class GoalIcon extends StatelessWidget {
  const GoalIcon({super.key, required this.intent, this.size = 36});

  final GoalIntent intent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final look = goalLook(intent);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: look.background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
        'viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="1.8" '
        'stroke-linecap="round" stroke-linejoin="round">${look.icon}</svg>',
        width: size * 0.56,
        height: size * 0.56,
        colorFilter: ColorFilter.mode(look.color, BlendMode.srcIn),
      ),
    );
  }
}
