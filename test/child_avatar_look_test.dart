import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/child_avatar_look.dart';

void main() {
  test('missing avatar_state is the default smile, never empty', () {
    final look = ChildAvatarLook.fromAvatarState(null);
    expect(look.faceEmoji, '😊');
    expect(look.accessoryEmoji, isNull);
    expect(look.hasCustomFace, isFalse);
    expect(ChildAvatarLook.hasPersistedFace(null), isFalse);
  });

  test('reads the face from emojis.face', () {
    final look = ChildAvatarLook.fromAvatarState({
      'emojis': {'face': '😎'},
    });
    expect(look.faceEmoji, '😎');
    expect(look.hasCustomFace, isTrue);
  });

  test('maps an equipped outfit key the same way the child customizer does', () {
    final look = ChildAvatarLook.fromAvatarState({
      'emojis': {'face': '🥰'},
      'equipped': {'outfit': 'cosmic-cape'},
    });
    expect(look.faceEmoji, '🥰');
    expect(look.accessoryEmoji, '🦸');
  });

  test('maps starter hair when that is all the dashboard sent', () {
    final look = ChildAvatarLook.fromAvatarState({
      'equipped': {'hair': 'starter-hair-01'},
    });
    expect(look.faceEmoji, '😊');
    expect(look.hasCustomFace, isFalse);
    expect(look.accessoryEmoji, '👦');
  });

  test('maps an equipped face inventory key', () {
    final look = ChildAvatarLook.fromAvatarState({
      'equipped': {'face': 'cool-shades-01'},
    });
    expect(look.faceEmoji, '😎');
    expect(look.hasCustomFace, isTrue);
  });

  test('an unknown inventory key is not drawn as a second smile', () {
    final look = ChildAvatarLook.fromAvatarState({
      'emojis': {'face': '😇'},
      'equipped': {'outfit': 'mystery-item-99'},
    });
    expect(look.faceEmoji, '😇');
    expect(look.accessoryEmoji, isNull);
  });

  test('inventory keys are never treated as a literal face emoji', () {
    expect(ChildAvatarLook.emojiForAvatarKey('cosmic-cape'), '🦸');
    expect(ChildAvatarLook.emojiForAvatarKey('rocket-pack'), '🚀');
    expect(ChildAvatarLook.emojiForAvatarKey('unknown'), isNull);
  });
}
