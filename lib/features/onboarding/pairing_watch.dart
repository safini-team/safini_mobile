import 'dart:async';

/// Watches for a child's phone to claim its pairing code, so the parent's
/// screen can flip from "Waiting for Amir's phone…" to connected by itself.
///
/// Polls every [every] and also on [checkNow] (the `child_connected` push),
/// stops at the first yes, and gives up after [giveUpAfter] so a parent who
/// left the screen open overnight is not polling all night.
class PairingWatch {
  PairingWatch({
    required this.isConnected,
    required this.onConnected,
    this.every = const Duration(seconds: 3),
    this.giveUpAfter = const Duration(minutes: 15),
  });

  final Future<bool> Function() isConnected;
  final void Function() onConnected;
  final Duration every;
  final Duration giveUpAfter;

  Timer? _timer;
  Timer? _deadline;
  bool _checking = false;
  bool _done = false;

  bool get isWatching => _timer != null;

  void start() {
    if (_done || _timer != null) return;
    _timer = Timer.periodic(every, (_) => checkNow());
    _deadline = Timer(giveUpAfter, stop);
  }

  Future<void> checkNow() async {
    if (_done || _checking) return;
    _checking = true;
    try {
      if (await isConnected() && !_done) {
        _done = true;
        stop();
        onConnected();
      }
    } catch (_) {
      // Offline for a moment: the next tick tries again.
    } finally {
      _checking = false;
    }
  }

  void stop() {
    _timer?.cancel();
    _deadline?.cancel();
    _timer = null;
    _deadline = null;
  }
}
