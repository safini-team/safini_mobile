# Safini

A Flutter app for the Safini parent and child experience.

## Sign-in

The login screen offers Apple (iOS only), Google, and email. Email is
sign-in only: the app has no email sign-up, so an email account has to be
created first in the Supabase dashboard (Authentication -> Users -> Add user,
with "Auto Confirm User" checked). Email sign-in ships in every build,
release included.

Demo accounts:

| Role | Email | Password |
| --- | --- | --- |
| Parent | `safini.team@gmail.com` | `stopscrolling` |
| Child | `safini.coder@gmail.com` | `stopscrolling` |

Do not reuse this password for real Google accounts or administrative access.
For App Review, provide the account email and password through App Store
Connect's private review information, not through source control.

## Localization

Translation workflow and locale setup are documented in `commands/localization.md`.

## Store version

`pubspec.yaml` `version:` (`1.0.9+33`) is the only store version. Play
`versionCode` and iOS `CFBundleVersion` are the `+N` suffix and must go up
on every upload. Do not bump it in a feature PR.

```
make version
make bump-build    # every Play / TestFlight upload, on an up-to-date main
make bump-patch    # 1.0.9 -> 1.0.10
make bump-minor    # 1.0.9 -> 1.1.0
```

Details: [`android/DEPLOY.md`](android/DEPLOY.md).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
 
