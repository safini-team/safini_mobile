import 'package:dio/dio.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/core/utils/request_id.dart';

/// A real-world reward a parent priced in Time Coins for one child (SAF-190).
class Prize {
  const Prize({
    required this.id,
    required this.childId,
    required this.title,
    required this.coinCost,
    this.emoji,
    this.note,
    this.templateKey,
    this.pendingRequestId,
  });

  final String id;
  final String childId;
  final String title;
  final String? emoji;
  final String? note;
  final int coinCost;
  final String? templateKey;

  /// Set while the child's ask for it waits on a parent. Its price is held.
  final String? pendingRequestId;

  bool get isWaiting => pendingRequestId != null;

  String get displayEmoji => (emoji ?? '').isEmpty ? '🎁' : emoji!;

  factory Prize.fromJson(Map<String, dynamic> json) => Prize(
    id: json['id'].toString(),
    childId: json['child_id'].toString(),
    title: (json['title'] ?? '').toString(),
    emoji: json['emoji'] as String?,
    note: json['note'] as String?,
    coinCost: (json['coin_cost'] as num?)?.toInt() ?? 0,
    templateKey: json['template_key'] as String?,
    pendingRequestId: json['pending_request_id'] as String?,
  );
}

enum PrizeRequestKind { buy, wish }

enum PrizeRequestStatus { pending, approved, declined }

/// A child's ask for a prize from the store, or a wish for one that is not in
/// it yet.
class PrizeRequest {
  const PrizeRequest({
    required this.id,
    required this.childId,
    required this.kind,
    required this.status,
    required this.title,
    required this.coinCost,
    this.emoji,
    this.prizeId,
    this.childNickname,
  });

  final String id;
  final String childId;
  final PrizeRequestKind kind;
  final PrizeRequestStatus status;
  final String title;
  final String? emoji;
  final int coinCost;
  final String? prizeId;

  /// Only on the parent's family-wide list.
  final String? childNickname;

  bool get isWish => kind == PrizeRequestKind.wish;
  bool get isPending => status == PrizeRequestStatus.pending;

  String get displayEmoji => (emoji ?? '').isEmpty ? '🎁' : emoji!;

  factory PrizeRequest.fromJson(Map<String, dynamic> json) => PrizeRequest(
    id: json['id'].toString(),
    childId: json['child_id'].toString(),
    kind: json['kind'] == 'wish' ? PrizeRequestKind.wish : PrizeRequestKind.buy,
    status: switch (json['status']) {
      'approved' => PrizeRequestStatus.approved,
      'declined' => PrizeRequestStatus.declined,
      _ => PrizeRequestStatus.pending,
    },
    title: (json['title'] ?? '').toString(),
    emoji: json['emoji'] as String?,
    coinCost: (json['coin_cost'] as num?)?.toInt() ?? 0,
    prizeId: json['prize_id'] as String?,
    childNickname: json['child_nickname'] as String?,
  );
}

/// One child's prizes and asks, as `GET /children/{id}/prizes` returns them.
class PrizeList {
  const PrizeList({
    required this.balance,
    required this.prizes,
    required this.requests,
  });

  const PrizeList.empty()
    : balance = null,
      prizes = const [],
      requests = const [];

  final int? balance;
  final List<Prize> prizes;
  final List<PrizeRequest> requests;

  List<PrizeRequest> get openWishes =>
      requests.where((r) => r.isWish && r.isPending).toList();
}

/// The result of an ask or a wish: the wallet after any hold, and the ask.
class PrizeAskResult {
  const PrizeAskResult(this.balanceAfter, this.request);

  final int? balanceAfter;
  final PrizeRequest request;
}

/// The prize routes. Errors surface as [DioException]; callers read `detail`.
class PrizeApi {
  PrizeApi(this._dio);

  final Dio _dio;

  Future<PrizeList> list(String childId) async {
    final response = await _dio.get(ApiConst.childPrizes(childId));
    final data = _map(response.data);
    return PrizeList(
      balance: (data['balance'] as num?)?.toInt(),
      prizes: _list(data['prizes']).map(Prize.fromJson).toList(),
      requests: _list(data['requests']).map(PrizeRequest.fromJson).toList(),
    );
  }

  Future<List<PrizeRequest>> familyRequests() async {
    final response = await _dio.get(ApiConst.prizeRequests);
    return _list(
      _map(response.data)['requests'],
    ).map(PrizeRequest.fromJson).toList();
  }

  Future<Prize> create(
    String childId, {
    required String title,
    required int coinCost,
    String? emoji,
    String? note,
    String? templateKey,
  }) async {
    final response = await _dio.post(
      ApiConst.childPrizes(childId),
      data: {
        'title': title,
        'coin_cost': coinCost,
        'emoji': ?emoji,
        'note': ?note,
        'template_key': ?templateKey,
      },
    );
    return Prize.fromJson(_map(response.data));
  }

  Future<Prize> update(
    String prizeId, {
    required String title,
    required int coinCost,
    String? emoji,
    String? note,
  }) async {
    final response = await _dio.patch(
      ApiConst.prize(prizeId),
      data: {
        'title': title,
        'coin_cost': coinCost,
        'emoji': emoji,
        'note': note,
      },
    );
    return Prize.fromJson(_map(response.data));
  }

  Future<void> delete(String prizeId) => _dio.delete(ApiConst.prize(prizeId));

  /// One request id per attempt, so a retried request is the same ask.
  Future<PrizeAskResult> ask(Prize prize) async {
    final response = await _dio.post(
      ApiConst.askForPrize(prize.id),
      data: {
        'client_request_id': newRequestId(),
        'expected_coin_cost': prize.coinCost,
      },
    );
    return _askResult(response.data);
  }

  Future<PrizeAskResult> wish(
    String childId, {
    required String title,
    required int coinCost,
    String? emoji,
  }) async {
    final response = await _dio.post(
      ApiConst.childWishes(childId),
      data: {
        'title': title,
        'coin_cost': coinCost,
        'emoji': ?emoji,
        'client_request_id': newRequestId(),
      },
    );
    return _askResult(response.data);
  }

  /// [coinCost] only matters for a wish: the price it goes into the store at.
  Future<void> approve(String requestId, {int? coinCost}) => _dio.post(
    ApiConst.approvePrizeRequest(requestId),
    data: {'coin_cost': ?coinCost},
  );

  Future<void> decline(String requestId) =>
      _dio.post(ApiConst.declinePrizeRequest(requestId));

  PrizeAskResult _askResult(dynamic raw) {
    final data = _map(raw);
    return PrizeAskResult(
      (data['balance_after'] as num?)?.toInt(),
      PrizeRequest.fromJson(_map(data['request'])),
    );
  }

  static Map<String, dynamic> _map(dynamic raw) => raw is Map
      ? raw.map((key, value) => MapEntry(key.toString(), value))
      : const {};

  static Iterable<Map<String, dynamic>> _list(dynamic raw) =>
      raw is List ? raw.whereType<Map>().map(_map) : const [];
}

/// The server's `detail`, when it sent one a person can read.
String? prizeErrorDetail(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  final detail = data is Map ? data['detail'] : null;
  return detail is String && detail.trim().isNotEmpty ? detail.trim() : null;
}
