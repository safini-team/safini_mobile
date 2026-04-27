import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _animationDone = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Minimum splash duration so users see the branding.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _animationDone = true;
        _navigateIfReady();
      }
    });

    // Kick off session check.
    context.read<AuthSessionCubit>().checkExistingSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Navigate only when both the animation delay has elapsed **and** the
  /// session/profile check has resolved.
  void _navigateIfReady() {
    if (!_animationDone || !mounted || _hasNavigated) return;

    final state = context.read<AuthSessionCubit>().state;
    final resolved = state.status == AuthSessionStatus.unauthenticated ||
        state.status == AuthSessionStatus.authenticated ||
        state.status == AuthSessionStatus.signInError ||
        state.status == AuthSessionStatus.profileError;

    // Avoid splash deadlock if auth resolved before BlocListener mounted.
    if (!resolved) return;

    _hasNavigated = true;

    switch (state.status) {
      case AuthSessionStatus.unauthenticated:
      case AuthSessionStatus.signInError:
        context.router.replace(const NamedRoute('login'));
        break;

      case AuthSessionStatus.authenticated:
        _routeByAccountType(state.accountType);
        break;

      case AuthSessionStatus.profileError:
        if (state.isUnauthorized) {
          context.router.replace(const NamedRoute('login'));
        } else {
          // Network error during profile fetch — go to login so user can retry.
          context.router.replace(const NamedRoute('login'));
        }
        break;

      // Still loading — should not happen, but guard anyway.
      default:
        break;
    }
  }

  void _routeByAccountType(String? accountType) {
    switch (accountType) {
      case 'parent':
        context.router.replace(const NamedRoute('parentHome'));
        break;
      case 'child':
        context.router.replace(const NamedRoute('childHome'));
        break;
      default:
        // null, missing, or any unexpected value → Role Selection
        context.router.replace(const NamedRoute('roleSelection'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listener: (context, state) {
        _navigateIfReady();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/logo/app_logo.png',
                width: 220,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
