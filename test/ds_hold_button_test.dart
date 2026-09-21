import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/widgets/ds/ds_hold_button.dart';

void main() {
  testWidgets('hold progress fills the full button height from left to right', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: DsHoldButton(
                label: 'Hold to mark it done',
                holdingLabel: 'Keep holding…',
                onComplete: () => completed = true,
              ),
            ),
          ),
        ),
      ),
    );

    final button = find.byType(DsHoldButton);
    final fill = find.byKey(const ValueKey('hold-progress-fill'));
    final gesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 575));

    final buttonSize = tester.getSize(button);
    final fillSize = tester.getSize(fill);
    expect(fillSize.height, buttonSize.height);
    expect(fillSize.width, greaterThan(buttonSize.width * 0.35));
    expect(fillSize.width, lessThan(buttonSize.width * 0.65));
    expect(completed, isFalse);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getSize(fill).width, 0);
    expect(completed, isFalse);
  });
}
