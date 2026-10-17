// a game night usually takes about three hours
const gameLength = Duration(hours: 3);

sealed class Countdown {
  const Countdown();

  factory Countdown.of(DateTime start, DateTime now) {
    if (now.isBefore(start)) return Upcoming(start.difference(now));
    final passed = now.difference(start);
    if (passed < gameLength) return Started(passed);
    return const Ended();
  }
}

class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

class Started extends Countdown {
  const Started(this.ago);
  final Duration ago;
}

class Ended extends Countdown {
  const Ended();
}
