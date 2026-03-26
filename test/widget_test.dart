import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/main.dart';

void main() {
  testWidgets('Loads Safini splash screen', (WidgetTester tester) async {
    configureDependencies();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('SAFINIO'), findsOneWidget);
    expect(find.text("I'm a Kid!"), findsOneWidget);
    expect(find.text("I'm a Parent"), findsOneWidget);
  });
}
