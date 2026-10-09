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
field, e.g. `1.0.9+33`. Do not edit that line by hand.

```
make version          # current number and the rules
make bump-build       # 1.0.9+33 -> 1.0.9+34   every store upload
make bump-patch       # 1.0.9+33 -> 1.0.10+34  a release of fixes
make bump-minor       # 1.0.9+33 -> 1.1.0+34   user-visible features
make version-check    # same guard CI runs on PRs
```

- `1.0.9` → `versionName` (user-visible version)
- `33` → `versionCode` (Play Store requires this to strictly increase on
  every upload, including internal/beta tracks)

Both are read into Gradle automatically via `flutter.versionName` /
`flutter.versionCode`, so there is nothing to edit in `android/`. iOS reads the same
field as `CFBundleShortVersionString` / `CFBundleVersion`, and Settings shows
it as `Safini 1.0.9 (33)` straight from the installed binary.

The rule, for both stores:

- Feature and fix PRs must not touch `version:`. Land the change, `git pull`
  on `main`, then bump. Mixing a bump into a stale branch is how a Play
  upload gets a colliding `versionCode` or a marketing version that goes
  backwards (see PR #109 vs `main`). CI fails that class of PR.
- Every upload (internal, TestFlight, beta, production) gets the next build
  number: `+33` → `+34`. Never reuse one, even for a rebuild of the same code.
  `make bump-build` / `make build-android` / `make build-ios` refuse unless
  you are on an up-to-date `main` (`FORCE=1` overrides). Commit the bumped
  `pubspec.yaml` once the upload is accepted.
- A release of fixes: `make bump-patch`. New features: `make bump-minor`.
  Each of those also increments `+N`, because Play still needs a new
  `versionCode`.

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
