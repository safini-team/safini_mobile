/// One place that decides what to call someone when the backend has no name
/// for them.
///
/// `GET /v1/me` returns `display_name: null` for anyone who signed up with
/// email, because the API only fills it from Google's `full_name` / `name`
/// metadata. The app used to paper over that with the literal string
/// `'NoName'` in ten different files, which is what the parent then read on
/// their own Family screen.
///
/// The rules, in order:
///  1. the name the server gave us, trimmed
///  2. the local part of the email — `safini.team@gmail.com` becomes
///     `safini.team`, which is at least recognisably theirs
///  3. empty, so the widget can put a localized placeholder in. Nothing here
///     returns display text of its own, because these run in DTOs and models
///     with no `BuildContext` and therefore no way to translate.
library;

String resolveDisplayName(Object? rawName, {Object? email}) {
  final name = rawName?.toString().trim() ?? '';
  if (name.isNotEmpty) return name;
  return emailLocalPart(email);
}

/// `safini.team@gmail.com` -> `safini.team`. Empty when there is no `@`.
String emailLocalPart(Object? email) {
  final value = email?.toString().trim() ?? '';
  final at = value.indexOf('@');
  if (at <= 0) return '';
  return value.substring(0, at);
}
