import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/utils/widgets/skeleton/skeleton_loader.dart';
import 'package:safini/features/common/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _initialName;
  String? _initialSurname;
  String? _initialDisplayName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Session expired. Please log in again.';
      });
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse('${SupabaseConfig.apiBaseUrl}/v1/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        setState(() {
          _isLoading = false;
          _errorMessage = _messageForStatus(response.statusCode);
        });
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Service unavailable. Please try again later.';
        });
        return;
      }

      final profile = ProfileModel.fromJson(decoded);
      _initialDisplayName = profile.displayName;
      final parts = _initialDisplayName!.split(' ');
      _initialName = parts.first;
      _initialSurname = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      _nameController.text = _initialName!;
      _surnameController.text = _initialSurname!;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Service unavailable. Please try again later.';
      });
    } on HttpException {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Service unavailable. Please try again later.';
      });
    } on http.ClientException {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Service unavailable. Please try again later.';
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Service unavailable. Please try again later.';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Session expired. Please log in again.';
      });
      return;
    }

    final changedPayload = <String, dynamic>{};
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final newDisplayName = surname.isEmpty ? name : '$name $surname';

    if (newDisplayName != (_initialDisplayName ?? '')) {
      changedPayload['display_name'] = newDisplayName;
    }

    try {
      final response = await http
          .patch(
            Uri.parse('${SupabaseConfig.apiBaseUrl}/v1/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(changedPayload),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        setState(() {
          _isSaving = false;
          _errorMessage = _messageForStatus(response.statusCode);
        });
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Service unavailable. Please try again later.';
        });
        return;
      }

      final updated = ProfileModel.fromJson(decoded);
      if (getIt.isRegistered<ProfileLocalDataSource>()) {
        await getIt<ProfileLocalDataSource>().cache(updated);
      }
      if (!mounted) return;
      context.router.maybePop(true);
    } on SocketException {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Service unavailable. Please try again later.';
      });
    } on HttpException {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Service unavailable. Please try again later.';
      });
    } on http.ClientException {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Service unavailable. Please try again later.';
      });
    }
  }

  String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Session expired. Please log in again.';
      case 409:
        return 'A conflict occurred. Please try again.';
      case 422:
        return 'Invalid input. Check name and bio length.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Service unavailable. Please try again later.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: Column(
        children: [
          DsNavBar(
            title: s.editProfile,
            backLabel: s.settings,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: _isLoading
                ? const Skeleton(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SkeletonBox(height: 116, radius: AppRadius.card),
                          SizedBox(height: 26),
                          SkeletonBox(height: 54, radius: AppRadius.button),
                        ],
                      ),
                    ),
                  )
                : DsScreenEntrance(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(
                          bottom: 40 + MediaQuery.viewInsetsOf(context).bottom,
                        ),
                        children: [
                          DsOverline(s.yourName, top: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.gutter,
                            ),
                            child: DsGroup(
                              radius: AppRadius.card,
                              verticalPadding: 4,
                              shadow: AppShadows.cardSoft,
                              children: [
                                DsFieldRow(
                                  label: s.name,
                                  child: TextFormField(
                                    controller: _nameController,
                                    maxLength: 60,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    cursorColor: AppColors.primary,
                                    style: AppText.rowTitleLg,
                                    decoration: DsFieldRow.decoration(
                                      s.name,
                                    ).copyWith(counterText: ''),
                                    validator: (value) {
                                      final text = value?.trim() ?? '';
                                      if (text.isEmpty) {
                                        return '${s.name} is required.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                DsFieldRow(
                                  label: s.surname,
                                  child: TextFormField(
                                    controller: _surnameController,
                                    maxLength: 60,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    cursorColor: AppColors.primary,
                                    style: AppText.rowTitleLg,
                                    decoration: DsFieldRow.decoration(
                                      s.surname,
                                    ).copyWith(counterText: ''),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                              child: Text(
                                _errorMessage!,
                                style: AppText.metaSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dangerDeep,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.gutter,
                              26,
                              AppSpacing.gutter,
                              0,
                            ),
                            child: DsPrimaryButton(
                              label: s.save,
                              busy: _isSaving,
                              onTap: _save,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
