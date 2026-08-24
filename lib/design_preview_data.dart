// Sample data for the design preview and the layout tests, transcribed from
// the artboard's own `state` object. Dev-only; `main.dart` never imports it.
import 'package:flutter/material.dart';

import 'package:safini/core/translation/generated/l10n.dart';

import 'package:safini/features/child/presentation/screens/home/child_today_view.dart';
import 'package:safini/features/child/presentation/screens/profile/child_me_view.dart';
import 'package:safini/features/child/presentation/screens/store/child_store_view.dart';
import 'package:safini/features/child/presentation/screens/tasks/child_tasks_view.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_view.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_view.dart';

/// The artboard's `state` object, transcribed.
class SampleData {
  const SampleData._();

  static const List<TodayKid> kids = [
    TodayKid(id: 'amir', name: 'Amir', color: Color(0xFF8100D1)),
    TodayKid(id: 'layla', name: 'Layla', color: Color(0xFFEE4FA2)),
  ];

  static const List<TodayApp> apps = [
    TodayApp(
      name: 'Roblox',
      emoji: '🎮',
      usedMinutes: 62,
      limitMinutes: 45,
    ),
    TodayApp(
      name: 'YouTube',
      emoji: '📺',
      usedMinutes: 38,
      limitMinutes: 60,
    ),
    TodayApp(
      name: 'Duolingo',
      emoji: '📚',
      usedMinutes: 24,
      limitMinutes: 0,
    ),
  ];

  static const ParentTodayData parentToday = ParentTodayData(
    kids: kids,
    selectedIndex: 0,
    kidName: 'Amir',
    usedMinutes: 130,
    limitMinutes: 180,
    topApp: 'Roblox',
    tasksDone: 2,
    tasksTotal: 5,
    coins: 240,
    streakDays: 5,
    apps: apps,
    reviews: [
      TodayReview(
        id: 'r1',
        title: 'Made the bed',
        meta: 'Amir · 12 min ago',
        kidName: 'Amir',
        color: Color(0xFF8100D1),
        coins: 10,
      ),
      TodayReview(
        id: 'r2',
        title: 'Maths homework, p. 41-42',
        meta: 'Layla · 1 h ago',
        kidName: 'Layla',
        color: Color(0xFFEE4FA2),
        coins: 25,
      ),
    ],
  );

  static ParentTasksData parentTasks(S s) => ParentTasksData(
    scopeLine: s.taskScopeLine(s.scopeEveryone, s.taskCount(8)),
    chips: [
      TaskScopeChip(key: 'all', label: s.scopeEveryone, hasAvatar: false),
      const TaskScopeChip(
        key: 'amir',
        label: 'Amir',
        color: Color(0xFF8100D1),
      ),
      const TaskScopeChip(
        key: 'layla',
        label: 'Layla',
        color: Color(0xFFEE4FA2),
      ),
    ],
    selectedScope: 'all',
    laneCounts: const {TaskLane.review: 2, TaskLane.active: 4, TaskLane.done: 2},
    lane: TaskLane.active,
    emptyTitle: s.emptyNoActiveTasks,
    emptyBody: s.emptyActiveBody,
    groups: [
      TaskGroupData(
        name: 'Amir',
        color: const Color(0xFF8100D1),
        summary: s.taskGroupSummary(s.taskCount(2), s.coinCountShort(25)),
        rows: const [
          TaskRowData(
            id: 't3',
            title: 'Tidy the room',
            meta: 'Every day',
            emoji: '🧹',
            lane: TaskLane.active,
            coins: 15,
            childName: 'Amir',
          ),
          TaskRowData(
            id: 't4',
            title: 'Clear the table',
            meta: 'Every day',
            emoji: '🍽️',
            lane: TaskLane.active,
            coins: 10,
            childName: 'Amir',
          ),
        ],
      ),
      TaskGroupData(
        name: 'Layla',
        color: const Color(0xFFEE4FA2),
        summary: s.taskGroupSummary(s.taskCount(2), s.coinCountShort(40)),
        rows: const [
          TaskRowData(
            id: 't5',
            title: 'Walk Rex',
            meta: 'Mon, Wed, Fri',
            emoji: '🐕',
            lane: TaskLane.active,
            coins: 20,
            childName: 'Layla',
          ),
          TaskRowData(
            id: 't7',
            title: 'Practise piano, 20 min',
            meta: 'Weekdays',
            emoji: '🎹',
            lane: TaskLane.active,
            coins: 20,
            childName: 'Layla',
          ),
        ],
      ),
    ],
  );

  static const ParentLimitsData parentLimits = ParentLimitsData(
    kids: [
      LimitsKid(id: 'amir', name: 'Amir', color: Color(0xFF8100D1)),
      LimitsKid(id: 'layla', name: 'Layla', color: Color(0xFFEE4FA2)),
    ],
    selectedKidId: 'amir',
    kidName: 'Amir',
    apps: [
      LimitsApp(
        slug: 'roblox',
        name: 'Roblox',
        emoji: '🎮',
        usedMinutes: 62,
        limitMinutes: 45,
        isEnabled: true,
      ),
      LimitsApp(
        slug: 'youtube-kids',
        name: 'YouTube',
        emoji: '📺',
        usedMinutes: 38,
        limitMinutes: 60,
        isEnabled: true,
      ),
      LimitsApp(
        slug: 'telegram',
        name: 'Telegram',
        emoji: '💬',
        usedMinutes: 21,
        limitMinutes: 0,
        isEnabled: false,
      ),
      LimitsApp(
        slug: 'spotify',
        name: 'Spotify',
        emoji: '🎵',
        usedMinutes: 9,
        limitMinutes: 30,
        isEnabled: true,
      ),
      LimitsApp(
        slug: 'duolingo',
        name: 'Duolingo',
        emoji: '📚',
        usedMinutes: 24,
        limitMinutes: 45,
        isEnabled: true,
      ),
    ],
  );

