import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:safini/core/network/app_client_headers.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppClientHeaders headers({
    String version = '1.0.9',
    String build = '33',
    String platform = 'android',
  }) => AppClientHeaders(
    readInfo: () async => (version: version, build: build),
    detectPlatform: () => platform,
  );

  test('headers read the injected build, not a hardcoded string', () async {
    expect(await headers().resolve(), {
      AppClientHeaders.version: '1.0.9',
      AppClientHeaders.build: '33',
      AppClientHeaders.platform: 'android',
    });
  });

  test('iOS sends platform ios', () async {
    expect(
      (await headers(platform: 'ios').resolve())[AppClientHeaders.platform],
      'ios',
    );
  });

  test('a failed PackageInfo read still sends platform', () async {
    final resolved = await AppClientHeaders(
      readInfo: () async => throw StateError('plugin missing'),
      detectPlatform: () => 'android',
    ).resolve();
    expect(resolved[AppClientHeaders.version], '');
    expect(resolved[AppClientHeaders.build], '');
    expect(resolved[AppClientHeaders.platform], 'android');
  });

  test('detectAppPlatform is android or ios', () {
    expect(detectAppPlatform(), anyOf('android', 'ios'));
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(detectAppPlatform(), anyOf('android', 'ios'));
  });

  test('Dio interceptor attaches the three headers to every request', () async {
    late RequestOptions seen;
    final dio = Dio()
      ..interceptors.add(AppClientHeadersInterceptor(headers()))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            seen = options;
            handler.resolve(Response(requestOptions: options, data: {}));
          },
        ),
      );

    await dio.get<void>('/v1/me');

    expect(seen.headers[AppClientHeaders.version], '1.0.9');
    expect(seen.headers[AppClientHeaders.build], '33');
    expect(seen.headers[AppClientHeaders.platform], 'android');
  });

  test('authenticated HTTP attaches the three headers', () async {
    Map<String, String>? seen;
    final client = AuthenticatedHttpClient(
      _Tokens(),
      headers: headers(platform: 'ios'),
      client: MockClient((request) async {
        seen = request.headers;
        return http.Response('ok', 200);
      }),
    );

    await client.get(Uri.parse('https://api.safini.fun/v1/me'));

    final sent = seen!;
    expect(sent[AppClientHeaders.version], '1.0.9');
    expect(sent[AppClientHeaders.build], '33');
    expect(sent[AppClientHeaders.platform], 'ios');
    expect(sent['Authorization'], 'Bearer tok');
  });
}

class _Tokens implements AuthTokenProvider {
  @override
  bool get hasSession => true;

  @override
  String? get currentAccessToken => 'tok';

  @override
  Future<String?> getAccessToken() async => 'tok';

  @override
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken) async =>
      null;
}
