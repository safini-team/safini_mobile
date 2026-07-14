import 'dart:async';

import 'package:flutter/foundation.dart';

/// Owns a one-second-ticking countdown.
///
/// Pure logic — it has no dependency on widgets or `BuildContext`, so it can be
/// unit-tested and reused by any UI. Following the Single Responsibility
/// Principle, its only job is to track "how much time is left"; rendering is
/// left to the view that listens to it.
class CountdownController extends ChangeNotifier {
  CountdownController({required Duration total}) : _total = total {
    _start();
  }

  Duration _total;
  Duration _remaining = Duration.zero;
  DateTime _endTime = DateTime.now();
  Timer? _timer;

  /// The full duration the countdown started from.
  Duration get total => _total;

  /// Time still remaining (never negative).
  Duration get remaining => _remaining;

  /// Remaining fraction: `1.0` when full, `0.0` when finished.
  double get fraction {
    final totalSeconds = _total.inSeconds;
    if (totalSeconds <= 0) return 0;
    return (_remaining.inSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// Restart the countdown with a new total (e.g. after a fresh grant).
  void reset(Duration total) {
    _total = total;
    _start();
  }

  void _start() {
    _endTime = DateTime.now().add(_total);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    final left = _endTime.difference(DateTime.now());
    _remaining = left.isNegative ? Duration.zero : left;
    if (_remaining == Duration.zero) _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
