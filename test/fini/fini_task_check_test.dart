import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/fini_copy.dart';
import 'package:safini/features/fini/presentation/widgets/fini_check_panel.dart';
import 'package:safini/features/models/domain/models/task_model.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_screen.dart'
    show finiTaskLine;
import 'package:safini/features/parent/presentation/widgets/tasks/task_sheet.dart';

const _duolingo = {
  'package_name': 'com.duolingo',
  'app_name': 'Duolingo',
  'minutes': 10,
};

ParentTaskInstanceModel _task(String status, Map<String, dynamic>? fini) =>
    ParentTaskInstanceModel.fromJson({
      'id': 't',
      'status': status,
      'title': 'Duolingo lesson',
      'fini_result': fini,
    });

void main() {
  group('"Let Fini check" on the task sheet', () {
    test('what goes in metadata.fini_check', () {
      const off = FiniCheck();
      expect(off.toJson(photo: false), isNull);
      const noApp = FiniCheck(on: true);
      expect(noApp.toJson(photo: false), isNull);
      expect(noApp.toJson(photo: true), {'photo': true});
      final app = FiniCheck.fromJson(_duolingo);
      expect(app.toJson(photo: false), _duolingo);
      expect(FiniCheck.fromJson({'photo': true}).on, isTrue);
    });

    test('the rest of the metadata is kept, the check set or dropped', () {
      final meta = {'emoji': '📚', 'idea': 'read', 'fini_check': _duolingo};
      expect(withFiniCheck(meta, null), {'emoji': '📚', 'idea': 'read'});
      expect(withFiniCheck({'emoji': '📚'}, {'photo': true}), {
        'emoji': '📚',
        'fini_check': {'photo': true},
      });
    });

    test('an edit sends the check only when it changed', () {
      const lesson = TaskModel(
        id: 'l',
        title: 'Duolingo lesson',
        category: 'learn',
        proofMode: 'none',
        coinReward: 20,
        xpReward: 20,
        metadata: {'emoji': '📚', 'fini_check': _duolingo},
      );
      Map<String, dynamic> edit(Map<String, dynamic>? check) => taskEditRequest(
        lesson,
        title: lesson.title,
        description: null,
        category: 'learn',
        coins: 20,
        recurrence: lesson.recurrence,
        recurrenceDays: 0,
        emoji: '📚',
        photoProof: false,
        finiCheck: check,
      ).toJson();
      expect(edit(_duolingo), isEmpty);
      expect(edit({..._duolingo, 'minutes': 15})['metadata'], {
        'emoji': '📚',
        'fini_check': {..._duolingo, 'minutes': 15},
      });
      expect(edit(null)['metadata'], {'emoji': '📚'});
    });
  });

  group('the Tasks list', () {
    late S s;
    setUp(() async => s = await S.load(const Locale('en')));

    test('Fini approved it: the line and Undo while it lasts', () {
      final approved = _task('approved', {
        'kind': 'usage',
        'approved': true,
        'proposal_id': 'p',
        'undo_until': DateTime.now()
            .add(const Duration(hours: 3))
            .toIso8601String(),
        'used_minutes': 12,
        'needed_minutes': 10,
      });
      expect(approved.approvedByFini, isTrue);
      expect(finiTaskLine(s, approved), s.taskFiniApproved);
      expect(approved.finiResult!.canUndo(DateTime.now()), isTrue);
      expect(
        approved.finiResult!.canUndo(
          DateTime.now().add(const Duration(days: 2)),
        ),
        isFalse,
      );
    });

    test('waiting for a parent: what Fini saw', () {
      final short = _task('submitted', {
        'kind': 'usage',
        'approved': false,
        'app_name': 'Duolingo',
        'used_minutes': 4,
        'needed_minutes': 10,
      });
      expect(
        finiTaskLine(s, short),
        s.taskFiniSawApp('Duolingo', formatHm(s, 4), formatHm(s, 10)),
      );
      final photo = _task('submitted', {
        'kind': 'photo',
        'state': 'parent',
        'note': 'The bed is out of frame.',
      });
      expect(
        finiTaskLine(s, photo),
        s.taskFiniSawPhoto('The bed is out of frame.'),
      );
      expect(
        finiTaskLine(
          s,
          _task('submitted', {'kind': 'photo', 'state': 'checking'}),
        ),
        s.taskFiniChecking,
      );
    });

    test('undone, or no Fini at all: no line', () {
      expect(
        finiTaskLine(
          s,
          _task('submitted', {
            'kind': 'usage',
            'approved': false,
            'undone': true,
          }),
        ),
        isNull,
      );
      expect(finiTaskLine(s, _task('submitted', null)), isNull);
    });
  });

  test('the activity entry says the minutes in the parent language', () async {
    final s = await S.load(const Locale('ru'));
    final approval = FiniProposal(
      id: 'p',
      childId: 'amir',
      kind: 'task_review',
      status: FiniProposalStatus.applied,
      decidedBy: 'fini',
      reason: 'Duolingo: 12 min today, the task asked for 10.',
      createdAt: DateTime(2026, 10, 15),
      evidence: const {
        'usage': {
          'app_name': 'Duolingo',
          'used_minutes': 12,
          'needed_minutes': 10,
        },
      },
    );
    expect(
      finiReasonLine(s, approval),
      s.finiUsageProof('Duolingo', formatHm(s, 12), formatHm(s, 10)),
    );
  });
}
