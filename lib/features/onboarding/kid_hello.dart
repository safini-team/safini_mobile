import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/onboarding/fini.dart';
import 'package:safini/features/onboarding/onboarding_store.dart';

/// Fini says hi the first time a kid reaches their shell on this phone: how
/// coins work, and plainly, that their parent sees which apps they use.
class KidHello extends StatefulWidget {
  const KidHello({
    super.key,
    required this.userId,
    required this.store,
    required this.child,
  });

  final String? userId;
  final OnboardingStore store;
  final Widget child;

  @override
  State<KidHello> createState() => _KidHelloState();
}

class _KidHelloState extends State<KidHello> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeGreet());
  }

  Future<void> _maybeGreet() async {
    final userId = widget.userId;
    if (!mounted || userId == null || widget.store.kidHelloSeen(userId)) {
      return;
    }
    // Before the sheet, so a kill mid-sheet does not greet them twice.
    await widget.store.markKidHelloSeen(userId);
    if (!mounted) return;
    await showKidHello(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> showKidHello(BuildContext context) {
  return showDsSheet<void>(
    context: context,
    builder: (sheetContext) {
      final s = S.of(sheetContext);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Fini(size: 120, cheer: true)),
          const SizedBox(height: 14),
          Text(
            s.kidHelloTitle,
            style: AppText.title2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          _Line(emoji: '✅', text: s.kidHelloTasks),
          _Line(emoji: '🎁', text: s.kidHelloSpend),
          _Line(emoji: '👀', text: s.kidHelloParent),
          const SizedBox(height: 20),
          DsPrimaryButton(
            key: const ValueKey('kid-hello-go'),
            label: s.kidHelloGo,
            onTap: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      );
    },
  );
}

class _Line extends StatelessWidget {
  const _Line({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.fillAlt,
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );
  }
}
