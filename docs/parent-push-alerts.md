# Parent push alerts - SAF-164 (F-13)

The parent app polls `GET /children/{id}/enforcement/status` while it is open.
This is the other half: a notification that reaches a parent whose app is
closed. The API side and the alert wording live in
`safini-api/docs/parent-protection-alerts.md`.

## What the app does

- The **parent** surface registers, not the child one. `ParentMainScreen` starts
  `ParentPushService` in `initState`, so the child app never asks for
  notification permission it has no use for.
- `PUT /v1/me/push-devices` on start and again on every `onTokenRefresh`.
- `DELETE /v1/me/push-devices` during sign-out, before the session is cleared,
  because revoking needs a usable bearer token. The next parent to sign in on a
  shared handset does not inherit the previous one's alerts.
- A tapped alert carries `deep_link=safini://children/<child id>/protection`.
  `PushDeepLinks` parks the child id, `AppRouter` sends the launch through the
  splash screen (the only place that knows whether this device is signed in),
  and the Apps tab opens on the child the alert names.
- Anything that is not `type=protection_alert`, and any link that is not exactly
  the shape above, is ignored.

Firebase is optional at runtime: `Firebase.initializeApp()` failing leaves
`ParentPushService` unregistered and every caller checks `getIt.isRegistered`
first, so a build without the config files behaves as it did before push.

## Config files

`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` are
client config for Firebase project `safini-app` (sender id 82130591868, the same
Google Cloud project as Google Sign-In). They are committed on purpose. The
service-account key is not: it lives only on the API server.

## Verified on the emulator

Pixel 10a, Android 17, Google Play services, debug build:

- A real FCM message sent through the API's own sender reached the device with
  the app backgrounded, and posted on channel `safini_protection` at importance
  4, with the Russian copy for a Russian device locale.
- `adb shell am start -a android.intent.action.VIEW -d
  "safini://children/<id>/protection"` resolves to `MainActivity`, so the new
  intent filter works.
- `flutter test` covers registration, refresh, revocation and message parsing
  against a recording Dio adapter; nothing there needs a network.

Not proven on device: the Apps tab landing on the right child, which needs a
signed-in parent account, and everything on iOS.

## Left for iOS

Firebase carries iOS through the APNs bridge, so no second provider is needed,
but before an iOS parent can receive anything:

1. Enable the Push Notifications capability for `com.safini.app` in the Apple
   developer portal.
2. Upload an APNs auth key to the Firebase project.
3. Add `aps-environment` to `Runner.entitlements`.

Step 3 is deliberately not in this branch: adding the entitlement before step 1
breaks provisioning for everyone building the app.
