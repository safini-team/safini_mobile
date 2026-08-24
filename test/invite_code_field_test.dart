import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
