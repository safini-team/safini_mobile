import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/push_deep_links.dart';

void main() {
  late PushDeepLinks links;

  setUp(() {
    links = PushDeepLinks();
    if (getIt.isRegistered<PushDeepLinks>()) getIt.unregister<PushDeepLinks>();
    getIt.registerSingleton<PushDeepLinks>(links);
  });

  tearDown(() => GetIt.I.reset());

  test('a protection alert parks the child and enters through the splash', () {
    final route = AppRouter.protectionRouteFor(
      Uri.parse('safini://children/child-7/protection'),
    );
    expect(route, '/');
    expect(links.takeChildId(), 'child-7');
  });

  test('other links are left for their own handlers', () {
    for (final other in [
      // Supabase and Google Sign-In both come back through custom schemes.
      'com.googleusercontent.apps.82130591868-abc:/oauth2redirect',
      'safini://children/child-7',
      'safini://settings',
      'https://safini.fun/inv',
    ]) {
      expect(
        AppRouter.protectionRouteFor(Uri.parse(other)),
        isNull,
        reason: '$other must not be swallowed by the alert route',
      );
      expect(links.hasPending, isFalse);
    }
  });
}
