import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_view.dart';

/// What the caller should do after the sheet closes.
enum FamilySheetAction { none, editProfile, editChild, removeParent }

/// The artboard's parent sheet: avatar, name and email, a details panel, then
/// the invite-code button that reveals the deep-purple code panel in place.
///
/// The artboard's "Can approve tasks" toggle is left out - the API has no
/// per-parent permission flag, and a switch that silently does nothing is worse
/// than no switch.
Future<FamilySheetAction?> showParentSheet(
  BuildContext context, {
  required FamilyParentRow parent,
  required String role,
  required String since,
  required Future<String?> Function() onCreateCode,
  bool canRemove = false,
}) {
  return showDsSheet<FamilySheetAction>(
    context: context,
    builder: (context) => _ParentSheet(
      parent: parent,
      role: role,
      since: since,
      onCreateCode: onCreateCode,
      canRemove: canRemove,
    ),
  );
}

class _ParentSheet extends StatefulWidget {
  const _ParentSheet({
    required this.parent,
    required this.role,
    required this.since,
    required this.onCreateCode,
    required this.canRemove,
  });

  final FamilyParentRow parent;
  final String role;
  final String since;
  final Future<String?> Function() onCreateCode;
  final bool canRemove;

  @override
  State<_ParentSheet> createState() => _ParentSheetState();
}

class _ParentSheetState extends State<_ParentSheet> {
  String? _code;
  bool _busy = false;

  Future<void> _makeCode() async {
    if (_code != null) {
      Navigator.of(context).pop(FamilySheetAction.none);
      return;
    }
    setState(() => _busy = true);
    final code = await widget.onCreateCode();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _code = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            DsInitialAvatar(
              name: widget.parent.name,
              color: widget.parent.color,
              imageUrl: widget.parent.avatarUrl,
              size: 56,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.parent.name, style: AppText.title4),
                  const SizedBox(height: 3),
                  Text(
                    widget.parent.subtitle,
                    style: AppText.meta.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DsSheetPanel(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          radius: AppRadius.card,
          child: Column(
            children: [
              _DetailRow(label: s.roleLabel, value: widget.role),
              const DsDivider(),
              _DetailRow(label: s.inTheFamilySince, value: widget.since),
            ],
          ),
        ),
        if (_code != null) ...[
          const SizedBox(height: 12),
          DsCodePanel(
            caption: s.inviteCodeValid,
            code: _code!,
            footnote: s.theyInstallSafini,
          ),
        ],
        const SizedBox(height: 14),
        DsPrimaryButton(
          label: _code != null ? s.doneAction : s.createAnInviteCode,
          busy: _busy,
          onTap: _makeCode,
        ),
        if (widget.parent.isYou) ...[
          const SizedBox(height: 9),
          DsPrimaryButton.secondary(
            label: s.editMyProfile,
            onTap: () =>
                Navigator.of(context).pop(FamilySheetAction.editProfile),
          ),
        ],
        if (widget.canRemove) ...[
          const SizedBox(height: 4),
          DsDestructiveButton(
            label: s.removeFromFamily,
            filled: false,
            onTap: () =>
                Navigator.of(context).pop(FamilySheetAction.removeParent),
          ),
        ],
      ],
    );
  }
}

/// The artboard's child sheet: avatar and status, stat tiles, a details panel,
/// then the re-connect code and the edit action.
Future<FamilySheetAction?> showChildSheet(
  BuildContext context, {
  required FamilyChildCard child,
  required Future<String?> Function() onCreateCode,
}) {
  return showDsSheet<FamilySheetAction>(
    context: context,
    builder: (context) => _ChildSheet(child: child, onCreateCode: onCreateCode),
  );
}

class _ChildSheet extends StatefulWidget {
  const _ChildSheet({required this.child, required this.onCreateCode});

  final FamilyChildCard child;
  final Future<String?> Function() onCreateCode;

  @override
  State<_ChildSheet> createState() => _ChildSheetState();
}

class _ChildSheetState extends State<_ChildSheet> {
  String? _code;
  bool _busy = false;

  Future<void> _makeCode() async {
    if (_code != null) {
      Navigator.of(context).pop(FamilySheetAction.none);
      return;
    }
    setState(() => _busy = true);
    final code = await widget.onCreateCode();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _code = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final child = widget.child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            DsInitialAvatar(name: child.name, color: child.color, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(child.name, style: AppText.title4),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      DsStatusDot(online: child.paired),
                      const SizedBox(width: 6),
                      Text(
                        child.status(s),
                        style: AppText.meta.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DsSheetPanel(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          radius: AppRadius.card,
          child: Column(
            children: [
              _DetailRow(
                label: s.ageFieldLabel,
                value: child.age > 0 ? s.yearsOld(child.age) : s.notSet,
              ),
              const DsDivider(),
              _DetailRow(label: s.levelShort, value: s.levelValue(child.level)),
              const DsDivider(),
              _DetailRow(label: s.statCoins, value: '${child.coins}'),
            ],
          ),
        ),
        if (_code != null) ...[
          const SizedBox(height: 12),
          DsCodePanel(
            caption: s.reconnectCodeValid,
            code: _code!,
            footnote: s.typeItOnPhone(child.name),
          ),
        ],
        const SizedBox(height: 14),
        DsPrimaryButton(
          label: _code != null ? s.doneAction : s.reconnectWithCode,
          busy: _busy,
          onTap: _makeCode,
        ),
        const SizedBox(height: 9),
        DsPrimaryButton.secondary(
          label: s.editName(child.name),
          onTap: () => Navigator.of(context).pop(FamilySheetAction.editChild),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppText.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// The deep-purple code panel from the pairing artboards: caption, the code in
/// wide tabular figures, then a copy affordance.
class DsCodePanel extends StatelessWidget {
  const DsCodePanel({
    super.key,
    required this.caption,
    required this.code,
    this.footnote,
    this.codeSize = 34,
  });

  final String caption;
  final String code;
  final String? footnote;
  final double codeSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.deep,
      ),
      child: Column(
        children: [
          Text(
            caption.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppText.overline.copyWith(
              letterSpacing: 0.96,
              color: const Color(0x8CFFFFFF),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            code,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: codeSize,
              fontWeight: FontWeight.w700,
              letterSpacing: codeSize * 0.08,
              height: 1.1,
              color: AppColors.textOnPrimary,
              fontFeatures: AppText.tabular,
            ),
          ),
          const SizedBox(height: 14),
          Pressable(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              DsToast.show(context, S.of(context).codeCopied);
            },
            scale: 0.97,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0x24FFFFFF),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcons.copy(),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).copyCode,
                    style: AppText.body.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: 12),
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: AppText.metaSm.copyWith(color: const Color(0x9EFFFFFF)),
            ),
          ],
        ],
      ),
    );
  }
}
