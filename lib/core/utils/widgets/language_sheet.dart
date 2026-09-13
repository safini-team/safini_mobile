import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/app_flags.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

/// PRD v4 §9.3: Uzbek (Latin), Russian, English.
const List<({String code, String label})> appLanguages = [
  (code: 'uz', label: 'Oʻzbekcha'),
  (code: 'ru', label: 'Русский'),
  (code: 'en', label: 'English'),
];

String languageName(String code, S s) => switch (code) {
  'uz' => s.uzbek,
  'ru' => s.russian,
  _ => s.english,
};

/// The current language as it appears next to every "Language" entry point:
/// its flag, then its name.
class LanguageLabel extends StatelessWidget {
  const LanguageLabel({super.key, required this.code, required this.style});

  final String code;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFlag(code, width: 21),
        const SizedBox(width: 7),
        Text(languageName(code, S.of(context)), style: style),
      ],
    );
  }
}

/// One language picker for every screen that offers one.
Future<void> showLanguageSheet(BuildContext context) {
  final s = S.of(context);
  final cubit = context.read<LocaleCubit>();
  final current = Localizations.localeOf(context).languageCode;

  return showDsSheet<void>(
    context: context,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.selectLanguage, style: AppText.title3),
        const SizedBox(height: 18),
        DsGroup(
          color: AppColors.fillAlt,
          shadow: const [],
          radius: AppRadius.card,
          children: [
            for (final option in appLanguages)
              DsRow(
                title: option.label,
                leading: AppFlag(option.code),
                verticalPadding: 15,
                onTap: () {
                  cubit.setLocale(Locale(option.code));
                  Navigator.of(context).pop();
                },
                trailing: option.code == current
                    ? AppIcons.check(
                        size: 15,
                        color: AppColors.primary,
                        strokeWidth: 2.4,
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ],
    ),
  );
}
