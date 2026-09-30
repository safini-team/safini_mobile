import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/features/common/auth/data/auth_apple_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_email_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/parent/data/datasources/local/parent_app_lock_store.dart';
import 'package:safini/features/parent/domain/parent_pin_hasher.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_state.dart';

void main() {
  group('ParentPinHasher', () {
    const hasher = ParentPinHasher();

    test('accepts only four digits', () {
      expect(hasher.isValid('1234'), isTrue);
      expect(hasher.isValid('0000'), isTrue);
      expect(hasher.isValid('123'), isFalse);
      expect(hasher.isValid('12345'), isFalse);
      expect(hasher.isValid('12a4'), isFalse);
    });

    test('same PIN and salt produce the same hash, never the PIN', () {
      const salt = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final first = hasher.hash('4242', salt: salt);
      final second = hasher.hash('4242', salt: salt);
      expect(first.hashHex, second.hashHex);
      expect(first.saltHex, isNot(contains('4242')));
      expect(first.hashHex, isNot(contains('4242')));
      expect(first.toJson().values, isNot(contains('4242')));
    });

    test('wrong PIN does not match', () {
      final record = hasher.hash('4242', salt: List.filled(16, 7));
      expect(hasher.matches('4242', record), isTrue);
      expect(hasher.matches('4243', record), isFalse);
    });

    test('different salts hash differently', () {
      final hasherA = ParentPinHasher(random: Random(1));
      final hasherB = ParentPinHasher(random: Random(2));
      expect(hasherA.hash('1111').hashHex, isNot(hasherB.hash('1111').hashHex));
    });
  });

  group('ParentAppLockCubit', () {
    late MemoryParentAppLockStore store;
    late ParentAppLockCubit cubit;
    late DateTime now;

    setUp(() {
      store = MemoryParentAppLockStore();
      now = DateTime.utc(2026, 9, 27, 12);
      cubit = ParentAppLockCubit(
        store: store,
        hasher: const ParentPinHasher(),
        now: () => now,
        maxFails: 3,
        lockoutDuration: const Duration(seconds: 20),
      );
    });

    tearDown(() => cubit.close());

    test('cold start with a PIN starts locked', () async {
      await store.write(const ParentPinHasher().hash('2580'));
      await cubit.load();
      expect(cubit.state.ready, isTrue);
      expect(cubit.state.enabled, isTrue);
      expect(cubit.state.locked, isTrue);
      expect(cubit.state.blocksParent, isTrue);
      expect(cubit.state.toString(), isNot(contains('2580')));
    });

    test('cold start without a PIN does not block', () async {
      await cubit.load();
      expect(cubit.state.enabled, isFalse);
      expect(cubit.state.locked, isFalse);
      expect(cubit.state.blocksParent, isFalse);
    });

    test(
      'a later load does not lock a session that already unlocked',
      () async {
        await store.write(const ParentPinHasher().hash('2580'));
        await cubit.load();
        expect(await cubit.unlock('2580'), isTrue);
        await cubit.load();
        expect(cubit.state.locked, isFalse);
        expect(cubit.state.enabled, isTrue);
      },
    );

    test('unlocks with the right PIN and rejects the wrong one', () async {
      await cubit.load();
      await cubit.enable('2580', '2580');
      cubit.lockOnBackground();
      expect(cubit.state.locked, isTrue);

      expect(await cubit.unlock('1111'), isFalse);
      expect(cubit.state.error, ParentAppLockError.wrongPin);
      expect(cubit.state.locked, isTrue);

      expect(await cubit.unlock('2580'), isTrue);
      expect(cubit.state.locked, isFalse);
      expect(cubit.state.error, isNull);
    });

    test('rate-limits after repeated failures', () async {
      await cubit.load();
      await cubit.enable('2580', '2580');
      cubit.lockOnBackground();

      expect(await cubit.unlock('0000'), isFalse);
      expect(await cubit.unlock('0001'), isFalse);
      expect(await cubit.unlock('0002'), isFalse);
      expect(cubit.state.error, ParentAppLockError.lockedOut);

      expect(await cubit.unlock('2580'), isFalse);
      expect(cubit.state.locked, isTrue);

      now = now.add(const Duration(seconds: 21));
      expect(await cubit.unlock('2580'), isTrue);
      expect(cubit.state.locked, isFalse);
    });

    test('enable requires matching confirmation', () async {
      await cubit.load();
      expect(await cubit.enable('1111', '2222'), isFalse);
      expect(cubit.state.error, ParentAppLockError.mismatch);
      expect(cubit.state.enabled, isFalse);
      expect(await store.read(), isNull);

      expect(await cubit.enable('1111', '1111'), isTrue);
      expect(cubit.state.enabled, isTrue);
      expect(cubit.state.locked, isFalse);
      expect(await store.read(), isNotNull);
    });

    test('change and disable require the current PIN', () async {
      await cubit.load();
      await cubit.enable('1111', '1111');

      expect(await cubit.change('0000', '2222', '2222'), isFalse);
      expect(cubit.state.error, ParentAppLockError.wrongPin);

      expect(await cubit.change('1111', '2222', '3333'), isFalse);
      expect(cubit.state.error, ParentAppLockError.mismatch);

      expect(await cubit.change('1111', '2222', '2222'), isTrue);
      cubit.lockOnBackground();
      expect(await cubit.unlock('1111'), isFalse);
      expect(await cubit.unlock('2222'), isTrue);

      expect(await cubit.disable('1111'), isFalse);
      expect(await cubit.disable('2222'), isTrue);
      expect(cubit.state.enabled, isFalse);
      expect(await store.read(), isNull);
    });

    test('reinstall flag wipes a leftover hash', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await store.write(const ParentPinHasher().hash('9999'));
      final fresh = ParentAppLockCubit(
        store: store,
        hasher: const ParentPinHasher(),
        prefs: prefs,
      );
      addTearDown(fresh.close);
      await fresh.load();
      expect(fresh.state.enabled, isFalse);
      expect(await store.read(), isNull);
      expect(prefs.getBool(ParentAppLockCubit.installedFlag), isTrue);
    });

    test('sign-out wipe keeps the overlay until unauthenticated', () async {
      await cubit.load();
      await cubit.enable('2580', '2580');
      cubit.lockOnBackground();
      await cubit.wipeForSignOut();
      expect(await store.read(), isNull);
      expect(cubit.state.enabled, isFalse);
      expect(cubit.state.locked, isTrue);
      cubit.onUnauthenticated();
      expect(cubit.state.locked, isFalse);
      expect(cubit.state.blocksParent, isFalse);
    });

    test('failed PIN wipe keeps recovery available for retry', () async {
      final failingStore = _FailingClearStore();
      await failingStore.write(const ParentPinHasher().hash('2580'));
      final failingLock = ParentAppLockCubit(
        store: failingStore,
        hasher: const ParentPinHasher(),
      );
      addTearDown(failingLock.close);
      await failingLock.load();
      await expectLater(
        failingLock.wipeForSignOut(),
        throwsA(isA<StateError>()),
      );
      expect(failingLock.state.blocksParent, isTrue);
      expect(await failingStore.read(), isNotNull);
    });
  });

  group('AuthSessionCubit sign-out', () {
    test('clears the local PIN hash', () async {
      SharedPreferences.setMockInitialValues({});
      final store = MemoryParentAppLockStore();
      await store.write(const ParentPinHasher().hash('2580'));
      final lock = ParentAppLockCubit(
        store: store,
        hasher: const ParentPinHasher(),
      );
      await lock.load();
      getIt.registerSingleton<ParentAppLockCubit>(lock);
      addTearDown(() async {
        await lock.close();
        await getIt.reset();
      });

      final cubit = AuthSessionCubit(
        _FakeGoogleAuth(),
        AuthAppleSignInService(),
        AuthEmailSignInService(),
        UserMeService(AuthenticatedHttpClient(_FakeTokens())),
        _FakeTokens(),
      );
      addTearDown(cubit.close);

      await cubit.signOut();
      expect(await store.read(), isNull);
      expect(lock.state.enabled, isFalse);
      expect(cubit.state.status, AuthSessionStatus.unauthenticated);
    });
  });
}

class _FakeGoogleAuth extends AuthGoogleSignInService {
  @override
  Future<void> signOut() async {}
}

class _FailingClearStore extends MemoryParentAppLockStore {
  @override
  Future<void> clear() async => throw StateError('Keychain unavailable');
}

class _FakeTokens implements AuthTokenProvider {
  @override
  bool hasSession = false;

  @override
  String? currentAccessToken;

  @override
  Future<String?> getAccessToken() async => currentAccessToken;

  @override
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken) async =>
      currentAccessToken;
}
