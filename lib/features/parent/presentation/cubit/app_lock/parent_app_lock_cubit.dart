import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/features/parent/data/datasources/local/parent_app_lock_store.dart';
import 'package:safini/features/parent/domain/parent_pin_hasher.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_state.dart';

/// Parent-only app lock. PIN hash lives on this device; nothing is sent to
/// the API.
///
/// Resume timing: [lockOnBackground] runs on [AppLifecycleState.paused] and
/// [AppLifecycleState.hidden], not [AppLifecycleState.inactive], so a system
/// dialog or the biometric sheet does not immediately lock. Coming back from
/// a real background is then already locked before the first resumed frame.
class ParentAppLockCubit extends Cubit<ParentAppLockState> {
  ParentAppLockCubit({
    required ParentAppLockStore store,
    required ParentPinHasher hasher,
    SharedPreferences? prefs,
    DateTime Function()? now,
    this.maxFails = 5,
    this.lockoutDuration = const Duration(seconds: 20),
  }) : _store = store,
       _hasher = hasher,
       _prefs = prefs,
       _now = now ?? DateTime.now,
       super(const ParentAppLockState.initial());

  static const installedFlag = 'parent_app_lock_installed_v1';

  final ParentAppLockStore _store;
  final ParentPinHasher _hasher;
  final SharedPreferences? _prefs;
  final DateTime Function() _now;
  final int maxFails;
  final Duration lockoutDuration;

  Future<void> load() async {
    try {
      await _wipeKeychainIfReinstalled();
      final record = await _store.read();
      final enabled = record != null;
      // Host remounts when MaterialApp rebuilds (locale). That is not a
      // cold start: keep an already-unlocked session open.
      final stayUnlocked = state.ready && !state.locked;
      _safeEmit(
        ParentAppLockState(
          ready: true,
          enabled: enabled,
          locked: enabled && !stayUnlocked,
        ),
      );
    } catch (e) {
      debugPrint('Parent app lock load failed: $e');
      _safeEmit(
        const ParentAppLockState(
          ready: true,
          enabled: true,
          locked: true,
          error: ParentAppLockError.storage,
        ),
      );
    }
  }

  /// iOS Keychain can outlive an uninstall. Shared preferences do not, so a
  /// missing flag means a fresh install: drop any leftover hash.
  Future<void> _wipeKeychainIfReinstalled() async {
    final prefs = _prefs;
    if (prefs == null) return;
    if (prefs.getBool(installedFlag) == true) return;
    await _store.clear();
    await prefs.setBool(installedFlag, true);
  }

  void lockOnBackground() {
    if (!state.ready || !state.enabled) return;
    _safeEmit(
      state.copyWith(locked: true, clearError: true, clearNotice: true),
    );
  }

