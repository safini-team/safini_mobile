class FamilyModel {
  final String id;
  final String ownerUserId;
  final String name;
  final String timezone;
  final List<ParentSummaryModel> parents;
  final List<ChildSummaryModel> children;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyModel({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.timezone,
    required this.parents,
    required this.children,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    final childrenJson = (json['children'] ?? json['kids'] ?? json['members']);
    final parentsJson = json['parents'];
    final ownerUserId =
        (json['ownerUserId'] ?? json['owner_user_id'] ?? json['owner_id'])
            as String? ??
        '';
    return FamilyModel(
      id:
          (json['id'] ?? json['family_id'] ?? json['familyId']) as String? ??
          '',
      ownerUserId: ownerUserId,
      name: (json['name'] ?? json['family_name'] ?? 'Family') as String,
      timezone: (json['timezone'] ?? 'UTC') as String,
      parents: parentsJson is List
          ? parentsJson
                .whereType<Map<String, dynamic>>()
                .map(ParentSummaryModel.fromJson)
                .toList()
          : (ownerUserId.isEmpty
                ? const <ParentSummaryModel>[]
                : <ParentSummaryModel>[
                    ParentSummaryModel(
                      userId: ownerUserId,
                      email: null,
                      displayName: 'NoName',
                      avatarUrl: null,
                      role: 'admin',
                      joinedAt: null,
                    ),
                  ]),
      children: childrenJson is List
          ? childrenJson
                .whereType<Map<String, dynamic>>()
                .map(ChildSummaryModel.fromJson)
                .toList()
          : const <ChildSummaryModel>[],
      createdAt:
          DateTime.tryParse(
            (json['createdAt'] ?? json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(
            (json['updatedAt'] ?? json['updated_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'name': name,
      'timezone': timezone,
      'parents': parents.map((e) => e.toJson()).toList(),
      'children': children.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ParentSummaryModel {
  final String userId;
  final String? email;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final DateTime? joinedAt;

  const ParentSummaryModel({
    required this.userId,
    this.email,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    this.joinedAt,
  });

  factory ParentSummaryModel.fromJson(Map<String, dynamic> json) {
    return ParentSummaryModel(
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      email: json['email'] as String?,
      displayName:
          (json['display_name'] ?? json['displayName'])
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true
          ? (json['display_name'] ?? json['displayName']).toString().trim()
          : 'NoName',
      avatarUrl:
          (json['avatar_url'] ?? json['avatarUrl'] ?? json['picture'])
              as String?,
      role: (json['role'] ?? 'parent').toString(),
      joinedAt: DateTime.tryParse(
        (json['joined_at'] ?? json['joinedAt'] ?? '').toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'role': role,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }
}

class ChildSummaryModel {
  final String id;
  final String nickname;
  final int age;
  final String? gender;
  final String? claimedByUserId;
  final int coinsBalance;
  final int level;

  /// `current_streak_days` from the child row. Every endpoint that serialises a
  /// child returns it, including `GET /v1/families/current`.
  final int currentStreakDays;

  const ChildSummaryModel({
    required this.id,
    required this.nickname,
    required this.age,
    this.gender,
    this.claimedByUserId,
    required this.coinsBalance,
    required this.level,
    this.currentStreakDays = 0,
  });

  factory ChildSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawAge = json['age'];
    final rawCoins = json['coinsBalance'] ?? json['coins_balance'];
    final rawLevel = json['level'] ?? json['rank'];
    return ChildSummaryModel(
      id: (json['id'] ?? json['child_id']) as String? ?? '',
      nickname:
          (json['nickname'] ?? json['name'] ?? json['display_name'])
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true
          ? (json['nickname'] ?? json['name'] ?? json['display_name'])
                .toString()
                .trim()
          : 'NoName',
      age: rawAge is int ? rawAge : int.tryParse(rawAge?.toString() ?? '') ?? 0,
      gender: (json['gender'] as String?)?.trim(),
      claimedByUserId:
          (json['claimed_by_user_id'] ?? json['claimedByUserId']) as String?,
      coinsBalance: rawCoins is int
          ? rawCoins
          : int.tryParse(rawCoins?.toString() ?? '') ?? 0,
      level: rawLevel is int
          ? rawLevel
          : int.tryParse(rawLevel?.toString() ?? '') ?? 0,
      currentStreakDays: switch (json['currentStreakDays'] ??
          json['current_streak_days']) {
        final int value => value,
        final Object? value => int.tryParse(value?.toString() ?? '') ?? 0,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'age': age,
      'gender': gender,
      'claimed_by_user_id': claimedByUserId,
      'coinsBalance': coinsBalance,
      'level': level,
      'currentStreakDays': currentStreakDays,
    };
  }
}
