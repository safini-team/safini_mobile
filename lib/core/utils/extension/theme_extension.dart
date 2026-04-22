import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_theme.dart';

extension ThemeExtensionX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  AppColorsExtension get customColors =>
      theme.extension<AppColorsExtension>() ??
      const AppColorsExtension(
        success: Colors.green,
        info: Colors.blue,
        warning: Colors.orange,
      );

  Color get successColor => customColors.success;
  Color get infoColor => customColors.info;
  Color get warningColor => customColors.warning;
}
