/// The in-app face a child equips, plus an optional worn extra.
///
/// Face lives in `avatar_state.emojis.face`. Equipped extras are inventory
/// keys (`outfit`, `back`, …) which we map to the same sticker emojis the
/// child customizer uses. Parents never get an OAuth photo from this.
class ChildAvatarLook {
  static const defaultFaceEmoji = '😊';

  const ChildAvatarLook({
    this.faceEmoji = defaultFaceEmoji,
    this.accessoryEmoji,
    this.hasCustomFace = false,
  });

  final String faceEmoji;
  final String? accessoryEmoji;

  /// True when the payload actually recorded a face, vs our fallback smile.
  final bool hasCustomFace;

  factory ChildAvatarLook.fromAvatarState(dynamic raw) {
    final state = _asMap(raw);
    final emojis = _asMap(state['emojis']);
    final equipped = _asMap(state['equipped']);

    final equippedFace = _trimmed(equipped['face']);
    final face = _trimmed(emojis['face']) ??
        _emojiIfLiteral(equippedFace) ??
        (equippedFace == null ? null : emojiForAvatarKey(equippedFace));
    final accessory = _accessoryFrom(emojis, equipped);

    return ChildAvatarLook(
      faceEmoji: (face == null || face.isEmpty) ? defaultFaceEmoji : face,
      accessoryEmoji: accessory,
      hasCustomFace: face != null && face.isNotEmpty,
    );
  }

  static bool hasPersistedFace(dynamic raw) {
    return ChildAvatarLook.fromAvatarState(raw).hasCustomFace;
  }

  static String? _accessoryFrom(
    Map<String, dynamic> emojis,
    Map<String, dynamic> equipped,
  ) {
    const slots = [
      'outfit',
      'outfits',
      'back',
      'backpack',
      'badge',
      'accessory',
      'hair',
    ];
    for (final slot in slots) {
      final fromEmojis = _emojiIfLiteral(_trimmed(emojis[slot]));
      if (fromEmojis != null) return fromEmojis;
      final key = _trimmed(equipped[slot]);
      if (key == null) continue;
      final literal = _emojiIfLiteral(key);
      if (literal != null) return literal;
      final mapped = emojiForAvatarKey(key);
      if (mapped != null) return mapped;
    }
    return null;
  }

  /// Sticker for an equipped inventory key. Null when the key is not a
  /// known extra - never the default face, so a missing map does not draw
  /// a second smile in the accessory bubble.
  static String? emojiForAvatarKey(String key) {
    final value = key.toLowerCase();
    if (value.contains('cape') || value.contains('hero')) return '🦸';
    if (value.contains('rocket')) return '🚀';
    if (value.contains('sword')) return '⚔️';
    if (value.contains('robot')) return '🤖';
    if (value.contains('star')) return '🤩';
    if (value.contains('cool')) return '😎';
    if (value.contains('shirt') || value.contains('outfit')) return '👕';
    if (value.contains('back') || value.contains('pack')) return '🎒';
    if (value.contains('hair')) return '👦';
    return null;
  }

  static String? _emojiIfLiteral(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.contains('-') && value.length > 4) return null;
    if (value.runes.every((unit) => unit <= 0x7F)) return null;
    return value;
  }

  static String? _trimmed(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }
}
