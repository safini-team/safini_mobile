import 'package:flutter/material.dart';
import 'package:safini/core/utils/widgets/ds/ds_toast.dart';

/// Kept as the app-wide entry point, but the presentation is now the design's
/// dark capsule toast (`flash()` in the artboards) rather than a Material
/// snack bar. Success gets the green tick; the others are text-only, because
/// the design has exactly one toast shape.
class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) =>
      DsToast.show(context, message);

  static void error(BuildContext context, String message) =>
      DsToast.show(context, message, success: false);

  static void info(BuildContext context, String message) =>
      DsToast.show(context, message, success: false);

  static void warning(BuildContext context, String message) =>
      DsToast.show(context, message, success: false);
}
