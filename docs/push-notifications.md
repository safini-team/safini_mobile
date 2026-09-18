# Push notifications (PRD v4 F-13, F-16)

Every event the API considers worth a push reaches the phone of whoever is signed
in, parent or child, whether Safini is closed, in the background or open. What
is sent, to whom and when is decided on the server; see
`safini-api/docs/notifications.md`. This is the app half.

## What the app does

- **Both shells register.** `ParentMainScreen` and the child shell's
  `_ChildPushBridge` each hold a `PushShell`, which starts `PushService` with
  the app's current language. `PUT /v1/me/push-devices` runs on start, on every
  `onTokenRefresh`, on resume if setup failed, and again when the app language
  changes, because that is the language the next push is written in. The child
  bridge sits outside `ChildAppBlockGate`, so a child still setting up limits
  already hears about new tasks.
- **Closed or backgrounded:** the system draws the push. The API names an
  Android channel and a tag, so a newer push about the same task or child
  replaces the older one.
- **Open:** iOS shows the banner through
  `setForegroundNotificationPresentationOptions`. Android shows nothing on its
  own, so `ForegroundNotifications` posts it through
  `PushNotifications.kt` on the same channel and tag, with `google.message_id`
  in the tap intent. firebase_messaging already resolves that id, so a tap on
  it arrives through `onMessageOpenedApp` exactly like a background one.
- **The screen behind the banner updates too.** `PushService.events` carries
  every push that arrives while the app is open; `OnPush` wraps the screens
  that show what it changed (Tasks and Today on both sides, Limits, Family).
- **A tap opens what the push is about.** `PushEvent` maps the `type` to a
  `PushDestination`; the shell switches tab, and the screen in that tab takes
  the rest from `PushDeepLinks`:

| Push | Opens |
| -- | -- |
| task sent for review | parent Tasks, that child, To review, the review sheet |
| limit reached, protection alert | parent Limits on that child |
| weekly digest | parent Today on that child |
| child connected, second parent joined | parent Family |
| task approved, streak reminder | child Today |
| task sent back, new tasks | child Tasks, and the task itself when it is one |

  A push for the other kind of account (left in the tray from a previous
  sign-in) is dropped. Unknown types and ids that are not plain ids are ignored.
- **Sign-out** cancels retries and listeners, waits for an in-flight
  registration, then `DELETE /v1/me/push-devices` and deletes the FCM token,
  before the session is cleared. A handset that changes accounts moves its
  token server-side on the next registration.

## Alerts in parent Settings

The artboard's three switches (New submissions, Limit reached, Weekly digest)
are backed by `GET/PATCH /v1/me/notification-preferences`, per account. A switch
flips at once and goes back with a toast if the save fails. When the phone
itself blocks Safini's notifications a red row says so and opens the system
page (`ACTION_APP_NOTIFICATION_SETTINGS` on Android, `app-settings:` on iOS);
it disappears on resume once they are allowed. Protection alerts have no switch.

## Android details

`PushNotifications.createChannels` creates `safini_protection`, `safini_tasks`
(both high importance), `safini_screen_time`, `safini_family` and
`safini_reminders`, named in en/ru/uz. Importance cannot be raised after a
channel exists, so it is decided there for good. `ic_stat_safini` is the Time
Coin's ring and tick as a silhouette, set as FCM's default icon and on the
enforcement service's ongoing notification; the launcher icon it replaces drew
as a white square.

## iOS

Firebase carries iOS through the APNs bridge, and the app code is done: foreground
banners and tap routing were verified on the iPhone 17 simulator with
`xcrun simctl push` and an FCM-shaped payload (`gcm.message_id` at the top level,
or firebase_messaging ignores it). Real delivery still needs, in order:

1. The Push Notifications capability on App ID `com.safini.app`.
2. An APNs auth key uploaded to Firebase project `safini-app`.
3. `aps-environment` in `Runner.entitlements`.

Step 3 waits for step 1: adding the entitlement before the capability exists
breaks signing for anyone whose Xcode account cannot change the App ID.

## Config files

`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` are
client config for Firebase project `safini-app` (sender id 82130591868, the same
Google Cloud project as Google Sign-In). They are committed on purpose. The
service-account key is not: it lives only on the API server.

## Verified

`flutter test` covers payload parsing and routing for every type, the shells'
tab choice, foreground posting over the method channel, registration, locale
changes, sign-out ordering and the Settings switches.

On the Safini_QA emulator (Android 17) against a local API with real FCM
delivery and a test family:

- Parent, app open: a child's submission posted on `safini_tasks` with tag
  `task:<id>`, and the Tasks badge and Today's review card updated without a
  refresh. Tapping it opened the review sheet for that task.
- Parent, backgrounded and with the process killed: the push arrived; tapping
  it opened the review sheet, and "out of Roblox time" cold-started into Limits
  on that child.
- Settings: switches saved to the server; with notifications denied the red row
  showed and opened the system page.
- Child, Uzbek: approval, "sent back" with the parent's note, and two new tasks
  merged into "2 ta yangi vazifa". The coin balance moved while Today was open,
  and tapping "sent back" opened that task to redo.

On the iPhone 17 simulator, parent in Russian: the permission prompt, the
banner over the open app with the badge updating behind it, and a tap opening
the review sheet.
