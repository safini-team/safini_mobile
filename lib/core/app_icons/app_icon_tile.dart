import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:safini/core/app_icons/app_icon_cache.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/utils/widgets/ds/ds_avatar.dart';

/// An app's real icon, with the emoji tile standing in until there is one.
///
/// On the child's own Android phone the icon comes from the launcher, by
/// [packageName]. Everywhere else - the parent's phone, an iPhone - it is the
/// copy the child's phone uploaded, at [iconUrl]. With neither, while it
/// loads, or when the app has no icon anywhere, this is the emoji tile it
/// replaced, at the same size, so rows do not jump when the icon lands.
class AppIconTile extends StatefulWidget {
  const AppIconTile({
    super.key,
    required this.emoji,
    this.packageName,
    this.iconUrl,
    this.size = 34,
    this.radius = AppRadius.sm,
    this.fontSize,
    this.opacity = 1,
    this.placeholder,
    this.cache,
  });

  final String emoji;
  final String? packageName;
  final String? iconUrl;
  final double size;
  final double radius;
  final double? fontSize;
  final double opacity;

  /// Drawn instead of the emoji tile while there is no icon, for places that
  /// show a bare emoji rather than a tile.
  final Widget? placeholder;

  /// Defaults to the app-wide cache; without one (previews, tests) this only
  /// ever draws the emoji.
  final AppIconCache? cache;

  @override
  State<AppIconTile> createState() => _AppIconTileState();
}

class _AppIconTileState extends State<AppIconTile> {
  Uint8List? _icon;

  AppIconCache? get _cache =>
      widget.cache ??
      (getIt.isRegistered<AppIconCache>() ? getIt<AppIconCache>() : null);

  String? get _package => _nonEmpty(widget.packageName);
  String? get _url => _nonEmpty(widget.iconUrl);

  static String? _nonEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(AppIconTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName ||
        oldWidget.iconUrl != widget.iconUrl) {
      _resolve();
    }
  }

  /// Takes what the cache already has in this frame, so a list scrolled back
  /// or a sheet opened again never flashes the emoji first.
  void _resolve() {
    _icon = null;
    final cache = _cache;
    if (cache == null) return;
    final package = _package;
    final url = _url;

    _icon =
        (package == null ? null : cache.peekLocal(package)) ??
        (url == null ? null : cache.peekRemote(url));
    if (_icon != null) return;

    final settled =
        (package == null || cache.hasLocal(package)) &&
        (url == null || cache.hasRemote(url));
    if (!settled) _load(cache, package, url);
  }

  /// The launcher first, since it is on this phone; the upload otherwise.
  Future<void> _load(AppIconCache cache, String? package, String? url) async {
    var icon = package == null ? null : await cache.local(package);
    if (icon == null && url != null) icon = await cache.remote(url);
    // The tile was handed another app meanwhile; this answer is not for it.
    if (!mounted || package != _package || url != _url) return;
    if (icon != null) setState(() => _icon = icon);
  }

  @override
  Widget build(BuildContext context) {
    final fallback =
        widget.placeholder ??
        DsEmojiTile(
          emoji: widget.emoji,
          size: widget.size,
          radius: widget.radius,
          fontSize: widget.fontSize,
          opacity: widget.opacity,
        );
    final icon = _icon;
    if (icon == null) return fallback;

    final pixels = (widget.size * MediaQuery.devicePixelRatioOf(context))
        .round();
    return Opacity(
      opacity: widget.opacity,
      child: Image.memory(
        icon,
        width: widget.size,
        height: widget.size,
        // Launcher icons carry their own shape, so no clip or tile behind.
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        cacheWidth: pixels,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
