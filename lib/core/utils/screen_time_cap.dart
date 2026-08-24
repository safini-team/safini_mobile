/// The ladder the parent's screen-time stepper walks.
///
/// `daily_screen_time_minutes` is null by default and the API takes 0..1440,
/// so the rungs are: no cap, 15 m, 30 m, ... 24 h. Turning the cap off is the
/// bottom of the same ladder rather than a second control - one stepper, and
/// the parent never has to find a switch to undo what they just set.
const int screenTimeCapStep = 15;

/// `ChildUpdateRequest.daily_screen_time_minutes` is capped at 1440 server-side.
const int screenTimeCapMax = 1440;

/// Where the first press of `+` lands when a child with no apps set up gets a
/// cap: an hour is a defensible starting point, and the parent adjusts from
/// there.
const int screenTimeCapSeed = 60;

/// One rung up, or the seed when there is no cap yet.
///
/// [combinedMinutes] is the sum of the per-app limits, which is the figure the
/// panel was showing a moment ago. Seeding from it means the first press does
/// not drop a child with four hours of apps down to fifteen minutes.
int screenTimeCapUp(int? current, {int combinedMinutes = 0}) {
  if (current == null) {
    final seed = combinedMinutes > 0
        ? _roundUpToStep(combinedMinutes)
        : screenTimeCapSeed;
    return seed.clamp(screenTimeCapStep, screenTimeCapMax);
  }
  final next = (current ~/ screenTimeCapStep + 1) * screenTimeCapStep;
  return next.clamp(screenTimeCapStep, screenTimeCapMax);
}

/// One rung down, or null once the ladder runs out - which is how the cap is
/// removed.
int? screenTimeCapDown(int? current) {
  if (current == null || current <= screenTimeCapStep) return null;
  if (current % screenTimeCapStep != 0) {
    return (current ~/ screenTimeCapStep) * screenTimeCapStep;
  }
  return current - screenTimeCapStep;
}

int _roundUpToStep(int minutes) =>
    ((minutes + screenTimeCapStep - 1) ~/ screenTimeCapStep) *
    screenTimeCapStep;
