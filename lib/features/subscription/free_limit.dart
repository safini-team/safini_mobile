import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

/// The free plan's limits (SAF-158). Past one the server answers `402` and
/// names it in `X-Safini-Limit`.
enum FreeLimit {
  children,
  controlledApps,
  recurringTasks;

  static const String header = 'x-safini-limit';

  static FreeLimit? fromResponse(int? statusCode, String? limit) {
    if (statusCode != 402) return null;
    return switch (limit) {
      'children' => FreeLimit.children,
      'controlled_apps' => FreeLimit.controlledApps,
      'recurring_tasks' => FreeLimit.recurringTasks,
      _ => null,
    };
  }
}

/// The parent hit a free-plan limit. [FreeLimitAlerts] already offered Pro,
/// so screens show nothing more for it.
class FreeLimitFailure extends Failure {
  const FreeLimitFailure(this.limit, super.message);

  final FreeLimit limit;
}

/// Both HTTP clients report a `402` here; the parent's home listens and
/// offers Safini Pro, whichever screen made the request.
class FreeLimitAlerts {
  FreeLimitAlerts._();

  static final FreeLimitAlerts instance = FreeLimitAlerts._();

  final _controller = StreamController<FreeLimit>.broadcast();

  Stream<FreeLimit> get stream => _controller.stream;

  /// Returns the limit when the response is one, so callers can map it.
  FreeLimit? check(int? statusCode, String? limitHeader) {
    final limit = FreeLimit.fromResponse(statusCode, limitHeader);
    if (limit != null) _controller.add(limit);
    return limit;
  }
}

/// What the parent sees past a limit. On iPhone it leads to the paywall; the
/// Android app sells nothing (SAF-216).
Future<void> showFreeLimitSheet(
  BuildContext context,
  FreeLimit limit, {
  bool? canBuy,
}) {
  final buyHere = canBuy ?? Platform.isIOS;
  return showDsSheet<void>(
    context: context,
    builder: (sheetContext) {
      final s = S.of(sheetContext);
      final body = switch (limit) {
        FreeLimit.children => s.freeLimitChildren,
        FreeLimit.controlledApps => s.freeLimitApps,
        FreeLimit.recurringTasks => s.freeLimitTasks,
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(s.freeLimitTitle, style: AppText.title2),
          const SizedBox(height: 8),
          Text(body, style: AppText.bodyRegular),
          if (!buyHere) ...[
            const SizedBox(height: 8),
            Text(s.freeLimitAndroid, style: AppText.footnote),
          ],
          const SizedBox(height: 20),
          if (buyHere) ...[
            DsPrimaryButton(
              label: s.freeLimitSeePro,
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.router.push(const NamedRoute('paywall'));
              },
            ),
            const SizedBox(height: 10),
            DsPrimaryButton.secondary(
              label: s.cancel,
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ] else
            DsPrimaryButton(
              label: s.ok,
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
        ],
      );
    },
  );
}
