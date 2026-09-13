# Android release / publishing

App ID: `com.safini.app`

## 1. One-time: signing setup

Release builds are signed with a keystore that is **not** in this repo
(`android/key.properties` and the `.jks`/`.keystore` file are gitignored on
purpose — signing keys never go into git).

To build a signed release locally:

1. Get the real keystore file + credentials from the team password manager.
2. `cp android/key.properties.example android/key.properties`
3. Fill in `storePassword`, `keyPassword`, `keyAlias`, and `storeFile`
   (absolute path to wherever you saved the `.jks` file).

Without this, `signingConfigs.release` in
[app/build.gradle.kts](app/build.gradle.kts) has no credentials and the
release build fails at the signing step. Debug builds are unaffected — they
use the shared `app/debug.keystore` committed in this repo, so every dev's
debug build has the same SHA-1 for Google Sign-In.

## 2. Bump the version

Version lives in one place: [`pubspec.yaml`](../pubspec.yaml) `version:`
field, e.g. `1.0.1+19`.

- `1.0.1` → `versionName` (user-visible version)
- `19` → `versionCode` (Play Store requires this to strictly increase on
  every upload, including internal/beta tracks)

Both are read into Gradle automatically via `flutter.versionName` /
`flutter.versionCode`, so there is nothing to edit in `android/`. iOS reads the same
field as `CFBundleShortVersionString` / `CFBundleVersion`, and Settings shows
it as `Safini 1.0.1 (19)` straight from the installed binary.

The rule, for both stores:

- Every upload (internal, TestFlight, beta, production) gets the next build
  number: `+19` → `+20`. Never reuse one, even for a rebuild of the same code.
  `make build-android` and `make build-ios` do this bump for you before
  building; commit the bumped `pubspec.yaml` once the upload is accepted.
- A release of fixes bumps the last part of the version: `1.0.1` → `1.0.2`.
  New features bump the middle part: `1.0.x` → `1.1.0`.

## 3. Build the release artifact

From the repo root:

```
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab` — this is what
gets uploaded to Play Console.

For a signed APK instead (e.g. manual sideload testing):

```
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## 4. Upload

Upload the `.aab` to Play Console under the appropriate track (internal
testing / production). There is no CI pipeline for this yet — it's a manual
upload.
