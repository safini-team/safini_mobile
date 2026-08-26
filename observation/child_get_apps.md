# Child · Get Installed Apps

> How the child device enumerates the apps installed on it, how to verify it,
> and how that list feeds the parent-facing "apps on this phone" feature.

This is the **child device** capability behind the installed-apps pipeline
(child enumerates → uploads → parent reads). See `app_blocking.md` §7 for the
full pipeline and `BACKEND_TODO.md` #4 for the (still pending) backend endpoint.

---

## 1. End-to-end path

```
CHILD DEVICE (Android)                              BACKEND            PARENT
──────────────────────                              ───────            ──────
PackageManager.queryIntentActivities(MAIN/LAUNCHER)
  │  (native, MainActivity.installedLaunchableApps)
  ▼
MethodChannel "com.safini.app/app_block" → "installedApps"
  │
  ▼
AppBlockService.installedApps() → List<InstalledApp>     ── dev screen reads this
  │
  ▼
ChildAppRulesService.reportInstalledApps(childId, apps)
        PUT /v1/children/{id}/installed-apps  ───────────►  (pending #4)  ──►  GET → ParentInstalledAppsScreen
```

The **dev screen added here taps in at `AppBlockService.installedApps()`** — it
does not upload anything. It only proves the device can read its own app list.

---

## 2. Native implementation (Android)

`android/app/src/main/kotlin/com/safini/app/MainActivity.kt`

```kotlin
"installedApps" -> result.success(installedLaunchableApps())

private fun installedLaunchableApps(): List<Map<String, String>> {
    val pm = packageManager
    val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
    return pm.queryIntentActivities(intent, 0)
        .mapNotNull { info ->
            val appPackage = info.activityInfo?.packageName ?: return@mapNotNull null
            if (appPackage == packageName) return@mapNotNull null   // skip Safini itself
            mapOf("packageName" to appPackage, "appName" to info.loadLabel(pm).toString())
        }
        .distinctBy { it["packageName"] }
}
```

Key points:

- It returns **launchable apps** (things with a launcher icon), not literally
  every installed package. That is the useful set for parental control — the
  apps a child can actually open — and it excludes Safini itself.
- Each entry is `{ packageName, appName }`, deduped by package.
- Switching to *every* package (incl. system/non-launchable) would mean
  `pm.getInstalledApplications(...)`, which is what `QUERY_ALL_PACKAGES` unlocks.
  We don't need that yet.

### Permissions & manifest

`android/app/src/main/AndroidManifest.xml`

- `<queries>` includes an `ACTION_MAIN` + `CATEGORY_LAUNCHER` intent, which is
  what lets `queryIntentActivities` see other apps on **Android 11+ (API 30+)**
  without any special permission.
- `QUERY_ALL_PACKAGES` is also declared (full visibility). It is a **sensitive**
  permission: Google Play requires a Declaration Form justifying it (parental
  control is an accepted use). The launcher-intent query above already works
  without it, so it is only needed if we move to `getInstalledApplications`.

---

## 3. Dart bridge

`lib/features/child/data/services/app_block_service.dart`

```dart
Future<List<InstalledApp>> installedApps() async {
  if (!isSupported) return const [];            // iOS / web → empty
  final raw = await _channel.invokeListMethod<dynamic>('installedApps');
  // ... map to InstalledApp(packageName, appName), drop blanks ...
}
```

- `isSupported` is `!kIsWeb && Platform.isAndroid`.
- `MissingPluginException` / `PlatformException` are swallowed → returns `[]`,
  so the app never crashes if the native handler is absent.

Model: `lib/features/models/domain/models/installed_app.dart`
(`InstalledApp { packageName, appName }`, snake_case JSON for the backend).

---

## 4. Dev verification screen (this change)

`lib/features/child/presentation/screens/dev/child_apps_debug_screen.dart`

A **debug-only** screen that calls `AppBlockService.installedApps()` and shows:

- Platform supported (Android) — check/cross.
- Usage-access and overlay-permission states (for reference; **not** required to
  list apps — enumeration works without them).
- App count and load time.
- The full scrollable list of `appName` + `packageName`, with a reload action
  and pull-to-refresh.
- Friendly blocks for the "iOS / unsupported", "no apps returned", and error
  cases (the last two point at the likely native cause).

### How to open it

Kid · **Me** tab → the top row **"DEV · Installed apps"**.

