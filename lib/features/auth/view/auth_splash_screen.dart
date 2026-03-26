import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthSplashScreen extends StatelessWidget {
  const AuthSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5B23C8),
              Color(0xFF6B2FE0),
              Color(0xFF9F7FFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            const _BackgroundGlow(
              alignment: Alignment(-0.9, 0.65),
              size: 280,
              opacity: 0.16,
            ),
            const _BackgroundGlow(
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
                    const Text(
                      'SAFINIO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Learn. Earn. Play.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const Spacer(flex: 3),
                    _RoleCard(
                      title: "I'm a Kid!",
                      subtitle: 'Earn coins & play',
                      color: const Color(0xFFF3B616),
                      icon: Icons.sports_esports_rounded,
                      onPressed: () => context.go('/tasks'),
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      title: "I'm a Parent",
                      subtitle: 'Monitor & reward',
                      color: const Color(0xFF2FD0AF),
                      icon: Icons.family_restroom_rounded,
                      onPressed: () => context.go('/parent'),
                    ),
                    const Spacer(flex: 2),
                    Text(
                      'Safe screen time for smart kids ✨',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
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

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safini Parent')),
      body: const Center(
        child: Text('Parent dashboard coming soon'),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(32),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                child: Icon(icon, size: 34, color: Colors.black.withValues(alpha: 0.45)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final double opacity;

  const _BackgroundGlow({
    required this.alignment,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
