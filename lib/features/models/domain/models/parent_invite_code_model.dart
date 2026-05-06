class ParentInviteCodeModel {
  final String familyId;
  final String inviteCode;
  final DateTime inviteCodeExpiresAt;

  const ParentInviteCodeModel({
    required this.familyId,
    required this.inviteCode,
    required this.inviteCodeExpiresAt,
  });

  factory ParentInviteCodeModel.fromJson(Map<String, dynamic> json) {
    return ParentInviteCodeModel(
      familyId: (json['family_id'] ?? json['familyId'] ?? '').toString(),
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
