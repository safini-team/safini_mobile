import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
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
    final initials = widget.child.nickname.isNotEmpty
        ? widget.child.nickname[0].toUpperCase()
        : 'C';

    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Edit Child',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Child avatar + name chip in header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.child.nickname,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Age ${widget.child.age}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24,
                  32,
                  24,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Edit profile',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Update your child\'s information below.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _FormCard(
                        child: TextFormField(
                          controller: _nicknameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            context,
                            label: 'Nickname',
                            hint: 'e.g. Alex',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Nickname is required.';
                            if (v.length > 80) {
                              return 'Nickname must be at most 80 characters.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FormCard(
                        child: TextFormField(
                          controller: _ageController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            context,
                            label: 'Age',
                            hint: '0 – 18',
                            icon: Icons.cake_outlined,
                          ),
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) return 'Age is required.';
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
                      ),
                      const SizedBox(height: 14),
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.wc_outlined,
                                  size: 20,
                                  color: context.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Gender (optional)',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: _GenderOption.values.map((option) {
                                final selected = _selectedGender == option;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedGender =
                                          selected ? null : option;
                                    }),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? context.colorScheme.primary
                                            : context.colorScheme.primary
                                                .withValues(alpha: 0.07),
                                        borderRadius:
                                            BorderRadius.circular(24),
                                        border: Border.all(
                                          color: selected
                                              ? context.colorScheme.primary
                                              : context.colorScheme.primary
                                                  .withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Text(
                                        option.label,
                                        style: context.textTheme.labelLarge
                                            ?.copyWith(
                                          color: selected
                                              ? Colors.white
                                              : context.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: context.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: context.colorScheme.primary, size: 20),
      filled: true,
      fillColor: context.colorScheme.primary.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: context.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: context.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colorScheme.error, width: 1.5),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nickname = _nicknameController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final gender = _selectedGender?.apiValue;

    final changedNickname =
        nickname != widget.child.nickname ? nickname : null;
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
      AppSnackBar.success(context, 'Child profile updated successfully.');
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
    if (failure is ValidationFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    return 'Unable to update child right now. Please try again.';
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

enum _GenderOption {
  boy('Boy', 'boy'),
  girl('Girl', 'girl'),
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
