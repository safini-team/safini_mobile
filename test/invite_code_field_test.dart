import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/utils/widgets/ds/ds_code_field.dart';

void main() {
  testWidgets('invite code field completes at four characters', (tester) async {
    final controller = TextEditingController();
    String? completedCode;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DsCodeField(
            controller: controller,
            autofocus: false,
            onCompleted: (value) => completedCode = value,
          ),
        ),
      ),
    );

    final field = tester.widget<DsCodeField>(find.byType(DsCodeField));
    expect(field.length, 4);

    controller.text = 'SAFE';
    await tester.pump();

    expect(completedCode, 'SAFE');
  });

  testWidgets('every empty code box keeps a green outline', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DsCodeField(controller: controller, autofocus: false),
        ),
      ),
    );

    final box = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final decoration = box.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    expect(border.top.color, AppColors.primary);
    expect(border.top.width, 1.25);
  });
}