That row is wrapped in `if (kDebugMode)` in
`lib/features/child/presentation/screens/profile/child_profile_screen.dart`
(`ChildMeSettings`), so it is present in debug/profile builds and **absent in
release**. No feature flag to flip — it keys off the build mode.

Strings on the dev screen are intentionally hard-coded English (not localized) —
it is a developer tool that never ships to users.

---

## 5. Expected results

| Platform | Result |
|----------|--------|
| Android device / emulator (debug) | Full list of launchable apps, minus Safini |
| iOS | Empty list + "Android only" block (iOS cannot enumerate installed apps) |
| Android before the native handler exists | Empty list + "No apps returned" block |

The `flutter run` session currently targeting **iOS** will show the "Android
only" state — run on Android to see real data. iOS **cannot** be made to behave
like Android here; see §6 for what is actually possible on iOS.

---

## 6. iOS — the same feature, a very different mechanism

**You cannot list installed apps on iOS.** A sandboxed App Store app has no
equivalent to Android's `PackageManager` enumeration — it is a privacy boundary
Apple enforces and there has never been a public API for it. That is why
`AppBlockService.installedApps()` returns `[]` on iOS by design and the dev
screen shows the "Android only" block.

There are two supported ways to get *something* app-related on iOS, each with
hard limits. Pick based on the goal (see the recommendation at the end).

### Option A — Probe a **known** list with `canOpenURL` (detect specific apps)

You cannot ask "what is installed?", but you can ask "is *this specific* app
installed?" by testing whether its custom URL scheme resolves.

- `UIApplication.shared.canOpenURL(URL(string: "roblox://")!)` → `true`/`false`.
- Every scheme you probe must be declared up front in `Info.plist` under
  `LSApplicationQueriesSchemes` (**max 50**). Undeclared schemes always return
  `false`.
- This only works for a **fixed, known set** — exactly our controlled-apps
  catalog (`ControlledApps.slugToPackage`). You'd maintain a
  `slug → iOS URL scheme` map next to it.
- App Review: acceptable for a small, purpose-specific set; using it to broadly
  fingerprint/enumerate apps risks rejection.
- **Result:** on iOS the "app list" becomes *"which of the apps we control are
  present"*, not the whole device.

iOS side (default Flutter `AppDelegate` has no channel yet — this adds one):

```swift
// ios/Runner/AppDelegate.swift
let channel = FlutterMethodChannel(
  name: "com.safini.app/app_block",
  binaryMessenger: controller.binaryMessenger)
channel.setMethodCallHandler { call, result in
  switch call.method {
  case "installedApps":
    // slug/package  ->  iOS URL scheme
    let schemes: [String: String] = [
      "com.roblox.client": "roblox",
      "com.mojang.minecraftpe": "minecraft",
      // youtube-kids / brawl-stars: confirm real schemes before adding
    ]
    let found = schemes.compactMap { (pkg, scheme) -> [String: String]? in
      guard let url = URL(string: "\(scheme)://"),
            UIApplication.shared.canOpenURL(url) else { return nil }
      return ["packageName": pkg, "appName": pkg]
    }
    result(found)
  default:
    result(FlutterMethodNotImplemented)
  }
}
```

```xml
<!-- ios/Runner/Info.plist -->
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>roblox</string>
  <string>minecraft</string>
  <!-- add each controlled app's real scheme -->
</array>
```

Dart change: `installedApps()` currently early-returns on non-Android
(`if (!isSupported) return const []`). To let iOS through, either broaden that
guard for this one method or add a dedicated `probeKnownApps()` path — do **not**
loosen `isSupported` globally (the enforcement calls must stay Android-only).

> Caveat: URL schemes are app-defined and can change or be absent. `canOpenURL`
> is a best-effort signal, not a guarantee. Confirm each app's current scheme
> before shipping it.

### Option B — Screen Time / FamilyControls (the real blocking path)

The correct parental-control API family: `FamilyControls`, `ManagedSettings`,
`DeviceActivity` (iOS 15+). This is how iOS blocking will actually work — see
`app_blocking.md` §9.

- The child device is enrolled via **Family Sharing**; the app calls
  `AuthorizationCenter.shared.requestAuthorization(for: .child)`, which requires
  the **`com.apple.developer.family-controls` entitlement** (requested from
  Apple; it is gated, not automatic).
- To choose apps you present the system **`FamilyActivityPicker`**. It returns
  **opaque tokens** (`ApplicationToken` / `ActivityCategoryToken`) — **not names,
  not bundle IDs**. You can shield/limit those tokens via `ManagedSettings`, but
  you can **never read the underlying app identities** or render your own list.
