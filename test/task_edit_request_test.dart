import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/models/domain/models/task_model.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_sheet.dart';

/// SAF-191: the edit sheet never sent the "Needs photo proof" switch, so a
/// parent could not turn photo proof off (or on) for an existing task.
void main() {
  const bed = TaskModel(
    id: 'bed',
    title: 'Make the bed',
    category: 'home',
    proofMode: 'text_image',
    coinReward: 10,
    xpReward: 10,
    metadata: {'emoji': '🛏️'},
  );

  Map<String, dynamic> edit(
    TaskModel original, {
    int? coins,
    bool? photoProof,
  }) => taskEditRequest(
    original,
    title: original.title,
    description: original.description,
    category: original.category!,
    coins: coins ?? original.coinReward,
    recurrence: original.recurrence,
    recurrenceDays: original.recurrenceDays ?? 0,
    emoji: original.metadata!['emoji'] as String,
    photoProof: photoProof ?? taskNeedsPhoto(original.proofMode),
  ).toJson();

  test('switching photo proof off is sent with the other changes', () {
    expect(edit(bed, coins: 15, photoProof: false), {
      'coin_reward': 15,
      'xp_reward': 15,
      'proof_mode': 'none',
    });
  });

  test('switching photo proof on is sent', () {
    const plain = TaskModel(
      id: 'read',
      title: 'Read',
      category: 'learn',
      proofMode: 'none',
      coinReward: 5,
      xpReward: 5,
      metadata: {'emoji': '📚'},
    );
    expect(edit(plain, photoProof: true), {'proof_mode': 'text_image'});
  });

  test('an untouched task sends nothing', () {
    expect(edit(bed), isEmpty);
  });

  test('a legacy text task is not rewritten when proof stays off', () {
    const legacy = TaskModel(
      id: 'legacy',
      title: 'Walk the dog',
      category: 'outdoor',
      proofMode: 'text',
      coinReward: 5,
      xpReward: 5,
      metadata: {'emoji': '🐕'},
    );
    expect(edit(legacy), isEmpty);
  });
}
