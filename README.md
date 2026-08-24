# Safini

A Flutter app for the Safini parent and child experience.

## Local debug and App Review sign-in

Email/password sign-in is available to make local development and App Review
testing faster than configuring Google Sign-In for every test environment.
Regular users continue to use Google Sign-In.

Use these pre-created test accounts:

| Role | Email | Password |
| --- | --- | --- |
| Parent | `safini.team@gmail.com` | `stopscrolling` |
| Child | `safini.coder@gmail.com` | `stopscrolling` |

These credentials are only for the pre-created Safini test identities. Do not
reuse this password for real Google accounts or administrative access.

For App Review, provide the selected account email and password through App
Store Connect's private review information, not through source control.

Email sign-in is enabled automatically in debug builds. For an App Review
release build, enable it explicitly:

```bash
flutter build ipa --release \
  --dart-define=ENABLE_EMAIL_SIGN_IN=true
```

## Localization

Translation workflow and locale setup are documented in `commands/localization.md`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
 
