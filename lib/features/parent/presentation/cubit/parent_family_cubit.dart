import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/models/domain/models/child_invite_code_model.dart';
import 'package:safini/features/models/domain/controllers/family_controller.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/models/domain/models/parent_invite_code_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

class ParentFamilyCubit extends Cubit<ParentFamilyState> {
  static const _familyCacheKey = 'parent_family_cache';
  static const _familyStageKey = 'parent_family_stage';

  final FamilyController _controller;
  final SharedPreferences _prefs;

  ParentFamilyCubit(this._controller, this._prefs)
    : super(_loadInitialState(_prefs));

  static ParentFamilyState _loadInitialState(SharedPreferences prefs) {
    final cachedFamily = _readCachedFamily(prefs);
    final stage = _stageFromString(prefs.getString(_familyStageKey));
    return ParentFamilyState.initial(family: cachedFamily, stage: stage);
  }

  static FamilyModel? _readCachedFamily(SharedPreferences prefs) {
    final raw = prefs.getString(_familyCacheKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return FamilyModel.fromJson(decoded);
      }
      if (decoded is Map) {
        return FamilyModel.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } catch (e) {
      debugPrint('Unable to restore cached family: $e');
    }
    return null;
  }

  static ParentFamilyStage _stageFromString(String? value) {
    switch (value) {
      case 'create':
        return ParentFamilyStage.create;
      case 'join':
        return ParentFamilyStage.join;
      case 'dashboard':
        return ParentFamilyStage.dashboard;
      default:
        return ParentFamilyStage.decision;
    }
  }

  String _stageToString(ParentFamilyStage stage) {
    switch (stage) {
      case ParentFamilyStage.create:
        return 'create';
      case ParentFamilyStage.join:
        return 'join';
      case ParentFamilyStage.dashboard:
        return 'dashboard';
      case ParentFamilyStage.decision:
        return 'decision';
    }
  }

  Future<void> markDecision() async {
    await _persistStage(ParentFamilyStage.decision);
    emit(
      state.copyWith(
        stage: ParentFamilyStage.decision,
        errorMessage: null,
        joinCodeError: null,
        canRetry: false,
        isUnauthorized: false,
        keepFamily: true,
      ),
    );
  }

  Future<void> markCreateFlow() async {
    await _persistStage(ParentFamilyStage.create);
    emit(
      state.copyWith(
        stage: ParentFamilyStage.create,
        errorMessage: null,
        joinCodeError: null,
        canRetry: false,
        isUnauthorized: false,
        keepFamily: true,
      ),
    );
  }

  Future<void> markJoinFlow() async {
    await _persistStage(ParentFamilyStage.join);
    emit(
      state.copyWith(
        stage: ParentFamilyStage.join,
        errorMessage: null,
        joinCodeError: null,
        canRetry: false,
        isUnauthorized: false,
        keepFamily: true,
      ),
    );
  }

  Future<void> reset() async {
    await _prefs.remove(_familyCacheKey);
    await _prefs.remove(_familyStageKey);
    emit(ParentFamilyState.initial());
  }

  Future<void> createFamily({String? name}) async {
    final familyName = (name == null || name.trim().isEmpty)
        ? 'My Family'
        : name.trim();

    await _persistStage(ParentFamilyStage.create);
    emit(
      state.copyWith(
        stage: ParentFamilyStage.create,
        isLoading: true,
        errorMessage: null,
        joinCodeError: null,
        canRetry: false,
        isUnauthorized: false,
        keepFamily: true,
      ),
    );

    final createResult = await _controller.createFamily(
      familyName,
      _timezoneLabel(),
    );

    await createResult.fold(
      (failure) async {
        if (_isFamilyAlreadyExistsFailure(failure)) {
          await _refreshCurrentFamily(afterFlow: ParentFamilyStage.create);
          return;
        }
        await _handleFailure(failure, stage: ParentFamilyStage.create);
      },
      (family) async {
        await _saveFamily(family);
        await _refreshCurrentFamily(afterFlow: ParentFamilyStage.create);
      },
    );
  }

