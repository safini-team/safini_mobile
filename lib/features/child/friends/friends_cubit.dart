import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/friends/friend.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';

class FriendsState {
  const FriendsState({
    this.loading = true,
    this.publicId,
    this.friends = const [],
    this.sortByLevel = false,
    this.loadFailed = false,
    this.busy = false,
  });

  final bool loading;
  final String? publicId;
  final List<FriendSummary> friends;
  final bool sortByLevel;
  final bool loadFailed;
  final bool busy;

  List<FriendSummary> get visible =>
      orderedFriends(friends, byLevel: sortByLevel);

  FriendsState copyWith({
    bool? loading,
    String? publicId,
    List<FriendSummary>? friends,
    bool? sortByLevel,
    bool? loadFailed,
    bool? busy,
  }) {
    return FriendsState(
      loading: loading ?? this.loading,
      publicId: publicId ?? this.publicId,
      friends: friends ?? this.friends,
      sortByLevel: sortByLevel ?? this.sortByLevel,
      loadFailed: loadFailed ?? this.loadFailed,
      busy: busy ?? this.busy,
    );
  }
}

class FriendsCubit extends Cubit<FriendsState> {
  FriendsCubit(this._api, this._profiles) : super(const FriendsState());

  final FriendsApi _api;
  final ProfileController _profiles;
  String? _childId;

  Future<void> load() async {
    emit(state.copyWith(loading: state.friends.isEmpty, loadFailed: false));
    final childId = await _resolveChildId();
    if (childId == null) {
      emit(state.copyWith(loading: false, loadFailed: true));
      return;
    }
    try {
      final page = await _api.list(childId);
      emit(
        state.copyWith(
          loading: false,
          loadFailed: false,
          publicId: page.publicId,
          friends: page.friends,
        ),
      );
    } on Exception {
      emit(state.copyWith(loading: false, loadFailed: true));
    }
  }

  void toggleSort() => emit(state.copyWith(sortByLevel: !state.sortByLevel));

  Future<FriendsError?> add(String publicId) async {
    final code = publicId.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) return FriendsError.invalid;
    final childId = await _resolveChildId();
    if (childId == null) return FriendsError.unavailable;
    emit(state.copyWith(busy: true));
    try {
      final friend = await _api.add(childId, code);
      final without = state.friends
          .where((row) => row.childId != friend.childId)
          .toList();
      emit(
        state.copyWith(
          busy: false,
          publicId: state.publicId,
          friends: [friend, ...without],
        ),
      );
      return null;
    } on FriendsException catch (error) {
      emit(state.copyWith(busy: false));
      return error.code;
    } on Exception {
      emit(state.copyWith(busy: false));
      return FriendsError.unavailable;
    }
  }

  Future<FriendsError?> remove(String friendChildId) async {
    final childId = await _resolveChildId();
    if (childId == null) return FriendsError.unavailable;
    emit(state.copyWith(busy: true));
    try {
      await _api.remove(childId, friendChildId);
      emit(
        state.copyWith(
          busy: false,
          friends: state.friends
              .where((row) => row.childId != friendChildId)
              .toList(),
        ),
      );
      return null;
    } on FriendsException catch (error) {
      emit(state.copyWith(busy: false));
      return error.code;
    } on Exception {
      emit(state.copyWith(busy: false));
      return FriendsError.unavailable;
    }
  }

  Future<String?> _resolveChildId() async {
    final cached = _childId;
    if (cached != null && cached.isNotEmpty) return cached;
    final me = await _profiles.fetchMe();
    _childId = me.fold((_) => null, (profile) {
      final id = profile.childId?.trim();
      return id == null || id.isEmpty ? null : id;
    });
    return _childId;
  }
}
