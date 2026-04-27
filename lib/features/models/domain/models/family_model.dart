class FamilyModel {
  final String id;
  final String ownerUserId;
  final String name;
  final String timezone;
  final List<ChildSummaryModel> children;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyModel({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.timezone,
    required this.children,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    final childrenJson = (json['children'] ?? json['kids'] ?? json['members']);
    return FamilyModel(
      id: (json['id'] ?? json['family_id'] ?? json['familyId']) as String? ?? '',
      ownerUserId:
          (json['ownerUserId'] ?? json['owner_user_id'] ?? json['owner_id'])
              as String? ??
          '',
      name: (json['name'] ?? json['family_name'] ?? 'Family') as String,
      timezone: (json['timezone'] ?? 'UTC') as String,
      children: childrenJson is List
          ? childrenJson
              .whereType<Map<String, dynamic>>()
              .map(ChildSummaryModel.fromJson)
              .toList()
          : const <ChildSummaryModel>[],
      createdAt: DateTime.tryParse(
            (json['createdAt'] ?? json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
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
      'children': children.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChildSummaryModel {
  final String id;
  final String nickname;
  final int age;
  final int coinsBalance;
  final int level;

  const ChildSummaryModel({
    required this.id,
    required this.nickname,
    required this.age,
    required this.coinsBalance,
    required this.level,
  });

  factory ChildSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawAge = json['age'];
    final rawCoins = json['coinsBalance'] ?? json['coins_balance'];
    final rawLevel = json['level'] ?? json['rank'];
    return ChildSummaryModel(
      id: (json['id'] ?? json['child_id']) as String? ?? '',
      nickname: (json['nickname'] ?? json['name'] ?? json['display_name'])
          as String? ??
          'Child',
      age: rawAge is int ? rawAge : int.tryParse(rawAge?.toString() ?? '') ?? 0,
      coinsBalance: rawCoins is int
          ? rawCoins
          : int.tryParse(rawCoins?.toString() ?? '') ??
              0,
      level: rawLevel is int ? rawLevel : int.tryParse(rawLevel?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'age': age,
      'coinsBalance': coinsBalance,
      'level': level,
    };
  }
}
