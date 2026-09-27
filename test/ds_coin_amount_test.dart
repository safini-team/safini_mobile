import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

void main() {
  testWidgets('the amount can be typed and keeps the steppers', (tester) async {
    var coins = 15;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => DsCoinAmount(
              value: coins,
              min: 5,
              max: 100000,
              onChanged: (value) => setState(() => coins = value),
              onLess: coins > 5
                  ? () => setState(() => coins = (coins - 5).clamp(5, 100000))
                  : null,
              onMore: () =>
                  setState(() => coins = (coins + 5).clamp(5, 100000)),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DsStepper), findsOneWidget);
    expect(find.byKey(const ValueKey('coin-amount')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('coin-amount')), '2000');
    await tester.pump();
    expect(coins, 2000);

    await tester.enterText(find.byKey(const ValueKey('coin-amount')), '999999');
    await tester.pump();
    expect(coins, 100000);

    await tester.enterText(find.byKey(const ValueKey('coin-amount')), '1');
    await tester.pump();
    expect(coins, 100000);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(coins, 5);
  });
}
