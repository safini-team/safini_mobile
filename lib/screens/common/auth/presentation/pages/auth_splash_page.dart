import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safini/screens/common/core/theme/app_colors.dart';
import 'package:safini/screens/common/core/utils/theme_extensions.dart';
import 'package:safini/screens/common/auth/presentation/widgets/background_glow.dart';
import 'package:safini/screens/common/auth/presentation/widgets/role_card.dart';

class AuthSplashScreen extends StatelessWidget {
  const AuthSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            const BackgroundGlow(
              alignment: Alignment(-0.9, 0.65),
              size: 280,
              opacity: 0.16,
            ),
            const BackgroundGlow(
              alignment: Alignment(0.9, -0.55),
              size: 290,
              opacity: 0.12,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    const Text('🦁', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 14),
                    Text(
                      'SAFINIO',
                      style: context.onPrimaryStyle(
                        context.headingXl.copyWith(
                          fontSize: 52,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Learn. Earn. Play.',
                      style: context.onPrimaryStyle(
                        context.headingMd.copyWith(
                          fontSize: 24,
                          letterSpacing: 0.6,
                        ),
                        opacity: 0.82,
                      ),
                    ),
                    const Spacer(flex: 3),
                    RoleCard(
                      title: "I'm a Kid!",
                      subtitle: 'Earn coins & play',
                      color: const Color(0xFFF3B616),
                      icon: Icons.sports_esports_rounded,
                      onPressed: () => context.go('/tasks'),
                    ),
                    const SizedBox(height: 16),
                    RoleCard(
                      title: "I'm a Parent",
                      subtitle: 'Monitor & reward',
                      color: const Color(0xFF2FD0AF),
                      icon: Icons.family_restroom_rounded,
                      onPressed: () => context.go('/parent'),
                    ),
                    const Spacer(flex: 2),
                    Text(
                      'Safe screen time for smart kids ✨',
                      style: context.onPrimaryStyle(
                        context.bodyLg.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        opacity: 0.7,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
