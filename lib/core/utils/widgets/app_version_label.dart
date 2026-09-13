import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/constants/app_constants.dart';

/// "Safini 1.0.1 (19)" at the foot of Settings: the version name and the build
/// number the store sees, read from the installed binary. Hardcoded constants
/// used to sit here and drifted four builds behind pubspec.
class AppVersionLabel extends StatelessWidget {
  const AppVersionLabel({super.key, this.info});

  /// Injected by tests; the app reads the platform.
  final Future<PackageInfo>? info;

  static String format(PackageInfo info) =>
      '${AppConstants.appName} ${info.version} (${info.buildNumber})';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: info ?? PackageInfo.fromPlatform(),
      builder: (context, snapshot) => Text(
        snapshot.hasData ? format(snapshot.data!) : AppConstants.appName,
        textAlign: TextAlign.center,
        style: AppText.caption.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}
