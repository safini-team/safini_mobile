import 'package:dio/dio.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/fini/domain/fini_models.dart';

/// Everything the Fini tab reads and writes. The app never calls a model:
/// these are plain API calls, and Fini's decisions happen on the server.
abstract class FiniRepository {
  Future<FiniSettings> settings(String childId);
  Future<FiniSettings> saveSettings(String childId, FiniSettings settings);
  Future<List<FiniGoal>> goals(String childId);
  Future<FiniGoal> createGoal(String childId, Map<String, dynamic> body);
  Future<FiniGoal> updateGoal(String goalId, Map<String, dynamic> changes);
  Future<void> deleteGoal(String goalId);
  Future<List<FiniProposal>> pending(String childId);
  Future<List<FiniProposal>> activity(String childId);
  Future<FiniProposal> decide(String proposalId, FiniDecision decision);
  Future<FiniInbox> inbox();
  Future<FiniTrial> trial();

  /// Starts the family's trial; a second call returns it unchanged.
  Future<FiniTrial> startTrial();

  /// Skips the rest of a budget goal's plan: the pool goes to the goal now.
  Future<FiniGoal> jumpToTarget(String goalId);

  /// The child's budget goals as shared pools, with today's minutes.
  Future<List<FiniPool>> pools(String childId);

  /// The parent's answer for one new app: [category] ("other" is "not a
  /// game") and/or its own [minutes] a day. Answers a waiting card for it.
  Future<FiniProposal> placeApp(
    String childId,
    String packageName, {
    String? category,
    int? minutes,
  });

  /// Fini's Sunday reports, newest first (SAF-278).
  Future<List<FiniReport>> reports(String childId);
}

enum FiniDecision { accept, dismiss, undo }

class FiniApiRepository implements FiniRepository {
  FiniApiRepository(this._dio);

  final Dio _dio;

  @override
  Future<FiniSettings> settings(String childId) async => FiniSettings.fromJson(
    _map((await _dio.get(ApiConst.finiSettings(childId))).data),
  );

  @override
  Future<FiniSettings> saveSettings(
    String childId,
    FiniSettings settings,
  ) async => FiniSettings.fromJson(
    _map(
      (await _dio.put(
        ApiConst.finiSettings(childId),
        data: settings.toJson(),
      )).data,
    ),
  );

  @override
  Future<List<FiniGoal>> goals(String childId) async => _list(
    _map((await _dio.get(ApiConst.finiGoals(childId))).data)['goals'],
  ).map(FiniGoal.fromJson).toList();

  @override
  Future<FiniGoal> createGoal(
    String childId,
    Map<String, dynamic> body,
  ) async => FiniGoal.fromJson(
    _map((await _dio.post(ApiConst.finiGoals(childId), data: body)).data),
  );

  @override
  Future<FiniGoal> updateGoal(
    String goalId,
    Map<String, dynamic> changes,
  ) async => FiniGoal.fromJson(
    _map((await _dio.patch(ApiConst.finiGoal(goalId), data: changes)).data),
  );

  @override
  Future<void> deleteGoal(String goalId) =>
      _dio.delete(ApiConst.finiGoal(goalId));

  @override
  Future<List<FiniProposal>> pending(String childId) async => _list(
    _map((await _dio.get(ApiConst.finiProposals(childId))).data)['items'],
  ).map(FiniProposal.fromJson).toList();

  @override
  Future<List<FiniProposal>> activity(String childId) async => _list(
    _map((await _dio.get(ApiConst.finiActivity(childId))).data)['items'],
  ).map(FiniProposal.fromJson).toList();

  @override
  Future<FiniProposal> decide(String proposalId, FiniDecision decision) async =>
      FiniProposal.fromJson(
        _map(
          (await _dio.post(
            ApiConst.finiDecision(proposalId, decision.name),
          )).data,
        ),
      );

  @override
  Future<FiniInbox> inbox() async =>
      FiniInbox.fromJson(_map((await _dio.get(ApiConst.finiInbox)).data));

  @override
  Future<FiniTrial> trial() async =>
      FiniTrial.fromJson(_map((await _dio.get(ApiConst.finiTrial)).data));

  @override
  Future<FiniTrial> startTrial() async =>
      FiniTrial.fromJson(_map((await _dio.post(ApiConst.finiTrialStart)).data));

  @override
  Future<FiniGoal> jumpToTarget(String goalId) async => FiniGoal.fromJson(
    _map((await _dio.post(ApiConst.finiGoalJump(goalId))).data),
  );

  @override
  Future<List<FiniPool>> pools(String childId) async => _list(
    _map((await _dio.get(ApiConst.finiPools(childId))).data)['pools'],
  ).map(FiniPool.fromJson).toList();

  @override
  Future<FiniProposal> placeApp(
    String childId,
    String packageName, {
    String? category,
    int? minutes,
  }) async => FiniProposal.fromJson(
    _map(
      (await _dio.put(
        ApiConst.finiApp(childId, packageName),
        data: {'category': ?category, 'minutes': ?minutes},
      )).data,
    ),
  );

  @override
  Future<List<FiniReport>> reports(String childId) async => _list(
    _map((await _dio.get(ApiConst.finiReports(childId))).data)['reports'],
  ).map(FiniReport.fromJson).toList();

  static Map<String, dynamic> _map(Object? data) =>
      data is Map ? data.cast<String, dynamic>() : const {};

  static List<Map<String, dynamic>> _list(Object? data) => data is List
      ? [
          for (final item in data)
            if (item is Map) item.cast<String, dynamic>(),
        ]
      : const [];
}
