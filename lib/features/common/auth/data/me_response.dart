/// Lightweight response model for `GET /v1/me`.
///
/// Only the fields needed by the auth/routing layer are extracted here.
/// The full profile payload is handled by [ProfileDto] / [ProfileModel].
class MeResponse {
  final String userId;
  final String? accountType;

  const MeResponse({
    required this.userId,
    required this.accountType,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    final userId = json['user_id'];
    if (userId is! String || userId.isEmpty) {
      throw FormatException(
        'GET /v1/me response missing or empty "user_id"',
        json,
      );
    }
    return MeResponse(
      userId: userId,
      accountType: json['account_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'account_type': accountType,
  };

  @override
  String toString() =>
      'MeResponse(userId: $userId, accountType: $accountType)';
}
