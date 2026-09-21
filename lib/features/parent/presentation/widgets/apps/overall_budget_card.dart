import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// Both tabs render the same server snapshot. Unknown usage is never zero.
class OverallBudgetSummary extends StatelessWidget {
  const OverallBudgetSummary({
    super.key,
    required this.limitMinutes,
    required this.usedMinutes,
    required this.remainingMinutes,
    required this.usageAvailable,
    this.configurationAvailable = true,
    this.nextResetAt,
    this.showTitle = true,
  });
  final int? limitMinutes;
  final int usedMinutes;
  final int? remainingMinutes;
  final bool usageAvailable;
  final bool configurationAvailable;
  final DateTime? nextResetAt;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (!configurationAvailable) {
      return Text(s.budgetUnavailable, style: AppText.meta);
    }
    final limit = limitMinutes;
    final reset = nextResetAt;
    final paused =
        limit == 0 ||
        (limit != null && usageAvailable && remainingMinutes == 0);
    final resetLabel = reset == null
        ? null
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).add_Hm().format(reset.toLocal());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Text(s.overallDailyBudget, style: AppText.overline),
          const SizedBox(height: 8),
        ],
        Text(
          limit == null
              ? s.noOverallDailyBudget
              : limit == 0
              ? s.budgetNoFreeTime
              : formatHm(s, limit),
          style: AppText.headline,
        ),
        const SizedBox(height: 8),
        Text(s.budgetScope, style: AppText.meta),
        const SizedBox(height: 14),
        if (usageAvailable) ...[
          _BudgetValue(
            label: s.budgetUsedToday,
            value: formatHm(s, usedMinutes),
          ),
          if (limit != null && remainingMinutes != null)
            _BudgetValue(
              label: s.budgetRemaining,
              value: formatHm(s, remainingMinutes!),
            ),
        ] else
          Text(s.budgetUsageUnknown, style: AppText.meta),
        if (paused) ...[
          const SizedBox(height: 10),
          Text(
            resetLabel == null
                ? s.budgetPaused
                : s.budgetPausedUntil(resetLabel),
            style: AppText.meta,
          ),
        ] else if (limit != null && resetLabel != null) ...[
          const SizedBox(height: 8),
          Text(s.budgetResetAt(resetLabel), style: AppText.meta),
        ],
      ],
    );
  }
}

class _BudgetValue extends StatelessWidget {
  const _BudgetValue({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppText.meta)),
        const SizedBox(width: 12),
        Text(value, style: AppText.rowTitleStrong),
      ],
    ),
  );
}

class OverallBudgetCard extends StatelessWidget {
  const OverallBudgetCard({
    super.key,
    required this.limitMinutes,
    required this.usedMinutes,
    required this.remainingMinutes,
    required this.usageAvailable,
    this.configurationAvailable = true,
    this.nextResetAt,
    this.onSave,
  });
  final int? limitMinutes;
  final int usedMinutes;
  final int? remainingMinutes;
  final bool usageAvailable;
  final bool configurationAvailable;
  final DateTime? nextResetAt;
  final Future<String?> Function(int?)? onSave;

  Future<void> _edit(BuildContext context, bool enabled) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _BudgetEditor(
      initialMinutes: limitMinutes ?? 60,
      enabled: enabled,
      onSave: onSave!,
    ),
  );

  @override
  Widget build(BuildContext context) => DsCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onSave != null && configurationAvailable) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).overallDailyBudget,
                  style: AppText.overline,
                ),
              ),
              const SizedBox(width: 12),
              Material(
                type: MaterialType.transparency,
                child: Semantics(
                  label: S.of(context).overallDailyBudget,
                  child: Switch.adaptive(
                    value: limitMinutes != null,
                    onChanged: (enabled) => _edit(context, enabled),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        OverallBudgetSummary(
          showTitle: onSave == null || !configurationAvailable,
          limitMinutes: limitMinutes,
          usedMinutes: usedMinutes,
          remainingMinutes: remainingMinutes,
          usageAvailable: usageAvailable,
          configurationAvailable: configurationAvailable,
          nextResetAt: nextResetAt,
        ),
        if (onSave != null &&
            configurationAvailable &&
            limitMinutes != null) ...[
          const SizedBox(height: 12),
          DsInlineButton(
            label: S.of(context).edit,
            onTap: () => _edit(context, true),
          ),
        ],
      ],
    ),
  );
}

class _BudgetEditor extends StatefulWidget {
  const _BudgetEditor({
    required this.initialMinutes,
    required this.enabled,
    required this.onSave,
  });
  final int initialMinutes;
  final bool enabled;
  final Future<String?> Function(int?) onSave;
  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  late final _minutes = TextEditingController(text: '${widget.initialMinutes}');
  late bool _enabled = widget.enabled;
  final _form = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.onSave(
      _enabled ? int.parse(_minutes.text) : null,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(s.overallDailyBudget),
        content: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.budgetEnabled),
                  value: _enabled,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _enabled = value),
                ),
                if (_enabled) ...[
                  TextFormField(
                    controller: _minutes,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: s.minutes),
                    validator: (value) {
                      final minutes = int.tryParse(value ?? '');
                      return minutes == null || minutes < 0 || minutes > 1440
                          ? s.budgetMinutesError
                          : null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(s.budgetMinutesHint),
                ],
                const SizedBox(height: 16),
                Text(_enabled ? s.budgetExplanation : s.budgetOffExplanation),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.save),
          ),
        ],
      ),
    );
  }
}
