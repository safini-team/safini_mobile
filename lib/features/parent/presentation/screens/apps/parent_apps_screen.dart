import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
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
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(32, 28, 32, 80),
                        children: [
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
                              onToggle: (val) => context
                                  .read<ParentAppsCubit>()
                                  .toggleApp(app['slug'] as String, val),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Add Another App Button
                          GestureDetector(
                            onTap: () => _showAddAppSheet(
                              context,
                              context.read<ParentAppsCubit>(),
                            ),
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
                                            color: const Color(0xFF8100D1),
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

/// Controlled apps the backend accepts. There is no catalog endpoint, so this
/// list is maintained client-side; add new entries here as the backend seeds
/// more controlled apps.
const List<({String slug, String name})> _knownApps = [
  (slug: 'youtube-kids', name: 'YouTube Kids'),
  (slug: 'roblox', name: 'Roblox'),
  (slug: 'brawl-stars', name: 'Brawl Stars'),
  (slug: 'minecraft', name: 'Minecraft'),
];

Future<void> _showAddAppSheet(BuildContext context, ParentAppsCubit cubit) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _AddAppSheet(cubit: cubit, addedSlugs: cubit.addedSlugs),
  );
}

class _AddAppSheet extends StatefulWidget {
  final ParentAppsCubit cubit;
  final Set<String> addedSlugs;

  const _AddAppSheet({required this.cubit, required this.addedSlugs});

  @override
  State<_AddAppSheet> createState() => _AddAppSheetState();
}

class _AddAppSheetState extends State<_AddAppSheet> {
  final _limit = TextEditingController(text: '60');
  final _cost = TextEditingController(text: '100');
  final _reward = TextEditingController(text: '30');
  bool _saving = false;
  String? _selectedSlug;

  late final List<({String slug, String name})> _available = _knownApps
      .where((a) => !widget.addedSlugs.contains(a.slug))
      .toList();

  @override
  void initState() {
    super.initState();
    if (_available.isNotEmpty) _selectedSlug = _available.first.slug;
  }

  @override
  void dispose() {
    _limit.dispose();
    _cost.dispose();
    _reward.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final slug = _selectedSlug;
    if (slug == null) return;
    final app = _available.firstWhere((a) => a.slug == slug);

    setState(() => _saving = true);
    final error = await widget.cubit.addApp(
      slug: app.slug,
      name: app.name,
      dailyLimitMinutes: int.tryParse(_limit.text.trim()) ?? 60,
      redeemCoinCost: int.tryParse(_cost.text.trim()) ?? 100,
      redeemRewardMinutes: int.tryParse(_reward.text.trim()) ?? 30,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppSnackBar.error(context, error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Добавить приложение',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ребёнок сможет обменивать монеты на время в этом приложении.',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          if (_available.isEmpty) ...[
            Text(
              'Все доступные приложения уже добавлены.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            Text(
              'Приложение',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedSlug,
                  items: _available
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.slug,
                          child: Text(a.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSlug = v),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _limit,
                    label: 'Лимит (мин)',
                    number: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _reward,
                    label: 'Награда (мин)',
                    number: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _cost,
              label: 'Стоимость (монет)',
              number: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Добавить',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool number;

  const _Field({
    required this.controller,
    required this.label,
    this.number = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
