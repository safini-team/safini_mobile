import 'package:flutter/material.dart';

/// Runs [onResume] every time the app comes back to the foreground.
///
/// Both shells fetch their data once and then sit on it, so anything that
/// happens while the app is backgrounded - the parent approving a task, the
/// child spending coins on the native block screen - left the screen showing
/// numbers that were already wrong. Wrap a screen in this and it refetches
/// when the child or parent actually looks at it again.
class OnAppResume extends StatefulWidget {
  const OnAppResume({super.key, required this.onResume, required this.child});

  final VoidCallback onResume;
  final Widget child;

  @override
  State<OnAppResume> createState() => _OnAppResumeState();
}

class _OnAppResumeState extends State<OnAppResume> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) widget.onResume();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
