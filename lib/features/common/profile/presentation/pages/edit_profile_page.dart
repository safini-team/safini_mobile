import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _initialDisplayName;
  String? _initialBio;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
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
      _initialBio = profile.bio ?? '';
      _displayNameController.text = _initialDisplayName!;
      _bioController.text = _initialBio!;

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
    final displayName = _displayNameController.text.trim();
    final bio = _bioController.text.trim();
    if (displayName != (_initialDisplayName ?? '')) {
      changedPayload['display_name'] = displayName;
    }
    if (bio != (_initialBio ?? '')) {
      changedPayload['bio'] = bio;
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
      context.router.maybePop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      controller: _displayNameController,
                      maxLength: 120,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Name is required.';
                        if (text.length > 120) return 'Max 120 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 6,
                      maxLength: 2000,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.length > 2000) return 'Max 2000 characters.';
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
                          : const Text('Save'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => context.router.maybePop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
