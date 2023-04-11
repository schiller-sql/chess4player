import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SecondsCountdownTimer {
  late int _secondsToGo;
  late Timer? _delayTimer;
  Timer? _periodicTimer;
  final ValueChanged<Duration> _durationChanged;

  SecondsCountdownTimer({
    required Duration duration,
    required void Function(Duration) durationChanged,
  }) : _durationChanged = durationChanged {
    final microsecondsTillNextSecond =
        duration.inMicroseconds % Duration.microsecondsPerSecond;
    _secondsToGo = duration.inSeconds;
    if (microsecondsTillNextSecond == 0) {
      _onDelayFinished();
    } else {
      final durationTillNextSecond = Duration(
        microseconds: microsecondsTillNextSecond,
      );
      _delayTimer = Timer(durationTillNextSecond, _onDelayFinished);
    }
  }

  void _onDelayFinished() {
    _durationChanged(Duration(seconds: _secondsToGo));
    _delayTimer = null;
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onSecondPeriod(),
    );
  }

  void _onSecondPeriod() {
    _secondsToGo--;
    _durationChanged(Duration(seconds: _secondsToGo));
    if (_secondsToGo == 0) {
      _periodicTimer?.cancel();
      _periodicTimer = null;
    }
  }

  void cancel() {
    _delayTimer?.cancel();
    _periodicTimer?.cancel();
  }
}
