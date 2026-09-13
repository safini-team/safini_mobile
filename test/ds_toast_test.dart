import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/utils/widgets/ds/ds_toast.dart';

/// The toast lives in the root overlay, above every Scaffold. It used to render
/// with Flutter's "no Material" fallback: a yellow double underline under the
/// message, on both platforms and in release builds.
void main() {
  testWidgets('toast text carries no fallback underline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => DsToast.show(context, 'Task approved'),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump(AppMotion.toast);

    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Task approved'),
    );
    final style = (paragraph.text as TextSpan).style!;
    expect(style.decoration ?? TextDecoration.none, TextDecoration.none);
    expect(style.fontFamily, isNot('monospace'));

    await tester.pump(AppMotion.toastDwell);
    expect(find.text('Task approved'), findsNothing);
  });
}
