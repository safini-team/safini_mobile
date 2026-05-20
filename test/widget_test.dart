import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/app/app.dart';
import 'package:safini/core/di/injection.dart';

void main() {
  testWidgets('Loads basic Safini app', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('SAFINI'), findsOneWidget);
  });
}
