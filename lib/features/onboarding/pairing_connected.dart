import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/onboarding/fini.dart';

/// What the parent's add-child screen turns into once the kid's phone has
/// used the code: Fini cheers, confetti, one line, one button.
class PairingConnected extends StatelessWidget {
  const PairingConnected({super.key, required this.name, required this.onDone});

  final String name;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 40, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 220,
            child: Stack(
              children: [
                Center(
                  child: Fini(size: 170, cheer: true, pose: FiniPose.cheer),
                ),
                Positioned.fill(child: FiniConfetti(pieces: 48)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            s.phoneConnectedTitle(name),
            style: AppText.title1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.phoneConnectedBody,
            style: AppText.bodyRegular,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          DsPrimaryButton(
            key: const ValueKey('pairing-connected-done'),
            label: s.goToMyFamily,
            onTap: onDone,
          ),
        ],
      ),
    );
  }
}
