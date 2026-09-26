import 'package:safini/core/notifications/push_deep_links.dart';

/// Every push the API sends, by the `type` in its data.
///
/// Mirrors `KINDS` in safini-api `app/services/notifications.py`, plus the
/// protection alert, which keeps its own payload. A type this build does not
/// know is ignored: the system still shows the notification, and tapping it
/// just opens the app.
enum PushType {
  protectionAlert('protection_alert'),
  taskSubmitted('task_submitted'),
  appLimitReached('app_limit_reached'),
  screenTimeReached('screen_time_reached'),
  weeklyDigest('weekly_digest'),
  childConnected('child_connected'),
  parentJoined('parent_joined'),
  taskApproved('task_approved'),
  taskRejected('task_rejected'),
  tasksAssigned('tasks_assigned'),
  streakReminder('streak_reminder'),
  prizeRequested('prize_requested'),
  wishRequested('wish_requested'),
  prizeAdded('prize_added'),
  prizeGiven('prize_given'),
  prizeDeclined('prize_declined'),
  signoutRequested('signout_requested'),
  setupReminder('setup_reminder');

  const PushType(this.wire);

  final String wire;

  static PushType? parse(Object? value) {
    for (final type in values) {
      if (type.wire == value) return type;
    }
    return null;
  }
}

/// Where tapping a push lands. Parent and child shells each take only their own.
enum PushDestination {
  parentToday,
  parentTasks,
  parentLimits,
  parentFamily,
  childToday,
  childTasks,
  childStore;

  bool get isParent => index <= parentFamily.index;
}

class PushTarget {
  const PushTarget(this.destination, {this.childId, this.taskId});

  final PushDestination destination;
  final String? childId;
  final String? taskId;

  @override
  bool operator ==(Object other) =>
      other is PushTarget &&
      other.destination == destination &&
      other.childId == childId &&
      other.taskId == taskId;

  @override
  int get hashCode => Object.hash(destination, childId, taskId);

  @override
  String toString() => 'PushTarget($destination, $childId, $taskId)';
}

/// One push the app understood.
class PushEvent {
  const PushEvent(this.type, {this.childId, this.taskId});

  final PushType type;
  final String? childId;
  final String? taskId;

  /// Null for anything that is not a Safini push, or that names ids this
  /// build cannot trust. A payload never steers the app anywhere else.
  static PushEvent? fromData(Map<String, dynamic> data) {
    final type = PushType.parse(data['type']);
    if (type == null) return null;
    if (type == PushType.protectionAlert) {
      // Protection alerts predate the generic payload; their link is the
      // source of truth and `child_id` only a fallback.
      final link = data['deep_link'];
      final uri = link is String ? Uri.tryParse(link) : null;
      final fromLink = uri == null ? null : PushDeepLinks.parseChildId(uri);
      final childId = fromLink ?? _id(data['child_id']);
      return childId == null ? null : PushEvent(type, childId: childId);
    }
    return PushEvent(
      type,
      childId: _id(data['child_id']),
      taskId: _id(data['task_id']),
    );
  }

  static final RegExp _idShape = RegExp(r'^[A-Za-z0-9-]{1,64}$');

  static String? _id(Object? value) =>
      value is String && _idShape.hasMatch(value) ? value : null;

  PushTarget get target => switch (type) {
    PushType.protectionAlert ||
    PushType.appLimitReached ||
    PushType.screenTimeReached => PushTarget(
      PushDestination.parentLimits,
      childId: childId,
    ),
    PushType.taskSubmitted => PushTarget(
      PushDestination.parentTasks,
      childId: childId,
      taskId: taskId,
    ),
    PushType.weeklyDigest ||
    PushType.prizeRequested ||
    PushType.wishRequested ||
    PushType.signoutRequested => PushTarget(
      PushDestination.parentToday,
      childId: childId,
    ),
    // The unpaired child's card is on Family, with their code a tap away.
    PushType.childConnected ||
    PushType.parentJoined ||
    PushType.setupReminder => PushTarget(
      PushDestination.parentFamily,
      childId: childId,
    ),
    PushType.taskApproved ||
    PushType.streakReminder => const PushTarget(PushDestination.childToday),
    PushType.taskRejected || PushType.tasksAssigned => PushTarget(
      PushDestination.childTasks,
      taskId: taskId,
    ),
    PushType.prizeAdded ||
    PushType.prizeGiven ||
    PushType.prizeDeclined => const PushTarget(PushDestination.childStore),
  };
}
