import 'package:dio/dio.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/fini/domain/fini_models.dart';

/// What the child sees of Fini (SAF-275): today's budgets, and their one ask
/// of the day for more time.
class KidFini {
  const KidFini({
    this.pools = const [],
    this.ask,
    this.canAsk = false,
    this.askMinutes = 15,
  });

  final List<KidPool> pools;
  final KidAsk? ask;
  final bool canAsk;
  final int askMinutes;

  /// The budget the card is about: the one the ask named, or the first spent.
  KidPool? get focus =>
      pools.where((pool) => pool.goalId == ask?.goalId).firstOrNull ??
      pools.where((pool) => pool.timeUp).firstOrNull;

  /// Shown only when there is something to say: a spent budget or an ask.
  bool get showCard => focus != null;

  KidFini asked(KidAsk ask) =>
      KidFini(pools: pools, ask: ask, canAsk: false, askMinutes: askMinutes);

  factory KidFini.fromJson(Map<String, dynamic> json) => KidFini(
    pools: [
      for (final pool in (json['pools'] as List?) ?? const [])
        if (pool is Map) KidPool.fromJson(pool.cast<String, dynamic>()),
    ],
    ask: json['ask'] is Map
        ? KidAsk.fromJson((json['ask'] as Map).cast<String, dynamic>())
        : null,
    canAsk: json['can_ask'] == true,
    askMinutes: (json['ask_minutes'] as num?)?.toInt() ?? 15,
  );
}

class KidPool {
  const KidPool({
    required this.goalId,
    required this.intent,
    required this.limitMinutes,
    required this.usedMinutes,
    this.planMinutes,
    this.grantedMinutes = 0,
    this.timeUp = false,
    this.apps = const [],
  });

  final String goalId;
  final GoalIntent intent;

  /// Today's budget, extra minutes included.
  final int limitMinutes;

  /// The family's plan for a day, before any extra minutes.
  final int? planMinutes;
  final int grantedMinutes;
  final int usedMinutes;
  final bool timeUp;
  final List<String> apps;

  factory KidPool.fromJson(Map<String, dynamic> json) => KidPool(
    goalId: json['goal_id'].toString(),
    intent:
        GoalIntent.values
            .where((intent) => intent.name == json['intent'])
            .firstOrNull ??
        GoalIntent.games,
    limitMinutes: (json['limit_minutes'] as num?)?.toInt() ?? 0,
    planMinutes: (json['plan_minutes'] as num?)?.toInt(),
    grantedMinutes: (json['granted_minutes'] as num?)?.toInt() ?? 0,
    usedMinutes: (json['used_minutes'] as num?)?.toInt() ?? 0,
    timeUp: json['time_up'] == true,
    apps: [
      for (final app in (json['apps'] as List?) ?? const [])
        if (app is Map) (app['app_name'] ?? app['package_name']).toString(),
    ],
  );
}

enum KidAskState { pending, granted, declined }

class KidAsk {
  const KidAsk({
    required this.id,
    required this.state,
    this.goalId,
    this.minutes = 15,
    this.parentName,
  });

  final String id;
  final String? goalId;
  final KidAskState state;
  final int minutes;

  /// Who answered; null while waiting, or when Fini gave it.
  final String? parentName;

  factory KidAsk.fromJson(Map<String, dynamic> json) => KidAsk(
    id: json['id'].toString(),
    goalId: json['goal_id']?.toString(),
    state: KidAskState.values.firstWhere(
      (state) => state.name == json['state'],
      orElse: () => KidAskState.pending,
    ),
    minutes: (json['minutes'] as num?)?.toInt() ?? 15,
    parentName: json['parent_name'] as String?,
  );
}

/// The child's side of Fini. Plain API calls; the answer comes from the
/// server's policy or a parent, never from this app.
abstract class KidFiniService {
  Future<KidFini> load(String childId);

  /// Throws when the server says no (409: already asked today).
  Future<KidAsk> ask(String childId, String goalId);
}

class KidFiniApiService implements KidFiniService {
  KidFiniApiService(this._dio);

  final Dio _dio;

  @override
  Future<KidFini> load(String childId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConst.finiKid(childId),
    );
    return KidFini.fromJson(response.data ?? const {});
  }

  @override
  Future<KidAsk> ask(String childId, String goalId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConst.finiAsk(childId),
      data: {'goal_id': goalId},
    );
    return KidAsk.fromJson(response.data ?? const {});
  }
}
