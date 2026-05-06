class ChildInviteCodeModel {
  final String childId;
  final String inviteCode;
  final DateTime inviteCodeExpiresAt;

  const ChildInviteCodeModel({
    required this.childId,
    required this.inviteCode,
    required this.inviteCodeExpiresAt,
  });

  factory ChildInviteCodeModel.fromJson(Map<String, dynamic> json) {
    return ChildInviteCodeModel(
      childId: (json['child_id'] ?? json['childId'] ?? '').toString(),
      inviteCode: (json['invite_code'] ?? json['inviteCode'] ?? '').toString(),
      inviteCodeExpiresAt:
          DateTime.tryParse(
            (json['invite_code_expires_at'] ??
                    json['inviteCodeExpiresAt'] ??
                    '')
                .toString(),
          ) ??
          DateTime.now().toUtc(),
    );
  }
}
