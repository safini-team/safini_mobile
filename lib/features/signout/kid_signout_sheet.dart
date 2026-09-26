import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/signout/signout_request.dart';

/// The child's sign-out, gated on a parent (SAF-191).
///
/// Asks the server, then waits: a parent approves in their app (seen on the
/// next poll), or reads out the code from their push and the child types it.
/// Returns true only when the child may sign out now. With no child profile
/// behind this account any more there is nothing to protect, so that is a
/// yes straight away.
Future<bool> askParentToSignOut(
  BuildContext context, {
  required SignoutApi api,
  required String childId,
  Duration poll = const Duration(seconds: 3),
}) async {
  final allowed = await showDsSheet<bool>(
    context: context,
    builder: (_) => KidSignoutSheet(api: api, childId: childId, poll: poll),
  );
  return allowed == true;
}

enum _Stage { asking, waiting, denied, ended, failed }

class KidSignoutSheet extends StatefulWidget {
  const KidSignoutSheet({
    super.key,
    required this.api,
    required this.childId,
    this.poll = const Duration(seconds: 3),
  });

  final SignoutApi api;
  final String childId;
  final Duration poll;

  @override
  State<KidSignoutSheet> createState() => _KidSignoutSheetState();
}

class _KidSignoutSheetState extends State<KidSignoutSheet> {
  final _code = TextEditingController();
  _Stage _stage = _Stage.asking;
  SignoutRequest? _request;
  Timer? _timer;
  String? _codeError;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _ask();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    _timer?.cancel();
    setState(() {
      _stage = _Stage.asking;
      _codeError = null;
      _code.clear();
    });
    try {
      final request = await widget.api.ask(widget.childId);
      if (!mounted) return;
      if (request == null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {
        _request = request;
        _stage = _Stage.waiting;
      });
      _timer = Timer.periodic(widget.poll, (_) => _refresh());
    } catch (_) {
      if (mounted) setState(() => _stage = _Stage.failed);
    }
  }

  Future<void> _refresh() async {
    final request = _request;
    if (request == null || _stage != _Stage.waiting) return;
    try {
      _settle(await widget.api.read(widget.childId, request.id));
    } catch (_) {
      // A missed poll is retried on the next tick.
    }
  }

  void _settle(SignoutRequest request) {
    if (!mounted) return;
    if (request.isApproved) {
      _timer?.cancel();
      Navigator.of(context).pop(true);
      return;
    }
    if (request.isPending) return;
    _timer?.cancel();
    setState(() => _stage = request.isDenied ? _Stage.denied : _Stage.ended);
  }

  Future<void> _verify(String code) async {
    final request = _request;
    if (request == null || _checking) return;
    setState(() {
      _checking = true;
      _codeError = null;
    });
    try {
      _settle(await widget.api.verify(widget.childId, request.id, code));
    } on WrongSignoutCode catch (wrong) {
      if (!mounted) return;
      _code.clear();
      if (wrong.locked) {
        _timer?.cancel();
        setState(() => _stage = _Stage.ended);
      } else {
        setState(
          () => _codeError = S.of(context).signoutWrongCode(wrong.attemptsLeft),
        );
      }
    } catch (_) {
      // Answered, replaced or expired meanwhile: the poll says which.
      await _refresh();
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.signoutAskTitle, style: AppText.title3),
        const SizedBox(height: 8),
        ...switch (_stage) {
          _Stage.asking => [
            Text(s.signoutAskBody, style: AppText.bodyRegular),
            const SizedBox(height: 22),
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ],
          _Stage.waiting => [
            Text(s.signoutAskBody, style: AppText.bodyRegular),
            const SizedBox(height: 18),
            Text(s.signoutWaiting, style: AppText.meta),
            const SizedBox(height: 22),
            Text(s.signoutTypeCode, style: AppText.meta),
            const SizedBox(height: 10),
            DsCodeField(
              controller: _code,
              digits: true,
              autofocus: false,
              enabled: !_checking,
              onCompleted: _verify,
            ),
            if (_codeError != null) ...[
              const SizedBox(height: 10),
              Text(
                _codeError!,
                style: AppText.meta.copyWith(color: AppColors.danger),
              ),
            ],
          ],
          _Stage.denied => [Text(s.signoutDenied, style: AppText.bodyRegular)],
          _Stage.ended => [Text(s.signoutEnded, style: AppText.bodyRegular)],
          _Stage.failed => [Text(s.networkError, style: AppText.bodyRegular)],
        },
        const SizedBox(height: 22),
        if (_stage == _Stage.ended || _stage == _Stage.failed) ...[
          DsPrimaryButton(
            label: _stage == _Stage.failed ? s.tryAgain : s.signoutAskAgain,
            onTap: _ask,
          ),
          const SizedBox(height: 9),
        ],
        DsPrimaryButton.secondary(
          label: _stage == _Stage.denied ? s.doneAction : s.cancel,
          onTap: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
