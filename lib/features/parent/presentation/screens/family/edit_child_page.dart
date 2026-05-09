import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

class EditChildPage extends StatefulWidget {
  final ChildSummaryModel child;

  const EditChildPage({super.key, required this.child});

  @override
  State<EditChildPage> createState() => _EditChildPageState();
}

class _EditChildPageState extends State<EditChildPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _ageController;

  _GenderOption? _selectedGender;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.child.nickname);
    _ageController = TextEditingController(text: widget.child.age.toString());
    _selectedGender = _GenderOption.fromApiValue(widget.child.gender);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Child')),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nicknameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Nickname'),
                  validator: (value) {
                    final nickname = value?.trim() ?? '';
                    if (nickname.isEmpty) return 'Nickname is required.';
                    if (nickname.length > 80) {
                      return 'Nickname must be at most 80 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _ageController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                  validator: (value) {
                    final input = value?.trim() ?? '';
                    if (input.isEmpty) return 'Age is required.';
                    final parsed = int.tryParse(input);
                    if (parsed == null) return 'Age must be an integer.';
                    if (parsed < 0 || parsed > 18) {
                      return 'Age must be between 0 and 18.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _openGenderSelector,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Gender (optional)',
                      hintText: 'Select gender',
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      helperText: _selectedGender == null
                          ? 'No selection'
                          : 'Selected: ${_selectedGender!.label}',
                    ),
                    child: Text(
                      _selectedGender?.label ?? 'Tap to select',
                      style: _selectedGender == null
                          ? context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            )
                          : context.textTheme.bodyMedium,
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: context.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nickname = _nicknameController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final gender = _selectedGender?.apiValue;

    final changedNickname = nickname != widget.child.nickname ? nickname : null;
    final changedAge = age != widget.child.age ? age : null;
    final changedGender =
        gender !=
            (widget.child.gender?.trim().isEmpty ?? true
                ? null
                : widget.child.gender!.trim())
        ? gender
        : null;

    if (changedNickname == null &&
        changedAge == null &&
        changedGender == null) {
      if (mounted) Navigator.of(context).pop(false);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final failure = await context.read<ParentFamilyCubit>().updateChild(
      widget.child.id,
      nickname: changedNickname,
      age: changedAge,
      gender: changedGender,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (failure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child profile updated successfully.')),
      );
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _errorMessage = _mapFailureMessage(failure);
    });
  }

  String _mapFailureMessage(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Invalid or expired token. Please sign in again.';
    }
    if (failure is ValidationFailure) {
      return failure.message;
    }
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Unable to update child right now. Please try again.';
  }

  Future<void> _openGenderSelector() async {
    final selected = await showDialog<_GenderOption>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Gender'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _GenderOption.values
                .map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    trailing: _selectedGender == option
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    setState(() {
      _selectedGender = selected;
    });
  }
}

enum _GenderOption {
  girl('Girl', 'girl'),
  boy('Boy', 'boy'),
  other('Other', 'other');

  final String label;
  final String apiValue;

  const _GenderOption(this.label, this.apiValue);

  static _GenderOption? fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final option in _GenderOption.values) {
      if (option.apiValue == normalized) return option;
    }
    return null;
  }
}
