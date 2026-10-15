import 'package:safini/core/config/supabase_config.dart';

class ApiConst {
  /// Resolved in one place, see [SupabaseConfig.apiBaseUrl]. Override a debug
  /// build with `--dart-define=API_BASE_URL=http://10.0.2.2:8000` or with
  /// `assets/env/app.env`; both move every call, not just the Dio ones.
  static String get baseUrl => SupabaseConfig.apiBaseUrl;
  static const String me = '/v1/me';

  /// GET - public min/recommended versions for this binary (SAF-203).
  /// Auth is optional; the gate runs before sign-in. Matches
  /// safini-api `GET /v1/system/version-policy`. Do not vendor this path
  /// in `api.json` until production serves it (CI diffs the spec against
  /// production).
  static const String versionPolicy = '/v1/system/version-policy';

  /// PUT/DELETE/GET - this handset's push token, parent or child, so
  /// notifications reach whoever is signed in while the app is closed.
  static const String pushDevices = '/v1/me/push-devices';

  /// GET/PATCH - the Alerts switches on parent Settings.
  static const String notificationPreferences =
      '/v1/me/notification-preferences';
  static const String currentFamily = '/v1/families/current';

  /// GET - the family's Safini Pro plan, whoever paid and however (SAF-208).
  static const String familySubscription = '/v1/families/current/subscription';

  /// POST - an App Store purchase or restore, as StoreKit's signed
  /// transaction, so the server makes the family Pro (SAF-211).
  static const String appleTransactions = '/v1/billing/apple/transactions';
  static const String promoRedeem = '/v1/billing/promo-codes/redeem';
  static const String webLink = '/v1/billing/web-link';
  static const String children = '/v1/families/current/children';

  static String childById(String childId) => '/v1/children/$childId';
  static String childTasks(String childId) => '/v1/children/$childId/tasks';
  static String task(String taskId) => '/v1/tasks/$taskId';
  static String childHome(String childId) => '/v1/children/$childId/home';

  /// GET/POST the child's friends. DELETE one friend at [childFriend].
  /// SAF-202. The list has no rank and no wallet.
  static String childFriends(String childId) => '/v1/children/$childId/friends';
  static String childFriend(String childId, String friendChildId) =>
      '/v1/children/$childId/friends/$friendChildId';
  static String childToday(String childId) => '/v1/children/$childId/today';
  static String submitTask(String taskId) => '/v1/tasks/$taskId/submit';
  static String taskProofUploadUrl(String childId) =>
      '/v1/children/$childId/task-proofs/upload-url';
  static String taskVoiceUploadUrl(String childId) =>
      '/v1/children/$childId/task-voice/upload-url';
  static String taskVoice(String taskId) => '/v1/tasks/$taskId/voice';
  static String reviewTask(String taskId) => '/v1/tasks/$taskId/review';
  static String childDashboard(String childId) =>
      '/v1/children/$childId/dashboard';
  static String childAvatar(String childId) => '/v1/children/$childId/avatar';
  static String childStore(String childId) => '/v1/children/$childId/store';
  static String redeemAppTime(String childId) =>
      '/v1/children/$childId/redemptions/app-time';
  static String redeemAvatarItem(String childId) =>
      '/v1/children/$childId/redemptions/avatar-items';

  // Prizes (SAF-190)
  static String childPrizes(String childId) => '/v1/children/$childId/prizes';
  static String childWishes(String childId) => '/v1/children/$childId/wishes';
  static String prize(String prizeId) => '/v1/prizes/$prizeId';
  static String askForPrize(String prizeId) => '/v1/prizes/$prizeId/requests';
  static const String prizeRequests = '/v1/prize-requests';

  /// Fini, the AI assistant (SAF-266). Parent-only.
  static String finiSettings(String childId) =>
      '/v1/children/$childId/fini/settings';
  static String finiGoals(String childId) => '/v1/children/$childId/fini/goals';
  static String finiGoal(String goalId) => '/v1/fini/goals/$goalId';

  /// The parent skips the rest of a budget goal's plan (SAF-274).
  static String finiGoalJump(String goalId) => '/v1/fini/goals/$goalId/jump';

  /// Budget goals as shared pools, with today's minutes (SAF-274).
  static String finiPools(String childId) => '/v1/children/$childId/fini/pools';
  static String finiProposals(String childId) =>
      '/v1/children/$childId/fini/proposals';
  static String finiActivity(String childId) =>
      '/v1/children/$childId/fini/activity';
  static String finiDecision(String proposalId, String action) =>
      '/v1/fini/proposals/$proposalId/$action';
  static const String finiInbox = '/v1/fini/inbox';

  /// GET the family's 14-day Fini trial; POST `start` begins it (SAF-273).
  static const String finiTrial = '/v1/fini/trial';
  static const String finiTrialStart = '/v1/fini/trial/start';

  /// A child asks a parent before signing out (SAF-191).
  static String childSignoutRequests(String childId) =>
      '/v1/children/$childId/signout-requests';
  static String childSignoutRequest(String childId, String requestId) =>
      '/v1/children/$childId/signout-requests/$requestId';
  static const String familySignoutRequests =
      '/v1/families/current/signout-requests';
  static String approvePrizeRequest(String requestId) =>
      '/v1/prize-requests/$requestId/approve';
  static String declinePrizeRequest(String requestId) =>
      '/v1/prize-requests/$requestId/decline';

  /// GET/POST — per-app usage + remaining minutes for a child.
  static String childAppUsage(String childId) =>
      '/v1/children/$childId/app-usage';

  /// GET — every app the child used today, rule or not, most used first.
  static String childDeviceUsage(String childId) =>
      '/v1/children/$childId/device-usage';

  /// PUT — upsert a controlled-app rule (limit / enabled) for a child.
  static String childAppRule(String childId, String appSlug) =>
      '/v1/children/$childId/app-rules/$appSlug';

  /// PUT (child uploads) / GET (parent or child reads) — the full list of apps
  /// installed on the child's device. Only a child token may write (parent PUT
  /// → 403). See BACKEND_TODO.md #4.
  static String childInstalledApps(String childId) =>
      '/v1/children/$childId/installed-apps';

  /// PUT (child) / GET (parent or child) — iOS Screen Time status: auth state +
  /// token counts + shield flag. The iOS analogue of `installed-apps` (Apple
  /// forbids an app list). Not deployed yet — see BACKEND_TODO.md #5 / SAF-154.
  static String childScreenTimeStatus(String childId) =>
      '/v1/children/$childId/screen-time-status';
}