- So iOS is "the user picks apps in Apple's own UI → you store tokens → you
  shield them". There is no way to show the child's real app names yourself, so
  it is a fundamentally different UX from the Android list.

#### How the block + overlay actually works (ScreenZen-verified)

The "overlay" is **not** an app-drawn window like Android's — it is Apple's
**system shield**, drawn by the OS over a blocked app. The proven pipeline (this
is exactly how ScreenZen does it — deep dive in `screenzen_research.md`):

1. **Authorize** — `AuthorizationCenter.shared.requestAuthorization(for:)`
   (`.child` for a parent-managed device, `.individual` for self-control).
2. **Pick apps/categories** — present `FamilyActivityPicker` → a
   `FamilyActivitySelection` of opaque `applicationTokens` / `categoryTokens`.
3. **Block** — assign those tokens to a `ManagedSettingsStore`
   (`store.shield.applications = tokens`,
   `store.shield.applicationCategories = .specific(categoryTokens)`). Non-nil →
   the OS blocks them immediately; `nil` lifts it.
4. **Schedule when** — a `DeviceActivityMonitor` extension applies/clears the
   shield on time ranges / usage thresholds, so the block survives app kill.
5. **Brand the overlay** — two ManagedSettingsUI extensions: a
   `ShieldConfigurationDataSource` (title, subtitle, icon, colors, ≤2 buttons)
   and a `ShieldActionDelegate` (button taps). The shield runs out-of-process:
   **no SwiftUI, no animation, system types only.**
6. **Rich "breathe / wait" screen (optional)** — the shield can't animate, so
   ScreenZen adds a **Shortcuts "Open App" automation** that launches its own app
   to render the countdown UI — the friendly friction layer on top of the hard
   shield.

All targets (app + monitor + both shield extensions) must share **one App Group**
to pass tokens and state. Full breakdown, code, and sources:
`observation/screenzen_research.md`.

### Recommendation

- **Parity with today's dev check:** implement **Option A** for the controlled
  apps only — enough to verify "is Roblox / Minecraft installed on this iPhone".
  Small, contained, no entitlement needed.
- **Real enforcement on iOS:** **Option B**, as a separate epic (needs the
  family-controls entitlement + a native Screen Time integration). The minimum
  target set (app + `DeviceActivityMonitor` + two shield extensions + a shared
  App Group) is spelled out in `screenzen_research.md` §7.
- **Model impact:** `InstalledApp { packageName, appName }` still fits Option A
  (use the slug/bundle id for both fields). Option B has no name to store — only
  on-device tokens.

### What the dev screen shows on iOS

- Today: the "Android only" block (accurate — nothing to enumerate).
- With Option A: it would list only the controlled apps detected as installed.
  Consider relabelling that state on iOS to "Detected controlled apps" so it is
  not mistaken for a full device list.

---

## 7. Testing steps

1. `flutter run` on an **Android** device/emulator (debug).
2. Sign in as a child → open the **Me** tab.
3. Tap **DEV · Installed apps**.
4. Confirm the count is non-zero and the list contains the device's apps
   (install Roblox / YouTube Kids first to see recognizable entries).
5. Tap reload / pull-to-refresh; the list and load time refresh.
6. (Optional) Compare against the upload path: once backend #4 is live, the same
   list should appear in the parent's "See all apps on this phone" screen.

---

## 8. Files

- `android/app/src/main/kotlin/com/safini/app/MainActivity.kt` — `installedApps`
  handler + `installedLaunchableApps()` (already present).
- `android/app/src/main/AndroidManifest.xml` — `<queries>` launcher intent +
  `QUERY_ALL_PACKAGES` (already present).
- `lib/features/child/data/services/app_block_service.dart` — `installedApps()`
  bridge (already present).
- `lib/features/models/domain/models/installed_app.dart` — `InstalledApp` model.
- **`lib/features/child/presentation/screens/dev/child_apps_debug_screen.dart`** — new dev screen.
- `lib/features/child/presentation/screens/profile/child_profile_screen.dart` — debug-only entry row.

## Related

- `observation/screenzen_research.md` — deep dive on the iOS Screen Time shield
  pipeline (the ScreenZen reverse-engineering behind §6, Option B).
- `observation/app_blocking.md` — the Android enforcement engine and the overall
  parent↔child blocking architecture.
