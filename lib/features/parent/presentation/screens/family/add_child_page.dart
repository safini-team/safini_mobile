import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _ageController;
  _GenderOption? _selectedGender;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _ageController = TextEditingController();
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
      appBar: AppBar(title: const Text('Add Child')),
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
                Text(
                  'Create a child profile',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill out the details below to add a child to your family.',
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nicknameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nickname',
                    hintText: 'e.g. Alex',
                  ),
                  validator: (value) {
                    final nickname = value?.trim() ?? '';
                    if (nickname.isEmpty) {
                      return 'Nickname is required.';
                    }
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
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    hintText: '0 - 18',
                  ),
                  validator: (value) {
                    final input = value?.trim() ?? '';
                    if (input.isEmpty) {
                      return 'Age is required.';
                    }
                    final parsed = int.tryParse(input);
                    if (parsed == null) {
                      return 'Age must be an integer.';
                    }
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
                      : const Text('Create Child'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final age = int.parse(_ageController.text.trim());
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final failure = await context.read<ParentFamilyCubit>().createChild(
      nickname: _nicknameController.text.trim(),
      age: age,
      gender: _selectedGender?.apiValue,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (failure == null) {
      context.router.pop(true);
      return;
    }

    setState(() {
      _errorMessage = _mapFailureMessage(failure);
    });
  }

  String _mapFailureMessage(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Session expired. Please sign in again.';
    }
    if (failure is ValidationFailure) {
      return failure.message;
    }
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Unable to create child right now. Please try again.';
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
}
