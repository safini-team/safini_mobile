// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FamilyModel {
  String get id => throw _privateConstructorUsedError;
  String get ownerUserId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  List<ChildSummaryModel> get children => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of FamilyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilyModelCopyWith<FamilyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyModelCopyWith<$Res> {
  factory $FamilyModelCopyWith(
    FamilyModel value,
    $Res Function(FamilyModel) then,
  ) = _$FamilyModelCopyWithImpl<$Res, FamilyModel>;
  @useResult
  $Res call({
    String id,
    String ownerUserId,
    String name,
    String timezone,
    List<ChildSummaryModel> children,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$FamilyModelCopyWithImpl<$Res, $Val extends FamilyModel>
    implements $FamilyModelCopyWith<$Res> {
  _$FamilyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerUserId = null,
    Object? name = null,
    Object? timezone = null,
    Object? children = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerUserId: null == ownerUserId
                ? _value.ownerUserId
                : ownerUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String,
            children: null == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                      as List<ChildSummaryModel>,
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
}

/// @nodoc
abstract class _$$FamilyModelImplCopyWith<$Res>
    implements $FamilyModelCopyWith<$Res> {
  factory _$$FamilyModelImplCopyWith(
    _$FamilyModelImpl value,
    $Res Function(_$FamilyModelImpl) then,
  ) = __$$FamilyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerUserId,
    String name,
    String timezone,
    List<ChildSummaryModel> children,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$FamilyModelImplCopyWithImpl<$Res>
    extends _$FamilyModelCopyWithImpl<$Res, _$FamilyModelImpl>
    implements _$$FamilyModelImplCopyWith<$Res> {
  __$$FamilyModelImplCopyWithImpl(
    _$FamilyModelImpl _value,
    $Res Function(_$FamilyModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FamilyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerUserId = null,
    Object? name = null,
    Object? timezone = null,
    Object? children = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$FamilyModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerUserId: null == ownerUserId
            ? _value.ownerUserId
            : ownerUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String,
        children: null == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<ChildSummaryModel>,
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

class _$FamilyModelImpl implements _FamilyModel {
  const _$FamilyModelImpl({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.timezone,
    required final List<ChildSummaryModel> children,
    required this.createdAt,
    required this.updatedAt,
  }) : _children = children;

  @override
  final String id;
  @override
  final String ownerUserId;
  @override
  final String name;
  @override
  final String timezone;
  final List<ChildSummaryModel> _children;
  @override
  List<ChildSummaryModel> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FamilyModel(id: $id, ownerUserId: $ownerUserId, name: $name, timezone: $timezone, children: $children, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerUserId, ownerUserId) ||
                other.ownerUserId == ownerUserId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            const DeepCollectionEquality().equals(other._children, _children) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerUserId,
    name,
    timezone,
    const DeepCollectionEquality().hash(_children),
    createdAt,
    updatedAt,
  );

  /// Create a copy of FamilyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyModelImplCopyWith<_$FamilyModelImpl> get copyWith =>
      __$$FamilyModelImplCopyWithImpl<_$FamilyModelImpl>(this, _$identity);
}

abstract class _FamilyModel implements FamilyModel {
  const factory _FamilyModel({
    required final String id,
    required final String ownerUserId,
    required final String name,
    required final String timezone,
    required final List<ChildSummaryModel> children,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$FamilyModelImpl;

  @override
  String get id;
  @override
  String get ownerUserId;
  @override
  String get name;
  @override
  String get timezone;
  @override
  List<ChildSummaryModel> get children;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of FamilyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilyModelImplCopyWith<_$FamilyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChildSummaryModel {
  String get id => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  int get coinsBalance => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;

  /// Create a copy of ChildSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildSummaryModelCopyWith<ChildSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildSummaryModelCopyWith<$Res> {
  factory $ChildSummaryModelCopyWith(
    ChildSummaryModel value,
    $Res Function(ChildSummaryModel) then,
  ) = _$ChildSummaryModelCopyWithImpl<$Res, ChildSummaryModel>;
  @useResult
  $Res call({String id, String nickname, int age, int coinsBalance, int level});
}

/// @nodoc
class _$ChildSummaryModelCopyWithImpl<$Res, $Val extends ChildSummaryModel>
    implements $ChildSummaryModelCopyWith<$Res> {
  _$ChildSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChildSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nickname = null,
    Object? age = null,
    Object? coinsBalance = null,
    Object? level = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            age: null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int,
            coinsBalance: null == coinsBalance
                ? _value.coinsBalance
                : coinsBalance // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChildSummaryModelImplCopyWith<$Res>
    implements $ChildSummaryModelCopyWith<$Res> {
  factory _$$ChildSummaryModelImplCopyWith(
    _$ChildSummaryModelImpl value,
    $Res Function(_$ChildSummaryModelImpl) then,
  ) = __$$ChildSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nickname, int age, int coinsBalance, int level});
}

/// @nodoc
class __$$ChildSummaryModelImplCopyWithImpl<$Res>
    extends _$ChildSummaryModelCopyWithImpl<$Res, _$ChildSummaryModelImpl>
    implements _$$ChildSummaryModelImplCopyWith<$Res> {
  __$$ChildSummaryModelImplCopyWithImpl(
    _$ChildSummaryModelImpl _value,
    $Res Function(_$ChildSummaryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChildSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nickname = null,
    Object? age = null,
    Object? coinsBalance = null,
    Object? level = null,
  }) {
    return _then(
      _$ChildSummaryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        age: null == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int,
        coinsBalance: null == coinsBalance
            ? _value.coinsBalance
            : coinsBalance // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ChildSummaryModelImpl implements _ChildSummaryModel {
  const _$ChildSummaryModelImpl({
    required this.id,
    required this.nickname,
    required this.age,
    required this.coinsBalance,
    required this.level,
  });

  @override
  final String id;
  @override
  final String nickname;
  @override
  final int age;
  @override
  final int coinsBalance;
  @override
  final int level;

  @override
  String toString() {
    return 'ChildSummaryModel(id: $id, nickname: $nickname, age: $age, coinsBalance: $coinsBalance, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildSummaryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.coinsBalance, coinsBalance) ||
                other.coinsBalance == coinsBalance) &&
            (identical(other.level, level) || other.level == level));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nickname, age, coinsBalance, level);

  /// Create a copy of ChildSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildSummaryModelImplCopyWith<_$ChildSummaryModelImpl> get copyWith =>
      __$$ChildSummaryModelImplCopyWithImpl<_$ChildSummaryModelImpl>(
        this,
        _$identity,
      );
}

abstract class _ChildSummaryModel implements ChildSummaryModel {
  const factory _ChildSummaryModel({
    required final String id,
    required final String nickname,
    required final int age,
    required final int coinsBalance,
    required final int level,
  }) = _$ChildSummaryModelImpl;

  @override
  String get id;
  @override
  String get nickname;
  @override
  int get age;
  @override
  int get coinsBalance;
  @override
  int get level;

  /// Create a copy of ChildSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildSummaryModelImplCopyWith<_$ChildSummaryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
