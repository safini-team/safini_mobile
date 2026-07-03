import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

class ParentProfilePage extends StatefulWidget {
  final ParentSummaryModel parentModel;

  const ParentProfilePage({super.key, required this.parentModel});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  bool _isRemoving = false;

  Future<void> _removeParent() async {
    final s = S.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.removeParentConfirmTitle),
        content: Text(s.removeParentConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(s.removeParent),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRemoving = true);
    final failure = await context
        .read<ParentFamilyCubit>()
        .removeParent(widget.parentModel.userId);

    if (!mounted) return;
    setState(() => _isRemoving = false);

    if (failure != null) {
      AppSnackBar.error(context, failure.message);
    } else {
      context.read<ParentFamilyCubit>().loadCurrentFamily(refresh: true);
      context.router.maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = widget.parentModel;
    final initials =
        p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : 'P';

    return Scaffold(
      appBar: AppBar(
        title: Text(s.parentAccount),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: context.colorScheme.primaryContainer,
              child: Text(
                initials,
                style: context.textTheme.displayMedium?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _InfoTile(label: s.name, value: p.displayName),
          const SizedBox(height: 16),
          _InfoTile(
            label: 'Role', // Not localized strictly but okay
            value: p.role == 'admin' ? s.admin : p.role,
          ),
          if (p.email != null) ...[
            const SizedBox(height: 16),
            _InfoTile(label: 'Email', value: p.email!),
          ],
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isRemoving ? null : _removeParent,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isRemoving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : Text(s.removeParent),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
