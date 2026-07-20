import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/widgets/skeleton/skeleton_loader.dart';
import 'package:safini/features/common/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
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

  Future<void> _deleteAccount() async {
    final s = S.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteAccountConfirmTitle),
        content: Text(s.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(s.deleteAccount),
          ),
        ],
      ),
    );

    if (confirm != true) return;

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

    try {
      final response = await http
          .delete(
            Uri.parse('${SupabaseConfig.apiBaseUrl}/v1/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _isSaving = false;
          _errorMessage = _messageForStatus(response.statusCode);
        });
        return;
      }

      if (!mounted) return;
      await getIt<AuthSessionCubit>().forceSignOut('Account deleted');
    } catch (_) {
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
      appBar: AppBar(
        title: Text(s.editProfile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: _isLoading
          ? const Skeleton(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SkeletonBox(width: 80, height: 14),
                    SizedBox(height: 10),
                    SkeletonBox(height: 48, radius: 12),
                    SizedBox(height: 24),
                    SkeletonBox(width: 80, height: 14),
                    SizedBox(height: 10),
                    SkeletonBox(height: 48, radius: 12),
                    SizedBox(height: 32),
                    SkeletonBox(height: 52, radius: 26),
                    SizedBox(height: 12),
                    SkeletonBox(height: 52, radius: 26),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _nameController,
                      maxLength: 60,
                      decoration: InputDecoration(labelText: s.name),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return '${s.name} is required.';
                        if (text.length > 60) return 'Max 60 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _surnameController,
                      maxLength: 60,
                      decoration: InputDecoration(labelText: s.surname),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.length > 60) return 'Max 60 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(s.save),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => context.router.maybePop(),
                      child: Text(s.cancel),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton(
                      onPressed: _isSaving ? null : _deleteAccount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(s.deleteAccount),
                    ),
                  ],
                ),
                ),
              ),
            ),
    );
  }
}
