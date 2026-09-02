# iOS Screen Time blocking — implementation status

This is the iOS counterpart to the Android app-blocking engine
(`observation/app_blocking.md`). The mechanism is completely different — see
`observation/child_get_apps.md` §6 and `observation/screenzen_research.md` for
the "why", and `observation/block_flow.md` for how the parent/child setup flow
forks by platform. This file tracks **what is actually built** and **what
remains**.

## TL;DR

- **Increment 1 (done, in this branch):** authorize → pick apps in Apple's
  `FamilyActivityPicker` → apply / clear the **system shield** immediately, all
  from the main app target. A debug screen exercises the whole flow.
- **Hard blocker:** Screen Time APIs stay inert until Family Controls is in
  **both** the provisioning profile and `Runner.entitlements`. Development
  authorize is verified on device. Confirm distribution (TestFlight) on SAF-135.
- **Increment 2 (deferred):** scheduling + a branded overlay require separate
  Xcode **app-extension targets** and an **App Group** (must be added in Xcode).

## What Screen Time can and cannot do

- **No app list, ever.** iOS does not let an app enumerate installed apps. The
  child picks apps in Apple's own `FamilyActivityPicker`, which returns **opaque
  tokens** (`ApplicationToken` / `ActivityCategoryToken`) — no names, no bundle
  ids. So the UI shows *counts*, not names. This is a platform limit, not a TODO.
- **The overlay is Apple's**, drawn by the OS over a shielded app. We don't draw
  it. We can only brand it (title/subtitle/icon/≤2 buttons) via an extension.
- **Per-app usage is not readable** by us either (only `DeviceActivity`
  thresholds fire callbacks). So the Android "used minutes / remaining" reporting
  has no direct iOS equivalent.

## Files (Increment 1)

Native (Runner app target):

- `ios/Runner/Runner.entitlements` — `com.apple.developer.family-controls`
  (must match the profile; see helper-communication note in the file).
- `ios/Runner.xcodeproj/project.pbxproj` — wires `CODE_SIGN_ENTITLEMENTS` into
  all three Runner configs (Debug/Release/Profile) and adds
  `ScreenTimeManager.swift` to the build.
- `ios/Runner/ScreenTimeManager.swift` — the engine:
  - `authorizationStatus()` → `notDetermined | denied | approved`
  - `requestAuthorization(member:)` → `.individual` (self, no Family Sharing) or
    `.child` (parent-managed)
  - `presentPicker()` → hosts `FamilyActivityPicker` in a `UIHostingController`,
    persists the `FamilyActivitySelection` (Codable) to `UserDefaults`
  - `applyShield()` / `clearShield()` → writes tokens to a `ManagedSettingsStore`
- `ios/Runner/AppDelegate.swift` — MethodChannel `com.safini.app/screen_time`
  (registered via the implicit-engine plugin registrar's messenger).

Dart:

- `lib/features/child/data/services/screen_time_service.dart` — bridge +
  `ScreenTimeAuthStatus`, `ScreenTimeMember`, `ScreenTimeSelection`,
  `ScreenTimeException`. iOS-only (`isSupported`); no-ops elsewhere.
- Registered in `lib/features/child/child_injection.dart`.
- `lib/features/child/presentation/screens/dev/child_screen_time_debug_screen.dart`
  — DEV screen (buttons: request auth, pick apps, block, unblock). Reachable
  from Kid · Me → "DEV · Screen Time (iOS)" in debug builds only.

`ScreenTimeService` is intentionally **separate** from `AppBlockService`
(Android-only). The platforms share no primitives, so a single cross-platform
interface would leak wrong assumptions (app lists, usage minutes) onto iOS.

## Channel contract (`com.safini.app/screen_time`)

| Method | Args | Returns |
|--------|------|---------|
| `authorizationStatus` | — | `String` status |
| `requestAuthorization` | `{ member: "individual" \| "child" }` | `String` status, or `FlutterError("authorization_failed")` |
| `presentPicker` | — | `{ applications: Int, categories: Int }`, or `FlutterError("picker_failed")` |
| `applyShield` | — | `Bool` (false = nothing selected) |
| `clearShield` | — | `null` |
| `selectionCounts` | — | `{ applications: Int, categories: Int }` |

## How to test

1. On a **real device** (Screen Time isn't in the Simulator), run a debug build.
2. Kid · Me → **DEV · Screen Time (iOS)**.
3. **Request authorization** → approve (`.individual`, no Family Sharing).
4. **Pick apps** → Done. Card shows token counts.
5. **Block** → open a picked app → system shield.
6. **Unblock** → shield lifts.

Family Controls must be in **both** the profile and `Runner.entitlements`.
Profile-only → "Couldn't communicate with a helper application".
Entitlements-only → install integrity failure.

## Remaining work

### A. Entitlement — development works; confirm distribution

Increment 1 **authorizes on device**. Still confirm Certificates → Provisioning
Support lists **TestFlight + App Store**
([SAF-135](https://linear.app/safini-team/issue/SAF-135)).

### B. Increment 2 — scheduling + branded overlay (needs Xcode)

[SAF-155](https://linear.app/safini-team/issue/SAF-155). New app-extension
targets + App Group `group.com.safini.app` (create in Xcode, do not hand-edit
pbxproj):

1. **DeviceActivityMonitor** — daily limits / schedules that survive app kill.
2. **ShieldConfiguration** + **ShieldAction** — brand the system shield.
3. Optional Shortcuts "Open App" interstitial.

### C. Backend + parent (do this next)

Full write-up: `observation/ios_parent_backend_sync.md`.

- [SAF-154](https://linear.app/safini-team/issue/SAF-154) — child PUTs Screen Time
  status; parent GETs it (counts + auth, **never tokens**).
  **Client plumbing already landed** (ahead of the endpoint): `ScreenTimeStatus`
  model, `ChildAppRulesService.report/fetchScreenTimeStatus`, and a "Sync status
  to backend, then read back" button on `ChildScreenTimeDebugScreen`. The GET
  returns 404 until the route deploys — the dev screen prints that verbatim.
  Still missing: automatic PUT after auth/pick/apply/clear, and the parent card.
- [SAF-156](https://linear.app/safini-team/issue/SAF-156) — iOS child fetches
  `/app-usage` and apply/clear the **local** shield from parent rules.
- [SAF-153](https://linear.app/safini-team/issue/SAF-153) — installed-apps API
  (Android only; iOS has no list).

## Constraints recap

- Min iOS: **17.4** (already the project's deployment target + Podfile platform).
- Device-only (no Simulator support for Screen Time).
- Selection tokens are per-device and non-portable; never sent to the backend.
