import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

/// A small bold label that heads a section inside the task sheets
/// ("Название", "Категория", "Награда", …).
class TaskSectionLabel extends StatelessWidget {
  final String text;

  const TaskSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.colorScheme.onSurface,
      ),
    );
  }
}
