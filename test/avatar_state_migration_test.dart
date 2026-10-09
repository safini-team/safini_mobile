import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

import 'package:safini/core/utils/child_avatar_look.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/models/domain/models/child_model.dart';
import 'package:safini/features/child/presentation/widgets/utils/avatar_character_catalog.dart';

// ─── AvatarStateModel migration tests ────────────────────────────────────────

void main() {
  group('AvatarStateModel.fromJson', () {
    test('empty / null avatar_state gives empty equipped and no characterId', () {
      final model = AvatarStateModel.fromJson({});
      expect(model.characterId, isNull);
      expect(model.equipped, isEmpty);
    });

    test('legacy child with only equipped map is parsed correctly', () {
      final model = AvatarStateModel.fromJson({
        'equipped': {'hair': 'starter-hair-01', 'outfit': 'cosmic-cape'},
      });
      expect(model.characterId, isNull);
      expect(model.equipped['hair'], 'starter-hair-01');
      expect(model.equipped['outfit'], 'cosmic-cape');
    });

    test('v2 child with character_id and v2 slots is parsed correctly', () {
      final model = AvatarStateModel.fromJson({
        'character_id': 'char_03',
        'equipped': {'head': 'item_cap_blue', 'accessory': 'item_watch_gold'},
      });
      expect(model.characterId, 'char_03');
      expect(model.equipped['head'], 'item_cap_blue');
      expect(model.equipped['accessory'], 'item_watch_gold');
    });

    test('child with character_id + mixed v1/v2 slots preserves all', () {
      final model = AvatarStateModel.fromJson({
        'character_id': 'char_07',
        'equipped': {
          'hair': 'starter-hair-01',
          'outfit': 'cosmic-cape',
          'head': 'item_beanie_purple',
        },
      });
      expect(model.characterId, 'char_07');
      expect(model.equipped['hair'], 'starter-hair-01');
      expect(model.equipped['outfit'], 'cosmic-cape');
      expect(model.equipped['head'], 'item_beanie_purple');
    });

    test('null avatar_state (null not empty map) gives defaults', () {
      final model = AvatarStateModel.fromJson({});
      expect(model.characterId, isNull);
      expect(model.equipped, isEmpty);
    });

    test('toJson round-trip preserves character_id', () {
      const model = AvatarStateModel(
        characterId: 'char_12',
        equipped: {'head': 'item_cap_red'},
      );
      final json = model.toJson();
      expect(json['character_id'], 'char_12');
      expect((json['equipped'] as Map)['head'], 'item_cap_red');
    });

    test('toJson omits character_id when null', () {
      const model = AvatarStateModel(equipped: {'hair': 'starter-hair'});
      final json = model.toJson();
      expect(json.containsKey('character_id'), isFalse);
      expect((json['equipped'] as Map)['hair'], 'starter-hair');
    });
  });

  // ─── SAF-131: PATCH replaces avatar_state, so a save must carry everything ──

  group('mergeAvatarState', () {
    test('character change keeps equipped, emojis and unknown keys', () {
      final merged = mergeAvatarState(
        {
          'character_id': 'char_01',
          'equipped': {'outfit': 'cosmic-cape'},
          'emojis': {'face': '🤓', 'outfit': '🦸'},
          'owned_characters': ['char_05'],
        },
        characterId: 'char_09',
        equipped: {'outfit': 'cosmic-cape'},
        emojis: {'face': '🤓'},
      );
      expect(merged['character_id'], 'char_09');
      expect(merged['equipped'], {'outfit': 'cosmic-cape'});
      expect(merged['emojis'], {'face': '🤓', 'outfit': '🦸'});
      expect(merged['owned_characters'], ['char_05']);
    });

    test('face change keeps the character the server holds', () {
      final merged = mergeAvatarState(
        {'character_id': 'char_07', 'equipped': {}},
        characterId: 'char_07',
        equipped: const {},
        emojis: {'face': '😎'},
      );
      expect(merged['character_id'], 'char_07');
      expect((merged['emojis'] as Map)['face'], '😎');
    });

    test('no character yet means no character_id key is invented', () {
      final merged = mergeAvatarState(
        const {},
        equipped: const {},
        emojis: {'face': '😊'},
      );
      expect(merged.containsKey('character_id'), isFalse);
    });

    test('does not mutate the base map', () {
      final base = <String, dynamic>{
        'equipped': {'hair': 'starter-hair-01'},
        'emojis': {'face': '😊'},
      };
      mergeAvatarState(
        base,
        characterId: 'char_02',
        equipped: {'hair': 'starter-hair-01'},
        emojis: {'face': '🥰'},
      );
      expect(base.containsKey('character_id'), isFalse);
      expect((base['emojis'] as Map)['face'], '😊');
    });
  });

  // ─── ChildAvatarLook migration tests ─────────────────────────────────────

  group('ChildAvatarLook migration', () {
    test('legacy emoji-only data still produces valid look', () {
      final look = ChildAvatarLook.fromAvatarState({
        'emojis': {'face': '😎'},
      });
      expect(look.characterId, isNull);
      expect(look.isIllustrated, isFalse);
      expect(look.faceEmoji, '😎');
      expect(look.hasCustomFace, isTrue);
    });

    test('v2 data produces illustrated look', () {
      final look = ChildAvatarLook.fromAvatarState({
        'character_id': 'char_07',
        'equipped': {'head': 'item_beanie_purple'},
      });
      expect(look.characterId, 'char_07');
      expect(look.isIllustrated, isTrue);
      expect(look.headItemId, 'item_beanie_purple');
    });

    test('mixed v1+v2 - emoji and characterId both available', () {
      final look = ChildAvatarLook.fromAvatarState({
        'character_id': 'char_03',
        'emojis': {'face': '🥰'},
        'equipped': {
          'outfit': 'cosmic-cape',
          'accessory': 'item_glasses',
        },
      });
      expect(look.characterId, 'char_03');
      expect(look.faceEmoji, '🥰');
      expect(look.accessoryItemId, 'item_glasses');
      // Legacy accessory emoji still mapped from outfit key
      expect(look.accessoryEmoji, '🦸');
    });

    test('null/missing avatar_state is safe (no characterId, default face)', () {
      final look = ChildAvatarLook.fromAvatarState(null);
      expect(look.characterId, isNull);
      expect(look.isIllustrated, isFalse);
      expect(look.faceEmoji, ChildAvatarLook.defaultFaceEmoji);
      expect(look.hasCustomFace, isFalse);
    });

    test('partially populated avatar_state does not crash', () {
      final look = ChildAvatarLook.fromAvatarState({'character_id': ''});
      expect(look.characterId, isNull);
      expect(look.isIllustrated, isFalse);
    });
  });

  // ─── Character catalog tests ──────────────────────────────────────────────

  group('Avatar character catalog', () {
    test('catalog has exactly 29 characters', () {
      expect(safiniiCharacters.length, 29);
    });

    test('all character IDs are unique', () {
      final ids = safiniiCharacters.map((c) => c.id).toSet();
      expect(ids.length, safiniiCharacters.length);
    });

    test('all IDs follow char_NN pattern', () {
      for (final c in safiniiCharacters) {
        expect(c.id, matches(RegExp(r'^char_\d{2}$')),
            reason: '${c.id} does not match char_NN');
      }
    });

    test('defaultCharacterId resolves to a known character', () {
      expect(characterById(defaultCharacterId), isNotNull);
    });

    test('resolvedCharacter falls back to first character for unknown id', () {
      final c = resolvedCharacter('char_99_unknown');
      expect(c, isNotNull);
      expect(safiniiCharacters.contains(c), isTrue);
    });

    test('asset paths follow the expected convention', () {
      for (final c in safiniiCharacters) {
        expect(c.assetPath, 'assets/avatar/characters/${c.id}.webp');
      }
    });

    test('every catalog character has its bundled file', () {
      for (final c in safiniiCharacters) {
        expect(File(c.assetPath).existsSync(), isTrue,
            reason: '${c.assetPath} missing');
      }
    });

    test('bundled character art stays small', () {
      final bytes = safiniiCharacters
          .map((c) => File(c.assetPath).lengthSync())
          .fold<int>(0, (a, b) => a + b);
      expect(bytes, lessThan(3 * 1024 * 1024),
          reason: 'character art is ${bytes ~/ 1024} KB');
    });
  });

  // ─── Migration scenario tests ─────────────────────────────────────────────

  group('Migration scenarios', () {
    test('child with only legacy emoji data gets no characterId', () {
      final model = AvatarStateModel.fromJson({
        'emojis': {'face': '😇'},
      });
      expect(model.characterId, isNull,
          reason: 'emojis map alone should not produce a characterId');
    });

    test('child with legacy equipped items keeps inventory intact', () {
      final model = AvatarStateModel.fromJson({
        'equipped': {
          'hair': 'starter-hair-01',
          'outfit': 'cosmic-cape',
          'back': 'rocket-pack',
        },
      });
      // No character_id assigned yet
      expect(model.characterId, isNull);
      // Inventory preserved exactly
      expect(model.equipped['hair'], 'starter-hair-01');
      expect(model.equipped['outfit'], 'cosmic-cape');
      expect(model.equipped['back'], 'rocket-pack');
    });

    test('child with empty avatar_state gets safe defaults', () {
      final model = AvatarStateModel.fromJson({});
      expect(model.characterId, isNull);
      expect(model.equipped, isEmpty);
      // No exception thrown - safe
    });

    test('child with character_id but no equipped map still parses', () {
      final model = AvatarStateModel.fromJson({'character_id': 'char_05'});
      expect(model.characterId, 'char_05');
      expect(model.equipped, isEmpty);
    });

    test('coins and inventory are logically separate from avatar_state', () {
      // AvatarStateModel contains no coin or inventory data.
      // This test documents the contract: PATCH /avatar only changes avatar_state,
      // never touches coins_balance or inventory.
      const model = AvatarStateModel(
        characterId: 'char_01',
        equipped: {'head': 'item_cap_green'},
      );
      final json = model.toJson();
      expect(json.containsKey('coins_balance'), isFalse);
      expect(json.containsKey('inventory'), isFalse);
    });
  });
}
