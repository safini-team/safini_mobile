// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WalletHistoryModel {
  String get id => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get transactionType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of WalletHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletHistoryModelCopyWith<WalletHistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletHistoryModelCopyWith<$Res> {
  factory $WalletHistoryModelCopyWith(
    WalletHistoryModel value,
    $Res Function(WalletHistoryModel) then,
  ) = _$WalletHistoryModelCopyWithImpl<$Res, WalletHistoryModel>;
  @useResult
  $Res call({
    String id,
    String childId,
    int amount,
    String transactionType,
    String description,
    DateTime createdAt,
  });
}

/// @nodoc
class _$WalletHistoryModelCopyWithImpl<$Res, $Val extends WalletHistoryModel>
    implements $WalletHistoryModelCopyWith<$Res> {
  _$WalletHistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? amount = null,
    Object? transactionType = null,
    Object? description = null,
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
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            transactionType: null == transactionType
                ? _value.transactionType
                : transactionType // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
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
abstract class _$$WalletHistoryModelImplCopyWith<$Res>
    implements $WalletHistoryModelCopyWith<$Res> {
  factory _$$WalletHistoryModelImplCopyWith(
    _$WalletHistoryModelImpl value,
    $Res Function(_$WalletHistoryModelImpl) then,
  ) = __$$WalletHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String childId,
    int amount,
    String transactionType,
    String description,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$WalletHistoryModelImplCopyWithImpl<$Res>
    extends _$WalletHistoryModelCopyWithImpl<$Res, _$WalletHistoryModelImpl>
    implements _$$WalletHistoryModelImplCopyWith<$Res> {
  __$$WalletHistoryModelImplCopyWithImpl(
    _$WalletHistoryModelImpl _value,
    $Res Function(_$WalletHistoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WalletHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? amount = null,
    Object? transactionType = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$WalletHistoryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        transactionType: null == transactionType
            ? _value.transactionType
            : transactionType // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
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

class _$WalletHistoryModelImpl implements _WalletHistoryModel {
  const _$WalletHistoryModelImpl({
    required this.id,
    required this.childId,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String childId;
  @override
  final int amount;
  @override
  final String transactionType;
  @override
  final String description;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'WalletHistoryModel(id: $id, childId: $childId, amount: $amount, transactionType: $transactionType, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletHistoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    childId,
    amount,
    transactionType,
    description,
    createdAt,
  );

  /// Create a copy of WalletHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletHistoryModelImplCopyWith<_$WalletHistoryModelImpl> get copyWith =>
      __$$WalletHistoryModelImplCopyWithImpl<_$WalletHistoryModelImpl>(
        this,
        _$identity,
      );
}

abstract class _WalletHistoryModel implements WalletHistoryModel {
  const factory _WalletHistoryModel({
    required final String id,
    required final String childId,
    required final int amount,
    required final String transactionType,
    required final String description,
    required final DateTime createdAt,
  }) = _$WalletHistoryModelImpl;

  @override
  String get id;
  @override
  String get childId;
  @override
  int get amount;
  @override
  String get transactionType;
  @override
  String get description;
  @override
  DateTime get createdAt;

  /// Create a copy of WalletHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletHistoryModelImplCopyWith<_$WalletHistoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StoreOfferModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get coinsPrice => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of StoreOfferModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreOfferModelCopyWith<StoreOfferModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreOfferModelCopyWith<$Res> {
  factory $StoreOfferModelCopyWith(
    StoreOfferModel value,
    $Res Function(StoreOfferModel) then,
  ) = _$StoreOfferModelCopyWithImpl<$Res, StoreOfferModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String category,
    int coinsPrice,
    bool isAvailable,
    DateTime createdAt,
  });
}

/// @nodoc
class _$StoreOfferModelCopyWithImpl<$Res, $Val extends StoreOfferModel>
    implements $StoreOfferModelCopyWith<$Res> {
  _$StoreOfferModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoreOfferModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? coinsPrice = null,
    Object? isAvailable = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
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
            coinsPrice: null == coinsPrice
                ? _value.coinsPrice
                : coinsPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$StoreOfferModelImplCopyWith<$Res>
    implements $StoreOfferModelCopyWith<$Res> {
  factory _$$StoreOfferModelImplCopyWith(
    _$StoreOfferModelImpl value,
    $Res Function(_$StoreOfferModelImpl) then,
  ) = __$$StoreOfferModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String category,
    int coinsPrice,
    bool isAvailable,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$StoreOfferModelImplCopyWithImpl<$Res>
    extends _$StoreOfferModelCopyWithImpl<$Res, _$StoreOfferModelImpl>
    implements _$$StoreOfferModelImplCopyWith<$Res> {
  __$$StoreOfferModelImplCopyWithImpl(
    _$StoreOfferModelImpl _value,
    $Res Function(_$StoreOfferModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoreOfferModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? coinsPrice = null,
    Object? isAvailable = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$StoreOfferModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
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
        coinsPrice: null == coinsPrice
            ? _value.coinsPrice
            : coinsPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$StoreOfferModelImpl implements _StoreOfferModel {
  const _$StoreOfferModelImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.coinsPrice,
    required this.isAvailable,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  @override
  final int coinsPrice;
  @override
  final bool isAvailable;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'StoreOfferModel(id: $id, title: $title, description: $description, category: $category, coinsPrice: $coinsPrice, isAvailable: $isAvailable, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreOfferModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.coinsPrice, coinsPrice) ||
                other.coinsPrice == coinsPrice) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    category,
    coinsPrice,
    isAvailable,
    createdAt,
  );

  /// Create a copy of StoreOfferModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreOfferModelImplCopyWith<_$StoreOfferModelImpl> get copyWith =>
      __$$StoreOfferModelImplCopyWithImpl<_$StoreOfferModelImpl>(
        this,
        _$identity,
      );
}

abstract class _StoreOfferModel implements StoreOfferModel {
  const factory _StoreOfferModel({
    required final String id,
    required final String title,
    required final String description,
    required final String category,
    required final int coinsPrice,
    required final bool isAvailable,
    required final DateTime createdAt,
  }) = _$StoreOfferModelImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  int get coinsPrice;
  @override
  bool get isAvailable;
  @override
  DateTime get createdAt;

  /// Create a copy of StoreOfferModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreOfferModelImplCopyWith<_$StoreOfferModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RedemptionResultModel {
  String get id => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  String get offerId => throw _privateConstructorUsedError;
  int get newBalance => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of RedemptionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedemptionResultModelCopyWith<RedemptionResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedemptionResultModelCopyWith<$Res> {
  factory $RedemptionResultModelCopyWith(
    RedemptionResultModel value,
    $Res Function(RedemptionResultModel) then,
  ) = _$RedemptionResultModelCopyWithImpl<$Res, RedemptionResultModel>;
  @useResult
  $Res call({
    String id,
    String childId,
    String offerId,
    int newBalance,
    DateTime createdAt,
  });
}

/// @nodoc
class _$RedemptionResultModelCopyWithImpl<
  $Res,
  $Val extends RedemptionResultModel
>
    implements $RedemptionResultModelCopyWith<$Res> {
  _$RedemptionResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedemptionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? offerId = null,
    Object? newBalance = null,
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
            offerId: null == offerId
                ? _value.offerId
                : offerId // ignore: cast_nullable_to_non_nullable
                      as String,
            newBalance: null == newBalance
                ? _value.newBalance
                : newBalance // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$RedemptionResultModelImplCopyWith<$Res>
    implements $RedemptionResultModelCopyWith<$Res> {
  factory _$$RedemptionResultModelImplCopyWith(
    _$RedemptionResultModelImpl value,
    $Res Function(_$RedemptionResultModelImpl) then,
  ) = __$$RedemptionResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String childId,
    String offerId,
    int newBalance,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$RedemptionResultModelImplCopyWithImpl<$Res>
    extends
        _$RedemptionResultModelCopyWithImpl<$Res, _$RedemptionResultModelImpl>
    implements _$$RedemptionResultModelImplCopyWith<$Res> {
  __$$RedemptionResultModelImplCopyWithImpl(
    _$RedemptionResultModelImpl _value,
    $Res Function(_$RedemptionResultModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RedemptionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? offerId = null,
    Object? newBalance = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RedemptionResultModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        offerId: null == offerId
            ? _value.offerId
            : offerId // ignore: cast_nullable_to_non_nullable
                  as String,
        newBalance: null == newBalance
            ? _value.newBalance
            : newBalance // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$RedemptionResultModelImpl implements _RedemptionResultModel {
  const _$RedemptionResultModelImpl({
    required this.id,
    required this.childId,
    required this.offerId,
    required this.newBalance,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String childId;
  @override
  final String offerId;
  @override
  final int newBalance;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RedemptionResultModel(id: $id, childId: $childId, offerId: $offerId, newBalance: $newBalance, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedemptionResultModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.offerId, offerId) || other.offerId == offerId) &&
            (identical(other.newBalance, newBalance) ||
                other.newBalance == newBalance) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, childId, offerId, newBalance, createdAt);

  /// Create a copy of RedemptionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedemptionResultModelImplCopyWith<_$RedemptionResultModelImpl>
  get copyWith =>
      __$$RedemptionResultModelImplCopyWithImpl<_$RedemptionResultModelImpl>(
        this,
        _$identity,
      );
}

abstract class _RedemptionResultModel implements RedemptionResultModel {
  const factory _RedemptionResultModel({
    required final String id,
    required final String childId,
    required final String offerId,
    required final int newBalance,
    required final DateTime createdAt,
  }) = _$RedemptionResultModelImpl;

  @override
  String get id;
  @override
  String get childId;
  @override
  String get offerId;
  @override
  int get newBalance;
  @override
  DateTime get createdAt;

  /// Create a copy of RedemptionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedemptionResultModelImplCopyWith<_$RedemptionResultModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
