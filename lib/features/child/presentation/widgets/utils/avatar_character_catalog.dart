import 'package:flutter/material.dart';
import 'package:safini/features/child/presentation/cubit/profile_model.dart';

/// Bundled head cosmetic items.
///
/// These are always available in the Head tab regardless of server state.
/// Server items with the same [id] take precedence.
const List<AvatarGridItem> bundledHeadItems = [
  AvatarGridItem(
    id: 'hat_cap_green',
    assetKey: 'hat_cap_green',
    emoji: '🧢',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_cap_blue',
    assetKey: 'hat_cap_blue',
    emoji: '🧢',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_bucket_yellow',
    assetKey: 'hat_bucket_yellow',
    emoji: '🪣',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_cap_orange',
    assetKey: 'hat_cap_orange',
    emoji: '🧢',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_bow_pink',
    assetKey: 'hat_bow_pink',
    emoji: '🎀',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_beanie_purple',
    assetKey: 'hat_beanie_purple',
    emoji: '🧤',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_beanie_white',
    assetKey: 'hat_beanie_white',
    emoji: '🧤',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_safari',
    assetKey: 'hat_safari',
    emoji: '🎩',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_dino',
    assetKey: 'hat_dino',
    emoji: '🦕',
    category: AvatarCategory.head,
  ),
  AvatarGridItem(
    id: 'hat_unicorn',
    assetKey: 'hat_unicorn',
    emoji: '🦄',
    category: AvatarCategory.head,
  ),
];

/// Bundled vehicle cosmetic items.
///
/// These are always available in the Vehicles tab regardless of server state.
/// Server items with the same [id] take precedence.
const List<AvatarGridItem> bundledVehicleItems = [
  AvatarGridItem(
    id: 'veh_car_red',
    assetKey: 'veh_car_red',
    emoji: '🚗',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_bus_school',
    assetKey: 'veh_bus_school',
    emoji: '🚌',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_bicycle_green',
    assetKey: 'veh_bicycle_green',
    emoji: '🚲',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_scooter_orange',
    assetKey: 'veh_scooter_orange',
    emoji: '🛴',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_airplane_blue',
    assetKey: 'veh_airplane_blue',
    emoji: '✈️',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_rocket_green',
    assetKey: 'veh_rocket_green',
    emoji: '🚀',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_train_rainbow',
    assetKey: 'veh_train_rainbow',
    emoji: '🚂',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_helicopter_blue',
    assetKey: 'veh_helicopter_blue',
    emoji: '🚁',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_firetruck',
    assetKey: 'veh_firetruck',
    emoji: '🚒',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_ambulance',
    assetKey: 'veh_ambulance',
    emoji: '🚑',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_police_car',
    assetKey: 'veh_police_car',
    emoji: '🚓',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_sailboat',
    assetKey: 'veh_sailboat',
    emoji: '⛵',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_submarine_yellow',
    assetKey: 'veh_submarine_yellow',
    emoji: '🚢',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_tractor_green',
    assetKey: 'veh_tractor_green',
    emoji: '🚜',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_balloon',
    assetKey: 'veh_balloon',
    emoji: '🎈',
    category: AvatarCategory.vehicle,
  ),
  AvatarGridItem(
    id: 'veh_ufo',
    assetKey: 'veh_ufo',
    emoji: '🛸',
    category: AvatarCategory.vehicle,
  ),
];

/// Bundled accessory cosmetic items.
///
/// These are always available in the Accessories tab regardless of server state.
/// Server items with the same [id] take precedence.
const List<AvatarGridItem> bundledAccessoryItems = [
  AvatarGridItem(
    id: 'acc_glasses_green',
    assetKey: 'acc_glasses_green',
    emoji: '👓',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_glasses_black',
    assetKey: 'acc_glasses_black',
    emoji: '🕶️',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_glasses_heart_pink',
    assetKey: 'acc_glasses_heart_pink',
    emoji: '🕶️',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_headphones_orange',
    assetKey: 'acc_headphones_orange',
    emoji: '🎧',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_headphones_purple',
    assetKey: 'acc_headphones_purple',
    emoji: '🎧',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_bow_pink',
    assetKey: 'acc_bow_pink',
    emoji: '🎀',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_bow_yellow',
    assetKey: 'acc_bow_yellow',
    emoji: '🎀',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_flower_pink',
    assetKey: 'acc_flower_pink',
    emoji: '🌸',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_camera',
    assetKey: 'acc_camera',
    emoji: '📷',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_gamepad',
    assetKey: 'acc_gamepad',
    emoji: '🎮',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_soccer_ball',
    assetKey: 'acc_soccer_ball',
    emoji: '⚽',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_book_penguin',
    assetKey: 'acc_book_penguin',
    emoji: '📚',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_backpack_teal',
    assetKey: 'acc_backpack_teal',
    emoji: '🎒',
    category: AvatarCategory.accessory,
  ),
  AvatarGridItem(
    id: 'acc_sparkle_gold',
    assetKey: 'acc_sparkle_gold',
    emoji: '✨',
    category: AvatarCategory.accessory,
  ),
];

/// A single Safini base character.
///
/// Asset files live at: `assets/avatar/characters/<id>.png`
class SafiniCharacter {
  final String id;
  final String name;
  final Color placeholderColor;

  const SafiniCharacter({
    required this.id,
    required this.name,
    required this.placeholderColor,
  });

  String get assetPath => 'assets/avatar/characters/$id.png';
}

/// A cosmetic item that can be layered on top of a base character.
///
/// Asset files live at: `assets/avatar/cosmetics/<slot>/<id>.png`
///
/// [slot] must be one of: head, accessory, vehicle
class SafiniCosmeticDef {
  final String id;
  final String slot;
  final String name;

  const SafiniCosmeticDef({
    required this.id,
    required this.slot,
    required this.name,
  });

  String get assetPath => 'assets/avatar/cosmetics/$slot/$id.png';
}

/// Catalog of the 29 Safini penguin characters.
///
/// IDs are stable — do not renumber once shipped.
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
