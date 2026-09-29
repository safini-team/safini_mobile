import 'package:dio/dio.dart';
import 'package:safini/core/utils/child_avatar_look.dart';
import 'package:safini/core/utils/constants/api_const.dart';

/// Why adding a friend did not work. The app translates these; the API sends
/// the same codes.
enum FriendsError { notFound, alreadyFriends, ownId, invalid, unavailable }

/// One child on the friends list. Wallet balances are not a field on purpose:
/// a friend card is progress, not a ranking or a coin count.
class FriendSummary {
  const FriendSummary({
    required this.childId,
    required this.publicId,
    required this.nickname,
    required this.level,
    required this.faceEmoji,
    required this.tasksDoneToday,
    required this.tasksTotalToday,
    required this.prizesClaimedCount,
    this.accessoryEmoji,
  });

  final String childId;
  final String publicId;
  final String nickname;
  final int level;
  final String faceEmoji;
  final String? accessoryEmoji;
  final int tasksDoneToday;
  final int tasksTotalToday;
  final int prizesClaimedCount;

  /// A star only when the day actually had tasks and every one is approved.
  /// An empty day is not "all done".
  bool get allTasksDoneToday =>
      tasksTotalToday > 0 && tasksDoneToday == tasksTotalToday;

  factory FriendSummary.fromJson(Map<String, dynamic> json) {
    final look = ChildAvatarLook.fromAvatarState(json['avatar_state']);
    return FriendSummary(
      childId: json['child_id'].toString(),
      publicId: (json['public_id'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      level: (json['level'] as num?)?.toInt() ?? 1,
      faceEmoji: look.faceEmoji,
      accessoryEmoji: look.accessoryEmoji,
      tasksDoneToday: (json['tasks_done_today'] as num?)?.toInt() ?? 0,
      tasksTotalToday: (json['tasks_total_today'] as num?)?.toInt() ?? 0,
      prizesClaimedCount: (json['prizes_claimed_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class FriendsPage {
  const FriendsPage({required this.publicId, required this.friends});

  final String publicId;
  final List<FriendSummary> friends;

  factory FriendsPage.fromJson(Map<String, dynamic> json) {
    final list = json['friends'];
    return FriendsPage(
      publicId: (json['public_id'] ?? '').toString(),
      friends: list is List
          ? list
                .whereType<Map>()
                .map(
                  (row) => FriendSummary.fromJson(row.cast<String, dynamic>()),
                )
                .toList()
          : const [],
    );
  }
}

/// Level order is optional and has no place numbers. Ties keep a stable name
/// order so the list does not jump.
List<FriendSummary> orderedFriends(
  List<FriendSummary> friends, {
  required bool byLevel,
}) {
  if (!byLevel) return friends;
  final copy = [...friends];
  copy.sort((a, b) {
    final byLevelOrder = b.level.compareTo(a.level);
    if (byLevelOrder != 0) return byLevelOrder;
    return a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase());
  });
  return copy;
}

class FriendsApi {
  FriendsApi(this._dio);

  final Dio _dio;

  Future<FriendsPage> list(String childId) async {
    final response = await _dio.get(ApiConst.childFriends(childId));
    return FriendsPage.fromJson(_map(response.data));
  }

  Future<FriendSummary> add(String childId, String publicId) async {
    try {
      final response = await _dio.post(
        ApiConst.childFriends(childId),
        data: {'public_id': publicId},
      );
      return FriendSummary.fromJson(_map(response.data));
    } on DioException catch (error) {
      throw FriendsException(_errorOf(error));
    }
  }

  Future<void> remove(String childId, String friendChildId) async {
    try {
      await _dio.delete(ApiConst.childFriend(childId, friendChildId));
    } on DioException catch (error) {
      throw FriendsException(_errorOf(error));
    }
  }

  static FriendsError _errorOf(DioException error) {
    final status = error.response?.statusCode;
    final detail = error.response?.data is Map
        ? (error.response!.data as Map)['detail']?.toString()
        : null;
    if (status == 404) return FriendsError.notFound;
    if (status == 409) return FriendsError.alreadyFriends;
    if (detail == 'own_id') return FriendsError.ownId;
    if (status == 400 || status == 422) return FriendsError.invalid;
    return FriendsError.unavailable;
  }

  static Map<String, dynamic> _map(Object? data) =>
      data is Map ? data.cast<String, dynamic>() : const {};
}

class FriendsException implements Exception {
  FriendsException(this.code);

  final FriendsError code;
}
