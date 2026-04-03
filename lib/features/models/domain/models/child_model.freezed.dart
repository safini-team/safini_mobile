// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChildModel {
  String get id => throw _privateConstructorUsedError;
  String get familyId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  AvatarStateModel get avatarState => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get currentStreakDays => throw _privateConstructorUsedError;
  int get longestStreakDays => throw _privateConstructorUsedError;
  int get tasksCompletedCount => throw _privateConstructorUsedError;
  int get coinsBalance => throw _privateConstructorUsedError;
  int get achievementsCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of ChildModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildModelCopyWith<ChildModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildModelCopyWith<$Res> {
  factory $ChildModelCopyWith(
    ChildModel value,
    $Res Function(ChildModel) then,
  ) = _$ChildModelCopyWithImpl<$Res, ChildModel>;
  @useResult
  $Res call({
    String id,
    String familyId,
    String nickname,
    int age,
    String gender,
    AvatarStateModel avatarState,
    int level,
    int xp,
    int currentStreakDays,
    int longestStreakDays,
    int tasksCompletedCount,
    int coinsBalance,
    int achievementsCount,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $AvatarStateModelCopyWith<$Res> get avatarState;
}

/// @nodoc
class _$ChildModelCopyWithImpl<$Res, $Val extends ChildModel>
    implements $ChildModelCopyWith<$Res> {
  _$ChildModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChildModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? nickname = null,
    Object? age = null,
    Object? gender = null,
    Object? avatarState = null,
    Object? level = null,
    Object? xp = null,
    Object? currentStreakDays = null,
    Object? longestStreakDays = null,
    Object? tasksCompletedCount = null,
    Object? coinsBalance = null,
    Object? achievementsCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            familyId: null == familyId
                ? _value.familyId
                : familyId // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            age: null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarState: null == avatarState
                ? _value.avatarState
                : avatarState // ignore: cast_nullable_to_non_nullable
                      as AvatarStateModel,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            currentStreakDays: null == currentStreakDays
                ? _value.currentStreakDays
                : currentStreakDays // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreakDays: null == longestStreakDays
                ? _value.longestStreakDays
                : longestStreakDays // ignore: cast_nullable_to_non_nullable
                      as int,
            tasksCompletedCount: null == tasksCompletedCount
                ? _value.tasksCompletedCount
                : tasksCompletedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            coinsBalance: null == coinsBalance
                ? _value.coinsBalance
                : coinsBalance // ignore: cast_nullable_to_non_nullable
                      as int,
            achievementsCount: null == achievementsCount
                ? _value.achievementsCount
                : achievementsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of ChildModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AvatarStateModelCopyWith<$Res> get avatarState {
    return $AvatarStateModelCopyWith<$Res>(_value.avatarState, (value) {
      return _then(_value.copyWith(avatarState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChildModelImplCopyWith<$Res>
    implements $ChildModelCopyWith<$Res> {
  factory _$$ChildModelImplCopyWith(
    _$ChildModelImpl value,
    $Res Function(_$ChildModelImpl) then,
  ) = __$$ChildModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String familyId,
    String nickname,
    int age,
    String gender,
    AvatarStateModel avatarState,
    int level,
    int xp,
    int currentStreakDays,
    int longestStreakDays,
    int tasksCompletedCount,
    int coinsBalance,
    int achievementsCount,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $AvatarStateModelCopyWith<$Res> get avatarState;
}

/// @nodoc
class __$$ChildModelImplCopyWithImpl<$Res>
    extends _$ChildModelCopyWithImpl<$Res, _$ChildModelImpl>
    implements _$$ChildModelImplCopyWith<$Res> {
  __$$ChildModelImplCopyWithImpl(
    _$ChildModelImpl _value,
    $Res Function(_$ChildModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChildModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? nickname = null,
    Object? age = null,
    Object? gender = null,
    Object? avatarState = null,
    Object? level = null,
    Object? xp = null,
    Object? currentStreakDays = null,
    Object? longestStreakDays = null,
    Object? tasksCompletedCount = null,
    Object? coinsBalance = null,
    Object? achievementsCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ChildModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        familyId: null == familyId
            ? _value.familyId
            : familyId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        age: null == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarState: null == avatarState
            ? _value.avatarState
            : avatarState // ignore: cast_nullable_to_non_nullable
                  as AvatarStateModel,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        currentStreakDays: null == currentStreakDays
            ? _value.currentStreakDays
            : currentStreakDays // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreakDays: null == longestStreakDays
            ? _value.longestStreakDays
            : longestStreakDays // ignore: cast_nullable_to_non_nullable
                  as int,
        tasksCompletedCount: null == tasksCompletedCount
            ? _value.tasksCompletedCount
            : tasksCompletedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        coinsBalance: null == coinsBalance
            ? _value.coinsBalance
            : coinsBalance // ignore: cast_nullable_to_non_nullable
                  as int,
        achievementsCount: null == achievementsCount
            ? _value.achievementsCount
            : achievementsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$ChildModelImpl implements _ChildModel {
  const _$ChildModelImpl({
    required this.id,
    required this.familyId,
    required this.nickname,
    required this.age,
    required this.gender,
    required this.avatarState,
    required this.level,
    required this.xp,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.tasksCompletedCount,
    required this.coinsBalance,
    required this.achievementsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;
  @override
  final String familyId;
  @override
  final String nickname;
  @override
  final int age;
  @override
  final String gender;
  @override
  final AvatarStateModel avatarState;
  @override
  final int level;
  @override
  final int xp;
  @override
  final int currentStreakDays;
  @override
  final int longestStreakDays;
  @override
  final int tasksCompletedCount;
  @override
  final int coinsBalance;
  @override
  final int achievementsCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ChildModel(id: $id, familyId: $familyId, nickname: $nickname, age: $age, gender: $gender, avatarState: $avatarState, level: $level, xp: $xp, currentStreakDays: $currentStreakDays, longestStreakDays: $longestStreakDays, tasksCompletedCount: $tasksCompletedCount, coinsBalance: $coinsBalance, achievementsCount: $achievementsCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.avatarState, avatarState) ||
                other.avatarState == avatarState) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.currentStreakDays, currentStreakDays) ||
                other.currentStreakDays == currentStreakDays) &&
            (identical(other.longestStreakDays, longestStreakDays) ||
                other.longestStreakDays == longestStreakDays) &&
            (identical(other.tasksCompletedCount, tasksCompletedCount) ||
                other.tasksCompletedCount == tasksCompletedCount) &&
            (identical(other.coinsBalance, coinsBalance) ||
                other.coinsBalance == coinsBalance) &&
            (identical(other.achievementsCount, achievementsCount) ||
                other.achievementsCount == achievementsCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    familyId,
    nickname,
    age,
    gender,
    avatarState,
    level,
    xp,
    currentStreakDays,
    longestStreakDays,
    tasksCompletedCount,
    coinsBalance,
    achievementsCount,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ChildModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildModelImplCopyWith<_$ChildModelImpl> get copyWith =>
      __$$ChildModelImplCopyWithImpl<_$ChildModelImpl>(this, _$identity);
}

abstract class _ChildModel implements ChildModel {
  const factory _ChildModel({
    required final String id,
    required final String familyId,
    required final String nickname,
    required final int age,
    required final String gender,
    required final AvatarStateModel avatarState,
    required final int level,
    required final int xp,
    required final int currentStreakDays,
    required final int longestStreakDays,
    required final int tasksCompletedCount,
    required final int coinsBalance,
    required final int achievementsCount,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ChildModelImpl;

  @override
  String get id;
  @override
  String get familyId;
  @override
  String get nickname;
  @override
  int get age;
  @override
  String get gender;
  @override
  AvatarStateModel get avatarState;
  @override
  int get level;
  @override
  int get xp;
  @override
  int get currentStreakDays;
  @override
  int get longestStreakDays;
  @override
  int get tasksCompletedCount;
  @override
  int get coinsBalance;
  @override
  int get achievementsCount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of ChildModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildModelImplCopyWith<_$ChildModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AvatarStateModel {
  Map<String, String> get equipped => throw _privateConstructorUsedError;

  /// Create a copy of AvatarStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvatarStateModelCopyWith<AvatarStateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvatarStateModelCopyWith<$Res> {
  factory $AvatarStateModelCopyWith(
    AvatarStateModel value,
    $Res Function(AvatarStateModel) then,
  ) = _$AvatarStateModelCopyWithImpl<$Res, AvatarStateModel>;
  @useResult
  $Res call({Map<String, String> equipped});
}

/// @nodoc
class _$AvatarStateModelCopyWithImpl<$Res, $Val extends AvatarStateModel>
    implements $AvatarStateModelCopyWith<$Res> {
  _$AvatarStateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvatarStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? equipped = null}) {
    return _then(
      _value.copyWith(
            equipped: null == equipped
                ? _value.equipped
                : equipped // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AvatarStateModelImplCopyWith<$Res>
    implements $AvatarStateModelCopyWith<$Res> {
  factory _$$AvatarStateModelImplCopyWith(
    _$AvatarStateModelImpl value,
    $Res Function(_$AvatarStateModelImpl) then,
  ) = __$$AvatarStateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, String> equipped});
}

/// @nodoc
class __$$AvatarStateModelImplCopyWithImpl<$Res>
    extends _$AvatarStateModelCopyWithImpl<$Res, _$AvatarStateModelImpl>
    implements _$$AvatarStateModelImplCopyWith<$Res> {
  __$$AvatarStateModelImplCopyWithImpl(
    _$AvatarStateModelImpl _value,
    $Res Function(_$AvatarStateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AvatarStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? equipped = null}) {
    return _then(
      _$AvatarStateModelImpl(
        equipped: null == equipped
            ? _value._equipped
            : equipped // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc

class _$AvatarStateModelImpl implements _AvatarStateModel {
  const _$AvatarStateModelImpl({required final Map<String, String> equipped})
    : _equipped = equipped;

  final Map<String, String> _equipped;
  @override
  Map<String, String> get equipped {
    if (_equipped is EqualUnmodifiableMapView) return _equipped;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_equipped);
  }

  @override
  String toString() {
    return 'AvatarStateModel(equipped: $equipped)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvatarStateModelImpl &&
            const DeepCollectionEquality().equals(other._equipped, _equipped));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_equipped));

  /// Create a copy of AvatarStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvatarStateModelImplCopyWith<_$AvatarStateModelImpl> get copyWith =>
      __$$AvatarStateModelImplCopyWithImpl<_$AvatarStateModelImpl>(
        this,
        _$identity,
      );
}

abstract class _AvatarStateModel implements AvatarStateModel {
  const factory _AvatarStateModel({
    required final Map<String, String> equipped,
  }) = _$AvatarStateModelImpl;

  @override
  Map<String, String> get equipped;

  /// Create a copy of AvatarStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvatarStateModelImplCopyWith<_$AvatarStateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