  Future<void> joinFamily(String inviteCode) async {
    final code = inviteCode.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (code.isEmpty) {
      emit(
        state.copyWith(
          stage: ParentFamilyStage.join,
          isLoading: false,
          joinCodeError: 'Invite code is required.',
          errorMessage: null,
          canRetry: false,
          keepFamily: true,
        ),
      );
      return;
    }
    if (code.length < 4 || code.length > 16) {
      emit(
        state.copyWith(
          stage: ParentFamilyStage.join,
          isLoading: false,
          joinCodeError: 'Invalid invite code format. Must be 4-16 characters.',
          errorMessage: null,
          canRetry: false,
          keepFamily: true,
        ),
      );
      return;
    }

    await _persistStage(ParentFamilyStage.join);
    emit(
      state.copyWith(
        stage: ParentFamilyStage.join,
        isLoading: true,
        errorMessage: null,
        joinCodeError: null,
        canRetry: false,
        isUnauthorized: false,
        keepFamily: true,
      ),
    );

    final joinResult = await _controller.joinFamily(code);

    await joinResult.fold(
      (failure) async => _handleFailure(failure, stage: ParentFamilyStage.join),
      (family) async {
        await _saveFamily(family);
        await _refreshCurrentFamily(afterFlow: ParentFamilyStage.join);
      },
    );
  }

  Future<ParentInviteCodeModel?> createParentInviteCode() async {
    emit(
      state.copyWith(
        isParentInviteCodeLoading: true,
        errorMessage: null,
        canRetry: false,
        keepFamily: true,
      ),
    );

    final result = await _controller.createParentInviteCode();
    ParentInviteCodeModel? inviteCode;
    await result.fold(
      (failure) async {
        if (failure is UnauthorizedFailure) {
          await _signOutAndRedirect(failure.message);
          return;
        }
        emit(
          state.copyWith(
            isParentInviteCodeLoading: false,
            errorMessage: failure.message,
            canRetry: false,
            keepFamily: true,
          ),
        );
      },
      (code) async {
        inviteCode = code;
        emit(
          state.copyWith(
            isParentInviteCodeLoading: false,
            errorMessage: null,
            canRetry: false,
            keepFamily: true,
          ),
        );
      },
    );
    return inviteCode;
  }

  Future<ChildInviteCodeModel?> createChildInviteCode(String childId) async {
    if (childId.trim().isEmpty) return null;

    emit(
      state.copyWith(
        issuingChildInviteCodeForId: childId,
        errorMessage: null,
        canRetry: false,
        keepFamily: true,
      ),
    );

    final result = await _controller.createChildInviteCode(childId);
    ChildInviteCodeModel? inviteCode;
    await result.fold(
      (failure) async {
        if (failure is UnauthorizedFailure) {
          await _signOutAndRedirect(failure.message);
          return;
        }
        emit(
          state.copyWith(
            issuingChildInviteCodeForId: null,
            errorMessage: failure.message,
            canRetry: false,
            keepFamily: true,
          ),
        );
      },
      (code) async {
        inviteCode = code;
        emit(
          state.copyWith(
            issuingChildInviteCodeForId: null,
            errorMessage: null,
            canRetry: false,
            keepFamily: true,
          ),
        );
      },
    );
    return inviteCode;
  }

  Future<Failure?> createChild({
    required String nickname,
    required int age,
    String? gender,
  }) async {
    final result = await _controller.createChild(
      nickname: nickname,
      age: age,
      gender: gender,
    );

    Failure? capturedFailure;
    await result.fold(
      (failure) async {
        if (failure is UnauthorizedFailure) {
          await _signOutAndRedirect(failure.message);
          capturedFailure = failure;
          return;
        }

        capturedFailure = failure;
      },
      (_) async {
        capturedFailure = null;
      },
    );

    return capturedFailure;
  }

