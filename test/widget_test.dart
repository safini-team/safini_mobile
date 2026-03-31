import 'package:flutter_test/flutter_test.dart';
import 'package:safini/screens/common/core/app/app.dart';
import 'package:safini/screens/common/core/di/injection.dart';

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
