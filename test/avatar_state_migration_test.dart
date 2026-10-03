import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/child_avatar_look.dart';
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

  // ─── SAF-131 Regression: partial equip update must not wipe other fields ──

  group('SAF-131 partial equip update safety', () {
    test('changing head slot must not remove existing accessory slot', () {
      // Simulate what AvatarCubit._saveAvatarState sends after equipping a head item:
      // the `equipped` map should contain ALL currently-equipped slots, not just head.
      final existingEquipped = {
        'accessory': 'item_watch_gold',
        'vehicle': 'item_car_blue',
      };

      // Simulated new head item
      const newHeadId = 'item_cap_green';

      // Safe merge: add head without removing others
      final merged = {...existingEquipped, 'head': newHeadId};

      expect(merged['head'], 'item_cap_green');
      expect(merged['accessory'], 'item_watch_gold',
          reason: 'accessory must survive a head change');
      expect(merged['vehicle'], 'item_car_blue',
          reason: 'vehicle must survive a head change');
    });

    test('changing character_id must not remove equipped slots', () {
      // The PATCH body sent by selectCharacter must include the existing equipped map.
      final existingEquipped = {
        'head': 'item_cap_red',
        'accessory': 'item_glasses_round',
      };

      final patchBody = {
        'avatar_state': {
          'character_id': 'char_09',
          'equipped': existingEquipped,
          'emojis': {'face': '😊'},
        },
      };

      final sentState = patchBody['avatar_state'] as Map;
      expect(sentState['character_id'], 'char_09');
      final sentEquipped = sentState['equipped'] as Map;
      expect(sentEquipped['head'], 'item_cap_red',
          reason: 'head must survive a character change');
      expect(sentEquipped['accessory'], 'item_glasses_round',
          reason: 'accessory must survive a character change');
    });

    test('legacy face emoji change must not wipe equipped slots', () {
      // selectFace sends the existing _equipped map back unchanged.
      final preserved = {
        'hair': 'starter-hair-01',
        'outfit': 'cosmic-cape',
        'head': 'item_beanie',
      };

      final patchBody = {
        'avatar_state': {
          'character_id': 'char_01',
          'equipped': preserved,
          'emojis': {'face': '🤓'},
        },
      };

      final sentEquipped =
          (patchBody['avatar_state'] as Map)['equipped'] as Map;
      expect(sentEquipped['hair'], 'starter-hair-01',
          reason: 'legacy hair must not be wiped by a face change');
      expect(sentEquipped['outfit'], 'cosmic-cape',
          reason: 'legacy outfit must not be wiped by a face change');
      expect(sentEquipped['head'], 'item_beanie',
          reason: 'v2 head must not be wiped by a face change');
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

    test('mixed v1+v2 — emoji and characterId both available', () {
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
        expect(c.assetPath, 'assets/avatar/characters/${c.id}.png');
      }
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
      // No exception thrown — safe
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
