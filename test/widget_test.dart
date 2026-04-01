import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/app/app.dart';
import 'package:safini/core/di/injection.dart';

void main() {
  testWidgets('Loads basic Safini app', (WidgetTester tester) async {
    configureDependencies();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('SAFINIO'), findsOneWidget);
    expect(find.text('SAFINIO'), findsOneWidget);
  });
}
