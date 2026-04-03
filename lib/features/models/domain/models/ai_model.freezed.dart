// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AIConversationLogModel {
  String get id => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  int get messageCount => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of AIConversationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIConversationLogModelCopyWith<AIConversationLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIConversationLogModelCopyWith<$Res> {
  factory $AIConversationLogModelCopyWith(
    AIConversationLogModel value,
    $Res Function(AIConversationLogModel) then,
  ) = _$AIConversationLogModelCopyWithImpl<$Res, AIConversationLogModel>;
  @useResult
  $Res call({
    String id,
    String childId,
    int messageCount,
    DateTime? lastMessageAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AIConversationLogModelCopyWithImpl<
  $Res,
  $Val extends AIConversationLogModel
>
    implements $AIConversationLogModelCopyWith<$Res> {
  _$AIConversationLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIConversationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? messageCount = null,
    Object? lastMessageAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            messageCount: null == messageCount
                ? _value.messageCount
                : messageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastMessageAt: freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AIConversationLogModelImplCopyWith<$Res>
    implements $AIConversationLogModelCopyWith<$Res> {
  factory _$$AIConversationLogModelImplCopyWith(
    _$AIConversationLogModelImpl value,
    $Res Function(_$AIConversationLogModelImpl) then,
  ) = __$$AIConversationLogModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String childId,
    int messageCount,
    DateTime? lastMessageAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AIConversationLogModelImplCopyWithImpl<$Res>
    extends
        _$AIConversationLogModelCopyWithImpl<$Res, _$AIConversationLogModelImpl>
    implements _$$AIConversationLogModelImplCopyWith<$Res> {
  __$$AIConversationLogModelImplCopyWithImpl(
    _$AIConversationLogModelImpl _value,
    $Res Function(_$AIConversationLogModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AIConversationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? messageCount = null,
    Object? lastMessageAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$AIConversationLogModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        messageCount: null == messageCount
            ? _value.messageCount
            : messageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastMessageAt: freezed == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AIConversationLogModelImpl implements _AIConversationLogModel {
  const _$AIConversationLogModelImpl({
    required this.id,
    required this.childId,
    required this.messageCount,
    this.lastMessageAt,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String childId;
  @override
  final int messageCount;
  @override
  final DateTime? lastMessageAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AIConversationLogModel(id: $id, childId: $childId, messageCount: $messageCount, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIConversationLogModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    childId,
    messageCount,
    lastMessageAt,
    createdAt,
  );

  /// Create a copy of AIConversationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIConversationLogModelImplCopyWith<_$AIConversationLogModelImpl>
  get copyWith =>
      __$$AIConversationLogModelImplCopyWithImpl<_$AIConversationLogModelImpl>(
        this,
        _$identity,
      );
}

abstract class _AIConversationLogModel implements AIConversationLogModel {
  const factory _AIConversationLogModel({
    required final String id,
    required final String childId,
    required final int messageCount,
    final DateTime? lastMessageAt,
    required final DateTime createdAt,
  }) = _$AIConversationLogModelImpl;

  @override
  String get id;
  @override
  String get childId;
  @override
  int get messageCount;
  @override
  DateTime? get lastMessageAt;
  @override
  DateTime get createdAt;

  /// Create a copy of AIConversationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIConversationLogModelImplCopyWith<_$AIConversationLogModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AIMessageModel {
  String get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of AIMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIMessageModelCopyWith<AIMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIMessageModelCopyWith<$Res> {
  factory $AIMessageModelCopyWith(
    AIMessageModel value,
    $Res Function(AIMessageModel) then,
  ) = _$AIMessageModelCopyWithImpl<$Res, AIMessageModel>;
  @useResult
  $Res call({String role, String content, DateTime createdAt});
}

/// @nodoc
class _$AIMessageModelCopyWithImpl<$Res, $Val extends AIMessageModel>
    implements $AIMessageModelCopyWith<$Res> {
  _$AIMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AIMessageModelImplCopyWith<$Res>
    implements $AIMessageModelCopyWith<$Res> {
  factory _$$AIMessageModelImplCopyWith(
    _$AIMessageModelImpl value,
    $Res Function(_$AIMessageModelImpl) then,
  ) = __$$AIMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String role, String content, DateTime createdAt});
}

/// @nodoc
class __$$AIMessageModelImplCopyWithImpl<$Res>
    extends _$AIMessageModelCopyWithImpl<$Res, _$AIMessageModelImpl>
    implements _$$AIMessageModelImplCopyWith<$Res> {
  __$$AIMessageModelImplCopyWithImpl(
    _$AIMessageModelImpl _value,
    $Res Function(_$AIMessageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AIMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AIMessageModelImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AIMessageModelImpl implements _AIMessageModel {
  const _$AIMessageModelImpl({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  @override
  final String role;
  @override
  final String content;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AIMessageModel(role: $role, content: $content, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIMessageModelImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, content, createdAt);

  /// Create a copy of AIMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIMessageModelImplCopyWith<_$AIMessageModelImpl> get copyWith =>
      __$$AIMessageModelImplCopyWithImpl<_$AIMessageModelImpl>(
        this,
        _$identity,
      );
}

abstract class _AIMessageModel implements AIMessageModel {
  const factory _AIMessageModel({
    required final String role,
    required final String content,
    required final DateTime createdAt,
  }) = _$AIMessageModelImpl;

  @override
  String get role;
  @override
  String get content;
  @override
  DateTime get createdAt;

  /// Create a copy of AIMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIMessageModelImplCopyWith<_$AIMessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TaskSuggestionModel {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get coinsReward => throw _privateConstructorUsedError;
  int get xpReward => throw _privateConstructorUsedError;
  String get reasoning => throw _privateConstructorUsedError;

  /// Create a copy of TaskSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskSuggestionModelCopyWith<TaskSuggestionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskSuggestionModelCopyWith<$Res> {
  factory $TaskSuggestionModelCopyWith(
    TaskSuggestionModel value,
    $Res Function(TaskSuggestionModel) then,
  ) = _$TaskSuggestionModelCopyWithImpl<$Res, TaskSuggestionModel>;
  @useResult
  $Res call({
    String title,
    String description,
    String category,
    int coinsReward,
    int xpReward,
    String reasoning,
  });
}

/// @nodoc
class _$TaskSuggestionModelCopyWithImpl<$Res, $Val extends TaskSuggestionModel>
    implements $TaskSuggestionModelCopyWith<$Res> {
  _$TaskSuggestionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? coinsReward = null,
    Object? xpReward = null,
    Object? reasoning = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            coinsReward: null == coinsReward
                ? _value.coinsReward
                : coinsReward // ignore: cast_nullable_to_non_nullable
                      as int,
            xpReward: null == xpReward
                ? _value.xpReward
                : xpReward // ignore: cast_nullable_to_non_nullable
                      as int,
            reasoning: null == reasoning
                ? _value.reasoning
                : reasoning // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaskSuggestionModelImplCopyWith<$Res>
    implements $TaskSuggestionModelCopyWith<$Res> {
  factory _$$TaskSuggestionModelImplCopyWith(
    _$TaskSuggestionModelImpl value,
    $Res Function(_$TaskSuggestionModelImpl) then,
  ) = __$$TaskSuggestionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String description,
    String category,
    int coinsReward,
    int xpReward,
    String reasoning,
  });
}

/// @nodoc
class __$$TaskSuggestionModelImplCopyWithImpl<$Res>
    extends _$TaskSuggestionModelCopyWithImpl<$Res, _$TaskSuggestionModelImpl>
    implements _$$TaskSuggestionModelImplCopyWith<$Res> {
  __$$TaskSuggestionModelImplCopyWithImpl(
    _$TaskSuggestionModelImpl _value,
    $Res Function(_$TaskSuggestionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? coinsReward = null,
    Object? xpReward = null,
    Object? reasoning = null,
  }) {
    return _then(
      _$TaskSuggestionModelImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        coinsReward: null == coinsReward
            ? _value.coinsReward
            : coinsReward // ignore: cast_nullable_to_non_nullable
                  as int,
        xpReward: null == xpReward
            ? _value.xpReward
            : xpReward // ignore: cast_nullable_to_non_nullable
                  as int,
        reasoning: null == reasoning
            ? _value.reasoning
            : reasoning // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TaskSuggestionModelImpl implements _TaskSuggestionModel {
  const _$TaskSuggestionModelImpl({
    required this.title,
    required this.description,
    required this.category,
    required this.coinsReward,
    required this.xpReward,
    required this.reasoning,
  });

  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  @override
  final int coinsReward;
  @override
  final int xpReward;
  @override
  final String reasoning;

  @override
  String toString() {
    return 'TaskSuggestionModel(title: $title, description: $description, category: $category, coinsReward: $coinsReward, xpReward: $xpReward, reasoning: $reasoning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskSuggestionModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.coinsReward, coinsReward) ||
                other.coinsReward == coinsReward) &&
            (identical(other.xpReward, xpReward) ||
                other.xpReward == xpReward) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    description,
    category,
    coinsReward,
    xpReward,
    reasoning,
  );

  /// Create a copy of TaskSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskSuggestionModelImplCopyWith<_$TaskSuggestionModelImpl> get copyWith =>
      __$$TaskSuggestionModelImplCopyWithImpl<_$TaskSuggestionModelImpl>(
        this,
        _$identity,
      );
}

abstract class _TaskSuggestionModel implements TaskSuggestionModel {
  const factory _TaskSuggestionModel({
    required final String title,
    required final String description,
    required final String category,
    required final int coinsReward,
    required final int xpReward,
    required final String reasoning,
  }) = _$TaskSuggestionModelImpl;

  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  int get coinsReward;
  @override
  int get xpReward;
  @override
  String get reasoning;

  /// Create a copy of TaskSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskSuggestionModelImplCopyWith<_$TaskSuggestionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