  Future<Failure?> updateChild(
    String childId, {
    String? nickname,
    int? age,
    String? gender,
  }) async {
    final result = await _controller.updateChild(
      childId,
      nickname: nickname,
      age: age,
      gender: gender,
    );

    Failure? capturedFailure;
    await result.fold(
      (failure) async {
        if (failure is UnauthorizedFailure) {
          await _signOutAndRedirect(failure.message);
          capturedFailure = failure;
          return;
        }
        capturedFailure = failure;
      },
      (_) async {
        capturedFailure = null;
      },
    );

    return capturedFailure;
  }

  Future<void> loadCurrentFamily({bool refresh = false}) async {
    if (!refresh && state.family == null) {
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        joinCodeError: null,
        canRetry: false,
        isUnauthorized: false,
        keepFamily: true,
      ),
    );

    final result = await _controller.getCurrentFamily();
    await result.fold((failure) => _handleLoadFailure(failure), (family) async {
      await _saveFamily(family);
      emit(
        state.copyWith(
          stage: ParentFamilyStage.dashboard,
          isLoading: false,
          family: family,
          errorMessage: null,
          joinCodeError: null,
          canRetry: false,
          isUnauthorized: false,
        ),
      );
    });
  }

  Future<void> retry() async {
    if (state.stage == ParentFamilyStage.dashboard || state.family != null) {
      await loadCurrentFamily(refresh: true);
      return;
    }

    if (state.stage == ParentFamilyStage.join) {
      await markJoinFlow();
      return;
    }

    await markCreateFlow();
  }

  Future<void> _refreshCurrentFamily({
    required ParentFamilyStage afterFlow,
  }) async {
    final result = await _controller.getCurrentFamily();
    await result.fold(
      (failure) async {
        await _handleFailure(failure, stage: afterFlow, keepStagedFamily: true);
      },
      (family) async {
        await _saveFamily(family);
        await _persistStage(ParentFamilyStage.dashboard);
        emit(
          state.copyWith(
            stage: ParentFamilyStage.dashboard,
            isLoading: false,
            family: family,
            errorMessage: null,
            joinCodeError: null,
            canRetry: false,
            isUnauthorized: false,
          ),
        );
      },
    );
  }

  Future<void> _handleLoadFailure(Failure failure) async {
    if (failure is UnauthorizedFailure) {
      await _signOutAndRedirect(failure.message);
      return;
    }

    if (failure is NotFoundFailure && state.family == null) {
      await _persistStage(ParentFamilyStage.decision);
      emit(ParentFamilyState.initial(stage: ParentFamilyStage.decision));
      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        canRetry: true,
        isUnauthorized: false,
        keepFamily: true,
      ),
    );
  }

  Future<void> _handleFailure(
    Failure failure, {
    required ParentFamilyStage stage,
    bool keepStagedFamily = false,
  }) async {
    if (failure is UnauthorizedFailure) {
      await _signOutAndRedirect(failure.message);
      return;
    }

    final inlineMessage = failure is ValidationFailure ? failure.message : null;

    emit(
      state.copyWith(
        stage: stage,
        isLoading: false,
        errorMessage: inlineMessage ?? failure.message,
        joinCodeError: stage == ParentFamilyStage.join
            ? (inlineMessage ?? failure.message)
            : null,
        canRetry: true,
        isUnauthorized: false,
        keepFamily: keepStagedFamily,
      ),
    );
  }

  Future<void> _signOutAndRedirect(String message) async {
    await _prefs.remove(_familyCacheKey);
    await _prefs.remove(_familyStageKey);
    await getIt<AuthSessionCubit>().forceSignOut(message);
    emit(ParentFamilyState.initial());
  }

  Future<void> _saveFamily(FamilyModel family) async {
    await _prefs.setString(_familyCacheKey, jsonEncode(family.toJson()));
  }

  Future<void> _persistStage(ParentFamilyStage stage) async {
    await _prefs.setString(_familyStageKey, _stageToString(stage));
  }

  bool _isFamilyAlreadyExistsFailure(Failure failure) {
    if (failure is! ValidationFailure) return false;
    final message = failure.message.toLowerCase();
    return message.contains('family already exists');
  }

  String _timezoneLabel() {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }
}
