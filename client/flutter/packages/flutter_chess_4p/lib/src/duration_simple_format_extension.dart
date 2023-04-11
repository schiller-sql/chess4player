extension SimpleFormat on Duration {
  String hoursAndMinutesFormat() {
    var microseconds = inMicroseconds.remainder(Duration.microsecondsPerHour);

    final minutes = microseconds ~/ Duration.microsecondsPerMinute;
    final minutesPadding = minutes < 10 ? "0" : "";
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

    final seconds = microseconds ~/ Duration.microsecondsPerSecond;
    final secondsPadding = seconds < 10 ? "0" : "";

    return "$minutesPadding$minutes:$secondsPadding$seconds";
  }
}
