class ApiConst {
  static const String baseUrl = 'https://api.safini.fun';
  static const String me = '/v1/me';
  static const String currentFamily = '/v1/families/current';
  static const String children = '/v1/families/current/children';

  static String childById(String childId) => '/v1/children/$childId';
  static String childTasks(String childId) => '/v1/children/$childId/tasks';
  static String task(String taskId) => '/v1/tasks/$taskId';
  static String childHome(String childId) => '/v1/children/$childId/home';
  static String childToday(String childId) => '/v1/children/$childId/today';
  static String submitTask(String taskId) => '/v1/tasks/$taskId/submit';
  static String taskProofUploadUrl(String childId) =>
      '/v1/children/$childId/task-proofs/upload-url';
  static String reviewTask(String taskId) => '/v1/tasks/$taskId/review';
  static String childDashboard(String childId) =>
      '/v1/children/$childId/dashboard';
  static String childAvatar(String childId) => '/v1/children/$childId/avatar';
  static String childStore(String childId) => '/v1/children/$childId/store';
  static String redeemAppTime(String childId) =>
      '/v1/children/$childId/redemptions/app-time';
  static String redeemAvatarItem(String childId) =>
      '/v1/children/$childId/redemptions/avatar-items';
}
