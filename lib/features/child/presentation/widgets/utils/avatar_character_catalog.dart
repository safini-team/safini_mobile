import 'package:flutter/material.dart';

/// A single Safini base character.
///
/// Asset files live at: `assets/avatar/characters/<id>.webp` (512px, lossy).
class SafiniCharacter {
  final String id;
  final String name;
  final Color placeholderColor;

  const SafiniCharacter({
    required this.id,
    required this.name,
    required this.placeholderColor,
  });

  String get assetPath => 'assets/avatar/characters/$id.webp';
}

/// Catalog of the 29 Safini penguin characters.
///
/// IDs are stable - do not renumber once shipped.
const List<SafiniCharacter> safiniiCharacters = [
  SafiniCharacter(
    id: 'char_01',
    name: 'Bow',
    placeholderColor: Color(0xFFD46B8A),
  ),
  SafiniCharacter(
    id: 'char_02',
    name: 'Blue Cap',
    placeholderColor: Color(0xFF2E6F8E),
  ),
  SafiniCharacter(
    id: 'char_03',
    name: 'Bucket Hat',
    placeholderColor: Color(0xFFC99A2E),
  ),
  SafiniCharacter(
    id: 'char_04',
    name: 'Pigtails',
    placeholderColor: Color(0xFFB05080),
  ),
  SafiniCharacter(
    id: 'char_05',
    name: 'Bookworm',
    placeholderColor: Color(0xFF1A5C4A),
  ),
  SafiniCharacter(
    id: 'char_06',
    name: 'Beanie',
    placeholderColor: Color(0xFF7B4EA6),
  ),
  SafiniCharacter(
    id: 'char_07',
    name: 'Soccer Star',
    placeholderColor: Color(0xFFBF5A22),
  ),
  SafiniCharacter(
    id: 'char_08',
    name: 'Cool Shades',
    placeholderColor: Color(0xFF2A2A2A),
  ),
  SafiniCharacter(
    id: 'char_09',
    name: 'Heart Hugger',
    placeholderColor: Color(0xFFD46B8A),
  ),
  SafiniCharacter(
    id: 'char_10',
    name: 'Winter',
    placeholderColor: Color(0xFF9B2A2A),
  ),
  SafiniCharacter(
    id: 'char_11',
    name: 'Astronaut',
    placeholderColor: Color(0xFF5A5A7A),
  ),
  SafiniCharacter(
    id: 'char_12',
    name: 'Artist',
    placeholderColor: Color(0xFFBF2A2A),
  ),
  SafiniCharacter(
    id: 'char_13',
    name: 'Scientist',
    placeholderColor: Color(0xFF2E6F8E),
  ),
  SafiniCharacter(
    id: 'char_14',
    name: 'Superhero',
    placeholderColor: Color(0xFF1A5C4A),
  ),
  SafiniCharacter(
    id: 'char_15',
    name: 'Wizard',
    placeholderColor: Color(0xFF7B4EA6),
  ),
  SafiniCharacter(
    id: 'char_16',
    name: 'Builder',
    placeholderColor: Color(0xFFC99A2E),
  ),
  SafiniCharacter(
    id: 'char_17',
    name: 'Flower',
    placeholderColor: Color(0xFFB05080),
  ),
  SafiniCharacter(
    id: 'char_18',
    name: 'Gamer',
    placeholderColor: Color(0xFF1A5C4A),
  ),
  SafiniCharacter(
    id: 'char_19',
    name: 'Raincoat',
    placeholderColor: Color(0xFFC99A2E),
  ),
  SafiniCharacter(
    id: 'char_20',
    name: 'Party',
    placeholderColor: Color(0xFFD46B8A),
  ),
  SafiniCharacter(
    id: 'char_21',
    name: 'Sleepy',
    placeholderColor: Color(0xFF7B8EC8),
  ),
  SafiniCharacter(
    id: 'char_22',
    name: 'Stargazer',
    placeholderColor: Color(0xFFC99A2E),
  ),
  SafiniCharacter(
    id: 'char_23',
    name: 'Cheeky',
    placeholderColor: Color(0xFF2E6F8E),
  ),
  SafiniCharacter(
    id: 'char_24',
    name: 'Robot',
    placeholderColor: Color(0xFF5A5A7A),
  ),
  SafiniCharacter(
    id: 'char_25',
    name: 'Chef',
    placeholderColor: Color(0xFFBF5A22),
  ),
  SafiniCharacter(
    id: 'char_26',
    name: 'Musician',
    placeholderColor: Color(0xFFBF4A22),
  ),
  SafiniCharacter(
    id: 'char_27',
    name: 'Detective',
    placeholderColor: Color(0xFF8B6B3A),
  ),
  SafiniCharacter(
    id: 'char_28',
    name: 'Champion',
    placeholderColor: Color(0xFFC99A2E),
  ),
  SafiniCharacter(
    id: 'char_29',
    name: 'Rainbow',
    placeholderColor: Color(0xFF4A9A6A),
  ),
];

const String defaultCharacterId = 'char_01';

SafiniCharacter? characterById(String id) {
  try {
    return safiniiCharacters.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

SafiniCharacter resolvedCharacter(String? id) =>
    characterById(id ?? defaultCharacterId) ?? safiniiCharacters.first;
