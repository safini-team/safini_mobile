class ParentMonitorModel {
  final String childName;
  final int level;
  final int timeCoins;
  final int stepsToday;
  final String? stepsChange;
  final String lessonsToday;
  final String? lessonsChange;
  final List<double> weeklyUsage;
  final List<Map<String, dynamic>> appLimits;

  const ParentMonitorModel({
    required this.childName,
    required this.level,
    required this.timeCoins,
    this.stepsToday = 0,
    this.stepsChange,
    this.lessonsToday = '—',
    this.lessonsChange,
    this.weeklyUsage = const [],
    this.appLimits = const [],
  });

  ParentMonitorModel copyWith({
    String? childName,
    int? level,
    int? timeCoins,
    int? stepsToday,
    String? stepsChange,
    String? lessonsToday,
    String? lessonsChange,
    List<double>? weeklyUsage,
    List<Map<String, dynamic>>? appLimits,
  }) {
    return ParentMonitorModel(
      childName: childName ?? this.childName,
      level: level ?? this.level,
      timeCoins: timeCoins ?? this.timeCoins,
      stepsToday: stepsToday ?? this.stepsToday,
      stepsChange: stepsChange ?? this.stepsChange,
      lessonsToday: lessonsToday ?? this.lessonsToday,
      lessonsChange: lessonsChange ?? this.lessonsChange,
      weeklyUsage: weeklyUsage ?? this.weeklyUsage,
      appLimits: appLimits ?? this.appLimits,
    );
  }
}
