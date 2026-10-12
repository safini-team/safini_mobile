import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/constants/app_constants.dart';

void main() {
  test('English legal pages stay at the root', () {
    expect(
      AppConstants.localizedLegalUrl(AppConstants.privacyPolicyUrl, 'en'),
      'https://safini.fun/privacy-policy',
    );
  });

  test('each app language opens its own legal page', () {
    for (final code in ['ru', 'uz', 'ky', 'kk']) {
      expect(
        AppConstants.localizedLegalUrl(AppConstants.termsOfUseUrl, code),
        'https://safini.fun/$code/terms-of-service',
      );
    }
  });

  test('a language without its own page falls back to English', () {
    expect(
      AppConstants.localizedLegalUrl(AppConstants.termsOfUseUrl, 'de'),
      'https://safini.fun/terms-of-service',
    );
  });
}
