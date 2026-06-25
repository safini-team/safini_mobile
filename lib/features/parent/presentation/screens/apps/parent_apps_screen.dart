import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ParentAppsScreen extends StatelessWidget {
  const ParentAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) => getIt<ParentAppsCubit>()..loadAppLimits(),
      child: Scaffold(
        backgroundColor: context.colorScheme.primary.withValues(alpha: 0.9),
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colorScheme.primary.withValues(alpha: 0.8),
                    context.colorScheme.primary,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.appLimits,
                        style: context.textTheme.displaySmall?.copyWith(
                          color: context.colorScheme.onPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.appLimitsSubtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Content ─────────────────────────────────────────
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -1), // Fix sub-pixel white line gap
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    child: BlocBuilder<ParentAppsCubit, ParentAppsState>(
                      builder: (context, state) {
                    if (state is ParentAppsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B46FF),
                        ),
                      );
                    }

                    if (state is ParentAppsLoaded) {
                      final cubit = context.read<ParentAppsCubit>();
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(32, 28, 32, 80),
                        children: [
                          if (state.appLimits.isNotEmpty) ...[
                            // Tip Banner
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: context.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_rounded,
                                    color: Color(0xFFFF9500),
                                    size: 26,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      s.kidsEarnTimeCoins,
                                      style: context.textTheme.titleSmall?.copyWith(
                                        color: context.colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...state.appLimits.map(
                              (app) => ParentAppLimitTile(
                                appName: app['name'],
                                usedMinutes: app['used'],
                                limitMinutes: app['limit'],
                                iconPath: app['icon'],
                                isEnabled: app['isEnabled'] ?? true,
                                onToggle: (val) => cubit.toggleApp(
                                  app['name'] as String,
                                  val,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ] else ...[
                            const SizedBox(height: 40),
                            Icon(
                              Icons.smartphone_rounded,
                              size: 72,
                              color: context.colorScheme.primary.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              s.appLimitsSubtitle,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                          ],
                          // Add Another App Button
                          GestureDetector(
                            onTap: () => _showAddAppSheet(context, cubit),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.colorScheme.primary.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: context.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        s.addAnotherApp,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(
                                              color: context.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddAppSheet(BuildContext context, ParentAppsCubit cubit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddAppSheet(cubit: cubit),
  );
}

class _AddAppSheet extends StatefulWidget {
  final ParentAppsCubit cubit;
  const _AddAppSheet({required this.cubit});

  @override
  State<_AddAppSheet> createState() => _AddAppSheetState();
}

class _AddAppSheetState extends State<_AddAppSheet> {
  final _nameController = TextEditingController();
  int _limitMinutes = 60;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Required');
      return;
    }
    widget.cubit.addApp(name, _limitMinutes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.addAnotherApp,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                labelText: 'App name',
                hintText: 'YouTube, TikTok…',
                prefixIcon: Icon(
                  Icons.smartphone_rounded,
                  color: context.colorScheme.primary,
                  size: 20,
                ),
                errorText: _error,
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
                  borderSide: BorderSide(
                    color: context.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.dailyLimit,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$_limitMinutes ${s.minutes}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Slider(
              value: _limitMinutes.toDouble(),
              min: 5,
              max: 240,
              divisions: 47,
              activeColor: context.colorScheme.primary,
              onChanged: (val) => setState(() => _limitMinutes = val.round()),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submit,
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }
}
