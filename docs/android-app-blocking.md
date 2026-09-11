# Android App Blocking — SAF-163

## Scope and rollout

Android catalog apps: YouTube Kids, Roblox, Brawl Stars, Minecraft, YouTube,
TikTok, Instagram and Telegram. SAF-165 adds the four missing package mappings
in API migration `20260908_0026` and the mobile installed-app picker. These map
the standard Google Play packages; Lite/regional variants and cloned apps need
separate mappings and testing.
One paired enforcement device per child. iOS enforcement and arbitrary installed
packages (SAF-157) are outside this implementation.

Deploy the companion API and migrations through `20260908_0026` first, then distribute this
mobile build. The first signed-in child session pairs the native service and asks
for Usage Access and Display Over Other Apps. Until both are granted and the first
snapshot is received, setup remains visible. Explicit sign-out stops enforcement,
clears cached data and attempts credential revocation even if offline.

The parent can independently choose unlimited, daily allowance, manual block and
whether coins may purchase time. Manual block overrides purchases and unlimited;
the overall screen-time cap also applies. Parent changes reach an online child
on the next minute sync. Offline devices keep their last known rules.

## Runtime and contract

`AppBlockForegroundService` owns enforcement independently of Flutter. Every
500 ms it reads new UsageStats events, accounts foreground time, and shows a native
localized overlay at exhaustion. Background and covered time do not spend credit.
It checkpoints elapsed usage every five seconds and reconciles cumulative server
usage without resetting local counters. A process crash can lose up to five
seconds of the most recent checkpoint. Budgets reset at family-local midnight;
yesterday's purchased minutes expire. Usage reports use whole minutes and retain
seven local dates for offline retries.

Non-secret rules and usage use device-protected storage. Boot/package replacement
restarts the foreground service when previously enabled. Boot clears the last
foreground observation while preserving saved usage, so an abrupt power loss
cannot charge the powered-off interval. Before the first unlock,
Android cannot supply UsageStats; enforcement resumes after unlock. The native
credential is encrypted with an Android Keystore key in credential-protected
storage. No Supabase refresh token is shared with the native network worker.

All paths below are under `/v1/children/{child_id}/enforcement`:

| Method/path | Authentication | Purpose |
| --- | --- | --- |
| POST `/session` | Claimed child's Supabase bearer | Pair/rotate a scoped device credential |
| POST `/sync` | `X-Safini-Device-Token` | Cumulative usage, permission heartbeat, fresh rules/wallet |
| POST `/redeem` | Device credential | Idempotent purchase; UUID plus displayed price/minutes |
| DELETE `/session` | Device credential | Revoke on sign-out |
| GET `/status` | Authorized parent/child bearer | Active, attention required, offline or not configured |

The native block screen and Flutter shop use the same purchase path. A purchase
first syncs usage, submits a durable request UUID, checks the displayed price on
the server and applies the returned snapshot immediately. A lost response can be
retried without a second charge. Purchases require connectivity; spending already
cached minutes does not. Device credentials are hashed server-side, rotate on
pairing, expire after 30 days without sync, and cannot access general family APIs.

## Block screen

`BlockOverlay` draws the SAF-166 "Takeover" design (Claude Design project "App blocked
screen redesign", direction 1a): full-bleed pine, one mascot mood per state, and a sand
sheet with the actions. Colours and curves mirror `lib/core/theme`; copy lives in
`res/values{,-ru,-uz}/strings.xml` and follows the child's app language, not the system's.

| State | When | Mascot |
| --- | --- | --- |
| Resting | app budget spent; unlock offered when coins may buy time | firm |
| Short of coins | coin unlock allowed, balance below the price | encouraging |
| Paused | parent's manual block | stop |
| That's all for today | overall screen-time cap spent; purchases are refused | relaxed |
| Confirm | sheet over Resting before any spend | (Resting's) |
| Unlocked | purchase went through; stays up until the child leaves it | superhero |
| Couldn't reach / unlock | purchase failed; a changed price is confirmed again instead | unimpressed |

The design's task suggestions, parent name and bedtime frame need data the enforcement
snapshot does not carry yet, so the sheet links to Safini's tasks instead. iOS shields are
SAF-155. `testConfigureLocalFixture` takes `-e language ru|uz` to review a translation.

## Verification

- September 8 audit: 290 Flutter tests and analyzer pass (one existing skipped test).
- Native JVM: seven policy tests; Android debug and test APK builds pass.
- Emulator: Android 15/API 35; native persistence/reset, boot-observation and family-midnight tests; foreground budget
  exhaustion; visible block overlay; purchase deducts one price and unlocks;
  automatic service recovery after a cold reboot; offline purchased-time
  exhaustion and non-charging offline purchase failure; revoked Usage Access
  reaches the parent status endpoint as attention required.
- September 8 installed app audit: signed-in child pairing and native startup;
  one-minute budget exhaustion; 100-coin purchase unlocks with one ledger charge;
  purchased time exhausts offline; offline purchase reports failure without charging.
  Real FCM delivery and signed-in parent navigation are recorded in
  [parent push verification](parent-push-alerts.md).
- API: full suite against migrated disposable Postgres, including pairing access,
  scope isolation, duplicate purchase retries, changed prices, manual blocking,
  historical reports and permission heartbeat transitions.

Run Flutter checks with `flutter analyze` and `flutter test`. Run native checks:

```sh
flutter build apk --debug
android/gradlew -p android :app:testDebugUnitTest :app:assembleDebugAndroidTest
adb install -r build/app/outputs/apk/debug/app-debug.apk
adb install -r build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk
adb shell am instrument -w -e class com.safini.app.EnforcementDeviceTest com.safini.app.test/com.safini.app.FixtureRunner
```

The device test replaces local enforcement state: run only on a disposable
emulator/test installation. `FixtureActivity` is a separate launchable test app;
map its package only in a disposable API database, never in the production catalog.

## Release gates and limits

- SAF-164 parent push is implemented. SAF-165 fixes registration after sign-out,
  offline registration retries, and backend delivery per recipient. Firebase
  credentials are configured on the API server. A heartbeat older than three
  minutes means offline/unknown; the API defaults to another two minutes grace
  before alerting. Check any deployment override when upgrading the backend.
- Roll out the audited API and mobile changes together; the September 8 server
  audit found no paired child devices, so it does not establish live family use.
- SAF-139: Samsung, Xiaomi and budget-device overnight survival, battery use and
  physical-device permission/reboot checks. Emulator success does not prove these.
- Google Play review of the `specialUse` foreground service declaration, overlay
  use and the parental-control disclosures is still required.
- Force-stop, removing permissions, uninstalling, safe mode, system time changes,
  split-screen and apps that hide third-party overlays can defeat or weaken this
  consumer enforcement model. It is not device-owner lockdown. Multi-window and
  overlay-hiding apps require explicit device QA before expanding the catalog.

Android references: [foreground service types](https://developer.android.com/develop/background-work/services/fgs/service-types),
[UsageStatsManager unlock behavior](https://developer.android.com/reference/android/app/usage/UsageStatsManager).
