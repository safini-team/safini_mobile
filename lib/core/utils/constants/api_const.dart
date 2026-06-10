class ApiConst {
  static const String baseUrl = 'https://api.safini.fun';
  static const String me = '/v1/me';
  static const String currentFamily = '/v1/families/current';
  static const String children = '/v1/families/current/children';

  static String childById(String childId) => '/v1/children/$childId';
  static String childTaskTemplates(String childId) =>
      '/v1/children/$childId/task-templates';
  static String childDashboard(String childId) =>
      '/v1/children/$childId/dashboard';
}