  static const ParentFamilyData parentFamily = ParentFamilyData(
    parents: [
      FamilyParentRow(
        id: 'pa1',
        name: 'Aisha Karimova',
        subtitle: 'Owner · aisha@icloud.com',
        color: Color(0xFF2D005F),
        isYou: true,
      ),
      FamilyParentRow(
        id: 'pa2',
        name: 'Bekzod Karimov',
        subtitle: 'Parent · bekzod@gmail.com',
        color: Color(0xFF00A6C5),
      ),
      FamilyParentRow(
        id: 'pa3',
        name: 'Nilufar',
        subtitle: 'Invite sent 2 days ago',
        color: Color(0xFFF09A77),
        isPending: true,
      ),
    ],
    children: [
      FamilyChildCard(
        id: 'amir',
        name: 'Amir',
        age: 9,
        color: Color(0xFF8100D1),
        level: 4,
        coins: 240,
        paired: true,
      ),
      FamilyChildCard(
        id: 'layla',
        name: 'Layla',
        age: 12,
        color: Color(0xFFEE4FA2),
        level: 6,
        coins: 415,
        paired: false,
      ),
    ],
  );

  static ChildTodayData kidToday(S s) => ChildTodayData(
    greeting: s.goodEvening,
    name: 'Amir',
    coins: 240,
    questsDone: 2,
    questsTotal: 5,
    openCoins: 30,
    streakDays: 5,
    holdToComplete: true,
    next: const TodayQuest(
      id: 'q1',
      title: 'Tidy the room',
      meta: 'Before dinner',
      emoji: '🧹',
      coins: 15,
    ),
    teaser: const TodayTeaser(
      name: '30 extra minutes of Roblox',
      emoji: '🎮',
      cost: 320,
      coins: 240,
    ),
  );

  static ChildTasksData kidTasks(S s) => ChildTasksData(
    done: 2,
    total: 5,
    pendingCoins: 10,
    emptyMessage: s.noQuestsInCategory,
    categories: [
      ChildTasksCategory(label: s.catAll, selected: true),
      ChildTasksCategory(label: s.catLearn, selected: false),
      ChildTasksCategory(label: s.catFitness, selected: false),
      ChildTasksCategory(label: s.catLogic, selected: false),
    ],
    rows: const [
      ChildTaskRow(
        id: 'q1',
        title: 'Tidy the room',
        meta: 'Before dinner',
        coins: 15,
        state: ChildTaskState.open,
      ),
      ChildTaskRow(
        id: 'q2',
        title: 'Clear the table',
        meta: 'After dinner',
        coins: 10,
        state: ChildTaskState.open,
      ),
      ChildTaskRow(
        id: 'q3',
        title: 'Made the bed',
        meta: 'Sent 18:52',
        coins: 10,
        state: ChildTaskState.sent,
      ),
      ChildTaskRow(
        id: 'q4',
        title: 'Read 20 minutes',
        meta: 'Paid this morning',
        coins: 15,
        state: ChildTaskState.done,
      ),
      ChildTaskRow(
        id: 'q5',
        title: 'Brush teeth, evening',
        meta: 'Health · 21:00',
        coins: 5,
        state: ChildTaskState.open,
      ),
    ],
  );

  static ChildStoreData kidStore(S s) => ChildStoreData(
    coins: 240,
    tabs: [s.storeAppTimeTab, s.storeAvatarTab],
    selectedTab: 0,
    subtitle: s.storeSubtitle,
    footnote: s.askForSomethingNew,
    cards: const [
      StoreCardData(
        id: 'w1',
        emoji: '🍦',
        name: 'Ice cream after school',
        cost: 60,
        affordable: true,
      ),
      StoreCardData(
        id: 'w2',
        emoji: '🎬',
        name: 'Pick the film on Friday',
        cost: 120,
        affordable: true,
      ),
      StoreCardData(
        id: 'w3',
        emoji: '🎮',
        name: '30 extra minutes of Roblox',
        cost: 200,
        affordable: true,
      ),
      StoreCardData(
        id: 'w4',
        emoji: '🏊',
        name: 'Trip to the pool',
        cost: 320,
        affordable: false,
        toGo: 80,
      ),
    ],
  );

  static ChildMeData kidMe(S s) => ChildMeData(
    name: 'Amir',
    faceEmoji: '🦊',
    avatarColor: Color(0xFF8100D1),
    accessoryEmoji: '🧢',
    levelLine: s.levelValue(4),
    xpProgress: 0.64,
    xpCaption: s.percentToNextLevel(64),
    coins: 240,
    questsDone: 42,
    streakDays: 5,
    badges: [
      MeBadge(emoji: '✅', label: s.badgeTasksDone(42)),
      MeBadge(emoji: '🔥', label: s.nDayStreak(5)),
      MeBadge(emoji: '🪙', label: s.badgeCoins(240)),
    ],
  );

  static const ParentTodayData parentTodayEmptyReviews = ParentTodayData(
    kids: kids,
    selectedIndex: 0,
    kidName: 'Amir',
    usedMinutes: 130,
    limitMinutes: 180,
    topApp: 'Roblox',
    tasksDone: 5,
    tasksTotal: 5,
    coins: 240,
    streakDays: 5,
    apps: apps,
    reviews: [],
  );
}
