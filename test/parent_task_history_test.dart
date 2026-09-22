import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/features/parent/data/repositories/parent_task_repository_impl.dart';

class _Tokens implements AuthTokenProvider {
  @override
  String? get currentAccessToken => 'token';

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken() async => 'token';

  @override
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken) async =>
      'token';
}

void main() {
  test(
    'the parent task list requests approved history for the Done feed',
    () async {
      Uri? requested;
      final httpClient = MockClient((request) async {
        requested = request.url;
        return http.Response('{"date":"2026-09-22","tasks":[]}', 200);
      });
      final repository = ParentTaskRepositoryImpl(
        AuthenticatedHttpClient(_Tokens(), client: httpClient),
      );

      await repository.fetchTasks('child-1');

      expect(requested?.path, '/v1/children/child-1/tasks');
      expect(requested?.queryParameters['include_completed_history'], 'true');
    },
  );
}
