enum ParentAppLockError { wrongPin, mismatch, invalidPin, lockedOut, storage }

enum ParentAppLockNotice { enabled, disabled, changed }

class ParentAppLockState {
  const ParentAppLockState({
    this.ready = false,
    this.enabled = false,
    this.locked = true,
    this.busy = false,
    this.failedAttempts = 0,
    this.lockoutUntil,
    this.error,
    this.notice,
  });

  const ParentAppLockState.initial() : this();

  /// Storage has been read at least once.
  final bool ready;

  final bool enabled;

  /// True until a correct PIN (or a missing PIN) lets the parent shell through.
  final bool locked;

  final bool busy;
  final int failedAttempts;
  final DateTime? lockoutUntil;
  final ParentAppLockError? error;
  final ParentAppLockNotice? notice;

  /// Parent chrome stays behind this until we know there is no PIN, or the
  /// PIN has been entered.
  bool get blocksParent => !ready || (enabled && locked);

  /// A PIN is actually stored. A storage failure fail-closes to [enabled]
  /// without a PIN, so that must not count.
  bool get pinIsSet => ready && enabled && error != ParentAppLockError.storage;

  ParentAppLockState copyWith({
    bool? ready,
    bool? enabled,
    bool? locked,
    bool? busy,
    int? failedAttempts,
    DateTime? lockoutUntil,
    bool clearLockout = false,
    ParentAppLockError? error,
    bool clearError = false,
    ParentAppLockNotice? notice,
    bool clearNotice = false,
  }) {
    return ParentAppLockState(
      ready: ready ?? this.ready,
      enabled: enabled ?? this.enabled,
      locked: locked ?? this.locked,
      busy: busy ?? this.busy,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: clearLockout ? null : (lockoutUntil ?? this.lockoutUntil),
      error: clearError ? null : (error ?? this.error),
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}
