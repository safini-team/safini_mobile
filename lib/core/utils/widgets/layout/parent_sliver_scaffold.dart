import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

/// Shared collapsing-header scaffold for the parent tabs.
///
/// Provides a [CustomScrollView] with a pinned [SliverAppBar] (gradient header
/// that collapses on scroll) and a rounded surface body that scrolls as one
/// piece — matching the monitor tab. Pass a finite [body] (e.g. a Column); the
/// scroll view owns the scrolling, so the body must not scroll itself.
class ParentSliverScaffold extends StatelessWidget {
  const ParentSliverScaffold({
    super.key,
    required this.header,
    required this.expandedHeight,
    required this.body,
    this.actions = const [],
    this.onRefresh,
    this.bodyPadding = const EdgeInsets.fromLTRB(24, 28, 24, 100),
  });

  /// Content shown inside the collapsing gradient header (title, subtitle…).
  final Widget header;

  /// Total height of the expanded header, including the status-bar inset is
  /// handled internally via [SafeArea].
  final double expandedHeight;

  /// Finite body content (does not scroll on its own).
  final Widget body;

  /// Optional pinned top-right actions.
  final List<Widget> actions;

  /// Pull-to-refresh handler; when null, refresh is disabled.
  final Future<void> Function()? onRefresh;

  final EdgeInsets bodyPadding;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;

    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: expandedHeight,
          collapsedHeight: kToolbarHeight,
          backgroundColor: primary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          actions: actions,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.8),
                    primary,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 12, 20),
                  child: header,
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(36),
                topRight: Radius.circular(36),
              ),
            ),
            child: Padding(padding: bodyPadding, child: body),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: primary,
      body: onRefresh == null
          ? scrollView
          : RefreshIndicator(onRefresh: onRefresh!, child: scrollView),
    );
  }
}