  Future<bool> unlock(String pin) async {
    if (!_prepareAttempt()) return false;
    if (!_hasher.isValid(pin)) {
      _safeEmit(
        state.copyWith(busy: false, error: ParentAppLockError.invalidPin),
      );
      return false;
    }

    _safeEmit(state.copyWith(busy: true, clearError: true));
    try {
      final record = await _store.read();
      if (record == null) {
        _safeEmit(
          state.copyWith(
            ready: true,
            enabled: false,
            locked: false,
            busy: false,
            failedAttempts: 0,
            clearLockout: true,
            clearError: true,
          ),
        );
        return true;
      }
      if (!_hasher.matches(pin, record)) {
        _registerFailure();
        return false;
      }
      _safeEmit(
        state.copyWith(
          locked: false,
          busy: false,
          failedAttempts: 0,
          clearLockout: true,
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Parent app lock unlock failed: $e');
      _safeEmit(state.copyWith(busy: false, error: ParentAppLockError.storage));
      return false;
    }
  }

  /// Confirms the current PIN without unlocking (settings change / disable).
  Future<bool> verifyPin(String pin) async {
    if (!_prepareAttempt()) return false;
    if (!_hasher.isValid(pin)) {
      _safeEmit(state.copyWith(error: ParentAppLockError.invalidPin));
      return false;
    }
    _safeEmit(state.copyWith(busy: true, clearError: true));
    try {
      final record = await _store.read();
      if (record == null || !_hasher.matches(pin, record)) {
        _registerFailure();
        return false;
      }
      _safeEmit(
        state.copyWith(
          busy: false,
          failedAttempts: 0,
          clearLockout: true,
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Parent app lock verify failed: $e');
      _safeEmit(state.copyWith(busy: false, error: ParentAppLockError.storage));
      return false;
    }
  }

  Future<bool> enable(String pin, String confirm) async {
    if (state.enabled) return false;
    if (!_hasher.isValid(pin) || !_hasher.isValid(confirm)) {
      _safeEmit(state.copyWith(error: ParentAppLockError.invalidPin));
      return false;
    }
    if (pin != confirm) {
      _safeEmit(state.copyWith(error: ParentAppLockError.mismatch));
      return false;
    }
    _safeEmit(state.copyWith(busy: true, clearError: true, clearNotice: true));
    try {
      await _store.write(_hasher.hash(pin));
      _safeEmit(
        state.copyWith(
          ready: true,
          enabled: true,
          locked: false,
          busy: false,
          failedAttempts: 0,
          clearLockout: true,
          clearError: true,
          notice: ParentAppLockNotice.enabled,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Parent app lock enable failed: $e');
      _safeEmit(state.copyWith(busy: false, error: ParentAppLockError.storage));
      return false;
    }
  }

  Future<bool> change(String current, String next, String confirm) async {
    if (!state.enabled) return false;
    if (!_hasher.isValid(current) ||
        !_hasher.isValid(next) ||
        !_hasher.isValid(confirm)) {
      _safeEmit(state.copyWith(error: ParentAppLockError.invalidPin));
      return false;
    }
    if (next != confirm) {
      _safeEmit(state.copyWith(error: ParentAppLockError.mismatch));
      return false;
    }
    _safeEmit(state.copyWith(busy: true, clearError: true, clearNotice: true));
    try {
      final record = await _store.read();
      if (record == null || !_hasher.matches(current, record)) {
        _registerFailure();
        return false;
      }
      await _store.write(_hasher.hash(next));
      _safeEmit(
        state.copyWith(
          busy: false,
          failedAttempts: 0,
          clearLockout: true,
          clearError: true,
          notice: ParentAppLockNotice.changed,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Parent app lock change failed: $e');
      _safeEmit(state.copyWith(busy: false, error: ParentAppLockError.storage));
      return false;
    }
  }

  Future<bool> disable(String pin) async {
    if (!state.enabled) return false;
    if (!_hasher.isValid(pin)) {
      _safeEmit(state.copyWith(error: ParentAppLockError.invalidPin));
      return false;
    }
    _safeEmit(state.copyWith(busy: true, clearError: true, clearNotice: true));
    try {
      final record = await _store.read();
      if (record == null || !_hasher.matches(pin, record)) {
        _registerFailure();
        return false;
      }
      await _store.clear();
      _safeEmit(
        state.copyWith(
          enabled: false,
          locked: false,
          busy: false,
          failedAttempts: 0,
          clearLockout: true,
          clearError: true,
          notice: ParentAppLockNotice.disabled,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Parent app lock disable failed: $e');
      _safeEmit(state.copyWith(busy: false, error: ParentAppLockError.storage));
      return false;
    }
  }

  /// Drops the local hash. Keeps [ParentAppLockState.locked] so the overlay
  /// does not flash parent tabs while sign-out is still in flight.
  Future<void> wipeForSignOut() async {
    try {
      await _store.clear();
    } catch (e) {
      debugPrint('Parent app lock wipe failed: $e');
      rethrow;
    }
    _safeEmit(
      state.copyWith(
        ready: true,
        enabled: false,
        busy: false,
        failedAttempts: 0,
        clearLockout: true,
        clearError: true,
        clearNotice: true,
      ),
    );
  }

  void onUnauthenticated() {
    _safeEmit(const ParentAppLockState(ready: true, locked: false));
  }

  void ackNotice() {
    _safeEmit(state.copyWith(clearNotice: true));
  }

  void clearError() {
    _safeEmit(state.copyWith(clearError: true));
  }

  bool _prepareAttempt() {
    if (state.busy) return false;
    final until = state.lockoutUntil;
    if (until == null) return true;
    if (_now().isBefore(until)) {
      _safeEmit(state.copyWith(error: ParentAppLockError.lockedOut));
      return false;
    }
    _safeEmit(
      state.copyWith(failedAttempts: 0, clearLockout: true, clearError: true),
    );
    return true;
  }

  void _registerFailure() {
    final fails = state.failedAttempts + 1;
    final lockedOut = fails >= maxFails;
    _safeEmit(
      state.copyWith(
        busy: false,
        failedAttempts: lockedOut ? 0 : fails,
        lockoutUntil: lockedOut ? _now().add(lockoutDuration) : null,
        clearLockout: !lockedOut,
        error: lockedOut
            ? ParentAppLockError.lockedOut
            : ParentAppLockError.wrongPin,
      ),
    );
  }

  void _safeEmit(ParentAppLockState next) {
    if (isClosed) return;
    emit(next);
  }
}
