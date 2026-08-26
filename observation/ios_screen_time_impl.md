# iOS Screen Time blocking — implementation status

This is the iOS counterpart to the Android app-blocking engine
(`observation/app_blocking.md`). The mechanism is completely different — see
`observation/child_get_apps.md` §6 and `observation/screenzen_research.md` for
the "why". This file tracks **what is actually built** and **what remains**.

## TL;DR

- **Increment 1 (done, in this branch):** authorize → pick apps in Apple's
  `FamilyActivityPicker` → apply / clear the **system shield** immediately, all
  from the main app target. A debug screen exercises the whole flow.
- **Hard blocker:** Screen Time APIs stay inert until Family Controls is added
  via Xcode Signing & Capabilities (and Apple has granted it for distribution).
  Do not paste the entitlement into `Runner.entitlements` by hand — that
  mismatches the provisioning profile and iOS kills the app on launch.
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

- `ios/Runner/Runner.entitlements` — present so Xcode can attach capabilities.
  **Do not** add `com.apple.developer.family-controls` by hand: if the key is in
  the binary but not the provisioning profile, iOS kills the app on launch.
  Add Family Controls later via Xcode → Signing & Capabilities (that updates
  entitlements + profile together).
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

## How to test (once the entitlement is approved)

1. On a **real device** (Screen Time isn't in the Simulator), run a debug build.
2. Kid · Me → **DEV · Screen Time (iOS)**.
3. **Request authorization** → approve. (`.individual` needs no Family Sharing.)
4. **Pick apps** → select a couple → Done. The card shows the token counts.
5. **Block** → leave the app and open a blocked app → Apple's shield appears.
6. **Unblock** → the shield is lifted.

Before approval, step 3 returns `authorization_failed` with a missing-entitlement
message — that is the expected state, surfaced in the "Last call failed" block.

## Remaining work

### A. Request the entitlement (external, gating everything)

- Apply at
  https://developer.apple.com/contact/request/family-controls-distribution
  for the **distribution** entitlement (development works under the automatically
  granted development variant on a provisioned device/team).
- Once approved, ensure the App ID / provisioning profile carries
  `com.apple.developer.family-controls`.

### B. Increment 2 — scheduling + branded overlay (needs Xcode)

These require **new app-extension targets** and a shared **App Group**
(`group.com.safini.app`), which must be created in Xcode (cannot be safely
hand-edited into the pbxproj):

1. **DeviceActivityMonitor extension** — apply/clear the shield on schedules and
   usage thresholds, so limits map to time-of-day / daily quotas and survive app
   kill. This is where the Android "daily limit" concept lands on iOS.
2. **ShieldConfiguration extension** (`ManagedSettingsUI`) — brand the overlay
   (title, subtitle, icon, up to two buttons). Runs out-of-process: system types
   only, **no SwiftUI, no animation**.
3. **ShieldAction extension** — handle the overlay's button taps.
4. **App Group** — share the selection/tokens and state across app + extensions.
5. (Optional, ScreenZen-style) a **Shortcuts "Open App" automation** to launch
   Safini for a richer "breathe / wait" interstitial, since the shield can't
   animate.

### C. Rule mapping (parent limits → iOS)

Android maps backend slugs → package names → native rules. On iOS there is no
package name and no readable identity, so the model is different: the backend
stores *intent* (which categories/limits), but the concrete tokens live only on
the child device (chosen via the picker). Design the parent→child contract for
iOS separately once Increment 2 exists.

## Constraints recap

- Min iOS: **17.4** (already the project's deployment target + Podfile platform).
- Device-only (no Simulator support for Screen Time).
- Selection tokens are per-device and non-portable; never sent to the backend.
