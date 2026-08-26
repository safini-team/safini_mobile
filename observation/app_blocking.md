# App Blocking — Implementation Guide for Safini

> Step-by-step plan to bring the **time-limit / manual app blocking** proven in the
> `app_block_test` spike into the `safini` Flutter app.
>
> The reference spike (`com.example.app_block_test`) is Android-only and enforces limits
> **on-device** with a foreground service, `UsageStatsManager`, and a `WindowManager`
> overlay. This document maps that design onto Safini's architecture and backend.

---

## 1. TL;DR — What has to change

| Layer | Reference spike (`app_block_test`) | Safini today | What we add |
|-------|-----------------------------------|--------------|-------------|
| Native Android | `AppBlockForegroundService`, `MainActivity` MethodChannel, overlay, broadcast | `MainActivity.kt` is a bare `FlutterActivity`; manifest only has `INTERNET` | Full native service + permissions + method channel |
| Platform bridge | `AppControlService` (MethodChannel `app_block_test`) | none | New `AppBlockService` Dart wrapper over a MethodChannel |
| Rule source | Local `SharedPreferences` only | Backend rules via REST (`app-rules` / `app-usage`) | Sync backend rules → native; report usage back |
| State / UI | Single Apps tab in spike | `ParentAppsScreen` (parent), child app screens | Child-side enforcement + permission onboarding |
| Backend | none | tracking-only, **does not block at OS level** (per API docs) | no backend change required for v1 |

**Key architectural fact:** in Safini the **parent configures** rules and the **child's
device enforces** them. The spike ran both roles on one device. So the native blocking
code must live on and run on the **child** device build.

---

## 2. Where "app blocking" lives in Safini right now

### 2.1 Domain stub (already scaffolded, not wired to blocking)

There is an unused/placeholder rule layer under the `models` feature that already carries an
`isBlocked` flag — this is the natural home for the "manual block" concept:

- `lib/features/models/domain/models/app_model.dart` — `AppRuleModel { …, bool isBlocked }`
- `lib/features/models/domain/controllers/app_controller.dart` — `updateAppRule(ruleId, {dailyLimitMinutes, isBlocked})`
- `lib/features/models/domain/repositories/i_app_repository.dart` — interface
- `lib/features/models/data/repositories/app_repository_impl.dart` — **all methods return `Left(ServerFailure('Not implemented'))`**
- `lib/features/models/data/dto/app_dto.dart` — maps `is_blocked` ⇄ `isBlocked`

> Note: `isBlocked` is **not** part of the live backend contract (see §3). It exists only
> in this stub layer. Treat it as an aspirational/local field for now.

### 2.2 The live parent-facing path (this is what actually runs)

- `lib/features/parent/presentation/screens/apps/parent_apps_screen.dart` — Apps tab UI, "add app" sheet
- `lib/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart` — per-app row + enable/disable switch
- `lib/features/parent/presentation/cubit/parent_apps_cubit.dart` — loads usage, toggles/persists rules
- `lib/features/parent/domain/models/child_app_usage_model.dart` — `is_enabled`, `daily_limit_minutes`, `used_minutes`, `remaining_minutes_today`, `redeem_coin_cost`, `redeem_reward_minutes`
- `lib/features/parent/data/repositories/parent_app_usage_repository_impl.dart` — REST calls to the backend

### 2.3 Native / platform

- `android/app/src/main/kotlin/com/safini/app/MainActivity.kt` — bare `FlutterActivity` (package `com.safini.app`)
- `android/app/src/main/AndroidManifest.xml` — only `android.permission.INTERNET`
- No `MethodChannel`/`EventChannel` exists in Dart yet (only Google Sign-In uses a plugin)
- iOS: nothing; OS-level blocking on iOS requires the Screen Time / FamilyControls entitlement (see §9)

### 2.4 Conventions to follow

- DI: `get_it` with manual registration per feature (`lib/features/*/**_injection.dart`), wired in `lib/core/di/injection.dart`. Some classes also use `injectable` annotations (`@lazySingleton`, `@Injectable(as: …)`).
- State: `flutter_bloc` cubits.
- Errors: `dartz` `Either<Failure, T>` with `Failure` subtypes in `lib/core/utils/error/failures.dart`.
- Networking: either `Dio` (`lib/core/network/dio_network.dart`) or raw `http.Client` against `SupabaseConfig.apiBaseUrl` with a Supabase bearer token (see `parent_app_usage_repository_impl.dart`).
- `shared_preferences` is registered in DI and available.

---

## 3. Backend contract (from `lib/api_reference/api.json`)

The MVP backend is **tracking-only**. Its own docs state: *"In the MVP this is tracking only.
The backend … does not yet block apps at the OS level."* So all enforcement is client-side.

Relevant endpoints (all `Authorization: Bearer <supabase_access_token>`):

| Method | Path | Purpose |
|--------|------|---------|
| `GET`  | `/v1/apps` | Controlled-app **catalog** (slug, display name, defaults). ✅ live — replaces the hardcoded `_knownApps` list |
| `GET`  | `/v1/children/{child_id}/app-usage` | Read per-app `used_minutes`, `remaining_minutes_today`, `is_enabled`, `daily_limit_minutes` (also returns `bonus_minutes_remaining`, `total_minutes_available`) |
| `PUT`  | `/v1/children/{child_id}/app-rules/{app_slug}` | Upsert a rule: `is_enabled`, `daily_limit_minutes`, `redeem_coin_cost`, `redeem_reward_minutes` |
| `POST` | `/v1/children/{child_id}/app-usage` | Report actual usage; backend reduces remaining granted minutes |
| `POST` | `/v1/children/{child_id}/redemptions/app-time` | Child spends Time Coins for extra minutes |

**Slug vs package name:** the backend keys apps by **slug** (from the live
`GET /v1/apps` catalog — see `CatalogAppModel`; the client no longer hardcodes the list).
Android blocking needs a **package name** (`com.google.android.apps.youtube.kids`, …). We
must maintain a `slug → packageName` map (`ControlledApps.slugToPackage`, see Step 5).

---

## 4. Target architecture

```
PARENT DEVICE                         BACKEND (tracking only)                 CHILD DEVICE
─────────────                         ───────────────────────                ────────────
ParentAppsScreen                                                             ChildAppBlockCubit
  │ toggle / set limit                                                          │ on app start / resume
  ▼                                                                             ▼
PUT /app-rules/{slug} ───────────────►  app_rules table  ◄──────────────────  GET /app-usage
                                        (is_enabled,                            │ (remaining_minutes_today,
                                         daily_limit_minutes)                   │  daily_limit_minutes, is_enabled)
                                                                                ▼
                                                                        AppBlockService (Dart, MethodChannel)
                                                                                │  syncRules(pkg → limitMs / blocked)
                                                                                ▼
                                                                        MainActivity (Kotlin, MethodChannel)
                                                                                │  SharedPreferences + broadcast
                                                                                ▼
                                                                        AppBlockForegroundService
                                                                          - poll every 500ms
                                                                          - UsageStatsManager.queryEvents
                                                                          - overlay via WindowManager
                                                                                │  reports measured usage
                                                                                ▼
                                                                        POST /app-usage (periodic)
```

The **native enforcement engine is a near-verbatim port** of the spike. The new work in
Safini is: (a) wiring the channel into `com.safini.app`, (b) translating backend rules into
the native limit map, and (c) reporting measured usage back to the backend.

---

## 5. Step-by-step implementation

> Ordering is chosen so each step is independently testable. Steps 1–6 are Android-only.

### Step 1 — Android permissions & manifest

Edit `android/app/src/main/AndroidManifest.xml`. Add above `<application>`:

```xml
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
    tools:ignore="ProtectedPermissions" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

- Add `xmlns:tools="http://schemas.android.com/tools"` to the `<manifest>` root.
- Register the service inside `<application>`:

```xml
<service
    android:name=".AppBlockForegroundService"
    android:exported="false"
    android:foregroundServiceType="specialUse">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="parental_control_app_time_enforcement" />
</service>
```

- `PACKAGE_USAGE_STATS` and `SYSTEM_ALERT_WINDOW` are **special permissions** — they cannot
  be granted by a normal runtime prompt. You must deep-link the user to Settings (Step 4).
- `<queries>` may need entries so `UsageStatsManager` / `PackageManager` can see the target
  apps on Android 11+.

### Step 2 — Port the native service

Create Kotlin files under `android/app/src/main/kotlin/com/safini/app/` (change package to
`com.safini.app` everywhere; the spike used `com.example.app_block_test`):

- `AppBlockForegroundService.kt` — the polling engine. Port verbatim from the spike:
  - `Handler(Looper.getMainLooper()).postDelayed(this, 500)` loop.
  - `UsageStatsManager.queryEvents(now - 2000, now)` → most recent `MOVE_TO_FOREGROUND` = current app.
  - Manual block set check → overlay immediately.
  - Time-limit check:
    - `measureFrom = max(startOfDay, limitSetAt)`
    - `computeUsageMs(measureFrom, now)` by summing `MOVE_TO_FOREGROUND`/`MOVE_TO_BACKGROUND` pairs (+ open session tail). Do **not** use `queryUsageStats` for enforcement (≈1-min granularity).
    - `usedMs >= limitMs` → overlay.
  - Overlay: full-screen `WindowManager` view (`TYPE_APPLICATION_OVERLAY`), title/message + "Go to Home" button (`Intent.ACTION_MAIN` + `CATEGORY_HOME`).
  - `START_STICKY`, foreground notification, `BroadcastReceiver` for `com.safini.app.UPDATE_BLOCKED_APPS` → `loadLimits()`.
- `BootReceiver.kt` (optional) — restart the service on `BOOT_COMPLETED` if enforcement was active.

Keep the SharedPreferences key scheme from the spike (namespaced to avoid clashes with the
Flutter `shared_preferences` file — use a dedicated prefs file name, e.g. `safini_app_block`):

| Key | Value |
|-----|-------|
| `limit_<packageName>` | limit in ms |
| `limitStart_<packageName>` | `System.currentTimeMillis()` when set |
| `blocked_set` | comma-joined package names for manual blocks |

### Step 3 — MethodChannel in `MainActivity.kt`

Replace the bare activity with a `configureFlutterEngine` that registers a channel
(`com.safini.app/app_block`). Handle these calls:

| Method | Args | Native action |
|--------|------|---------------|
| `hasUsageAccess` | – | return whether `PACKAGE_USAGE_STATS` is granted |
| `hasOverlayPermission` | – | `Settings.canDrawOverlays(context)` |
| `requestUsageAccess` | – | launch `ACTION_USAGE_ACCESS_SETTINGS` |
| `requestOverlayPermission` | – | launch `ACTION_MANAGE_OVERLAY_PERMISSION` |
| `startService` | – | `startForegroundService(...)` |
| `stopService` | – | `stopService(...)` |
| `setAppLimit` | `packageName`, `limitMs` | write prefs + broadcast |
| `removeAppLimit` | `packageName` | delete prefs + broadcast |
| `setManualBlock` | `packageName`, `blocked` | update `blocked_set` + broadcast |
| `syncRules` | `List<{packageName, limitMs?, blocked}>` | replace whole map + broadcast |
| `installedApps` | – (optional) | return launchable packages for a picker |

`syncRules` is the important one for Safini: it lets the Dart layer push the full backend
rule set atomically in one call after fetching `/app-usage`.

### Step 4 — Dart platform bridge: `AppBlockService`

Create `lib/features/child/data/services/app_block_service.dart` (child feature, since the
child device enforces). Mirror the spike's `AppControlService`:

```dart
class AppBlockService {
  static const _channel = MethodChannel('com.safini.app/app_block');

  Future<bool> hasUsageAccess() async =>
      await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
  Future<bool> hasOverlayPermission() async =>
      await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
  Future<void> requestUsageAccess() => _channel.invokeMethod('requestUsageAccess');
  Future<void> requestOverlayPermission() =>
      _channel.invokeMethod('requestOverlayPermission');
  Future<void> startService() => _channel.invokeMethod('startService');
  Future<void> syncRules(List<Map<String, dynamic>> rules) =>
      _channel.invokeMethod('syncRules', {'rules': rules});
}
```

- Guard every call with `if (!Platform.isAndroid) return;` so iOS is a no-op until §9.
- Register in `lib/features/child/child_injection.dart`:
  `sl.registerLazySingleton<AppBlockService>(() => AppBlockService());`

### Step 5 — Slug ↔ package-name map

The backend uses slugs; Android needs package names. Add a single source of truth, e.g.
extend `lib/features/parent/data/app_data.dart` (already referenced by the limit tile) or a
new `lib/core/utils/constants/controlled_apps.dart`:

```dart
const Map<String, String> kSlugToPackage = {
  'youtube-kids': 'com.google.android.apps.youtube.kids',
  'roblox': 'com.roblox.client',
  'brawl-stars': 'com.supercell.brawlstars',
  'minecraft': 'com.mojang.minecraftpe',
};
```

Keep this in sync with the live `GET /v1/apps` catalog (`CatalogAppModel`) — only the
native package mapping is maintained by hand; the slug list itself is server-driven.

### Step 6 — Convert backend rules → native limit map

On the **child** device, after fetching usage (reuse the pattern in
`parent_app_usage_repository_impl.dart`, but as a child repository), build the rule list:

- For each `ChildAppUsageModel`:
  - `packageName = kSlugToPackage[app.appSlug]` (skip if unknown).
  - If `!app.isEnabled` → treat as a **manual block** (`blocked: true`). (Interpretation
    choice: an app the parent disabled = fully blocked. Document/confirm this with product.)
  - Else if `app.remainingMinutesToday <= 0` → `blocked: true` (limit already consumed).
  - Else → `limitMs = remainingMinutesToday * 60000` and `blocked: false`.
- Call `appBlockService.syncRules(rules)`.

> Because the backend already computes `remaining_minutes_today` (base limit + redeemed −
> used), sending **remaining** minutes as the native limit is simpler and keeps redemptions
> working automatically. The spike's `measureFrom = max(startOfDay, limitSetAt)` logic still
> applies for the intra-day window after each sync.

### Step 7 — Child-side orchestration (cubit + lifecycle)

Add `lib/features/child/presentation/cubit/app_block_cubit.dart`:

- On child app start / resume (`WidgetsBindingObserver.didChangeAppLifecycleState`) and on a
  periodic timer (e.g. every 5–10 min):
  1. Check permissions (`hasUsageAccess`, `hasOverlayPermission`). If missing → emit a state
     that drives a permission-onboarding screen.
  2. `GET /app-usage` for the current child.
  3. `syncRules(...)` (Step 6).
  4. `startService()` (idempotent).
- Report measured usage back: `POST /app-usage` on a cadence, so the backend's
  `remaining_minutes_today` stays accurate across devices. (Native can expose a
  `getMeasuredUsage` channel method, or Dart can read from a shared source.)

Wire into the child shell (`lib/features/child/presentation/screens/main/child_main_screen.dart`)
via a `BlocProvider`.

### Step 8 — Permission onboarding UI

Special permissions need explicit user action. Add a gate screen (child flow) that:

- Explains why Usage Access + Display-over-other-apps are needed.
- Buttons call `requestUsageAccess()` / `requestOverlayPermission()`.
- Re-checks on resume and continues once both are granted.

Follow existing widget/theme conventions (`ParentSliverScaffold`, `context.colorScheme`,
`AppSnackBar`, and the `S.of(context)` localization used across screens).

### Step 9 — Parent visibility (optional, nice-to-have)

The parent's `parent_apps_screen.dart` can surface enforcement status (e.g. "blocking active
on child device", "permissions missing"). This needs a backend field or a lightweight
heartbeat; out of scope for v1 but worth a placeholder.

---

## 6. Wiring the two rule concepts

| Concept | Where set in Safini | Native mapping | Overlay title |
|---------|--------------------|----------------|---------------|
| Manual block | Parent toggles `is_enabled = false` on the app row (`ParentAppLimitTile` switch) | `setManualBlock(pkg, true)` / `blocked: true` in `syncRules` | "App Blocked" |
| Time limit | `daily_limit_minutes` + redemptions → `remaining_minutes_today` | `limitMs = remaining * 60000` | "Time Limit Reached" |

Manual block takes priority (matches the spike). Daily reset is implicit: `remaining_minutes_today`
resets server-side at the day boundary and `getStartOfDay()` resets the native window at midnight.

---

## 7. Files to create / change (checklist)

**Native (Android)** — implemented; compiles (`:app:compileDebugKotlin` OK)
- [x] `android/app/src/main/AndroidManifest.xml` — permissions + `<service>` + `<receiver>` + `tools` ns + `<queries>`
- [x] `android/app/src/main/kotlin/com/safini/app/AppBlockStore.kt` — shared prefs rule store + `UPDATE_BLOCKED_APPS` broadcast
- [x] `android/app/src/main/kotlin/com/safini/app/AppBlockForegroundService.kt` — 500ms poll, `UsageStatsManager` measurement, `WindowManager` overlay
- [x] `android/app/src/main/kotlin/com/safini/app/MainActivity.kt` — MethodChannel `com.safini.app/app_block`
- [x] `android/app/src/main/kotlin/com/safini/app/BootReceiver.kt` — restart on boot when enforcing

**Dart**
- [x] `lib/features/child/data/services/app_block_service.dart` — MethodChannel wrapper + `AppBlockRule` + `syncFromUsage` mapping (native no-op until Steps 1-3 land)
- [x] `lib/features/child/data/services/child_app_rules_service.dart` — backend: fetch rules to enforce + report usage (`GET`/`POST /app-usage`)
- [x] `lib/features/parent/data/services/parent_app_blocking_service.dart` — backend: fetch rules + set limit / block (`GET /app-usage`, `PUT /app-rules/{slug}`)
- [x] `lib/core/utils/constants/controlled_apps.dart` — slug↔package map
- [x] `lib/core/network/dio_error_mapper.dart` — shared `DioException → Failure` mapper
- [x] `lib/core/utils/constants/api_const.dart` — `childAppUsage` / `childAppRule` endpoints
- [x] `lib/features/child/child_injection.dart` + `parent_injection.dart` — services registered in DI
- [x] `lib/features/child/presentation/cubit/app_block_cubit.dart` + `app_block_state.dart` — orchestration (permissions → resolve child → fetch rules → `syncFromUsage` → `startService` → 5-min re-sync + on-resume re-check)
- [x] `lib/features/child/presentation/screens/blocking/child_app_block_gate.dart` — permission-onboarding gate, wired into `child_main_screen.dart`
- [x] Periodic **usage reporting** back to the backend (`POST /app-usage`) — native `usageSinceMidnight(packages)` measures the day total (not the limit window); the cubit's cycle now runs **report → fetch → sync** so `remaining_minutes_today` stays accurate

**Installed-apps list (child → backend → parent)** — client done; backend pending
- [x] `android/app/src/main/kotlin/com/safini/app/MainActivity.kt` — `installedApps` MethodChannel (launchable apps)
- [x] `android/app/src/main/AndroidManifest.xml` — `QUERY_ALL_PACKAGES` (Play Declaration Form required)
- [x] `lib/features/models/domain/models/installed_app.dart` — shared `InstalledApp` model
- [x] `AppBlockService.installedApps()` — enumerate on the child device
- [x] `ChildAppRulesService.reportInstalledApps()` — `PUT /children/{id}/installed-apps` (child uploads once per session in `ChildAppBlockCubit.start()`)
- [x] `ParentAppBlockingService.fetchInstalledApps()` — `GET /children/{id}/installed-apps` (parent reads)
- [ ] **Backend endpoints** `PUT/GET /children/{id}/installed-apps` — see `BACKEND_TODO.md` #4 (blocker)
- [x] Parent UI to display the fetched list — `ParentInstalledAppsScreen` +
  `ParentInstalledAppsCubit`, reachable from the Limits screen via a
  "See all apps on this phone" row. Gated behind
  `AppConstants.childInstalledAppsShipped` (false) until the endpoint lands; a
  404 renders the "No apps synced yet" empty state.

**Optional / cleanup**
- [ ] Decide fate of the `models` app-rule stub (`app_repository_impl.dart` returns "Not implemented"). Either implement it against the live endpoints or delete it to avoid confusion with the live `parent` path.

---

## 8. Testing plan

1. **Permissions:** fresh install → onboarding gate appears → grant both → gate clears.
2. **Manual block:** parent disables an app → within ≤500ms on child device, opening that app shows "App Blocked".
3. **Time limit:** set a short limit (use a 10s test limit like the spike) → open app → overlay after limit; "Go to Home" dismisses.
4. **Daily reset:** advance device clock past midnight (or wait) → app usable again with fresh limit.
5. **Redemption:** child redeems coins → `remaining_minutes_today` grows → next sync lifts/extends the limit.
6. **Force-stop / reboot:** verify `START_STICKY` + `BootReceiver` behavior matches expectations.
7. **Usage accuracy:** compare native measured minutes vs backend `used_minutes` after a `POST /app-usage`.

---

## 9. Known constraints & risks

Carried over from the spike:

- **Usage Stats permission required.** Without `PACKAGE_USAGE_STATS`, `queryEvents` returns nothing — no foreground detection, no usage measurement.
- **Overlay permission required.** Without `SYSTEM_ALERT_WINDOW`, the block screen silently fails to draw.
- **Clock manipulation.** Moving the device clock back can bypass daily limits. Validate against server time if this matters.
- **Force-stop.** Settings → Force Stop kills the service; `START_STICKY` only recovers from system-initiated kills. Restart on next app open / boot.

Safini-specific:

- **iOS is not covered by this design.** `UsageStatsManager`/overlay have no iOS equivalent.
  iOS requires Apple's **FamilyControls / DeviceActivity / ManagedSettings** (Screen Time)
  framework, a special entitlement (`com.apple.developer.family-controls`), and a separate
  implementation. Ship Android first; make all Dart calls no-ops on iOS.
- **Slug/package drift.** The slug list is server-driven (`GET /v1/apps`), but each new
  controlled app still needs a `ControlledApps.slugToPackage` entry (and a `<queries>`
  `<package>` line) or the native engine can't see it.
- **Battery / background limits.** OEM battery optimizers (Xiaomi, Samsung, etc.) may kill the
  foreground service; consider requesting battery-optimization exemption.
- **Two-device latency.** Parent changes propagate only when the child device next syncs
  (`GET /app-usage`), so enforcement is eventually-consistent, not instant, across devices.
- **Backend has no `is_blocked` field.** The `models`-layer `isBlocked` is a local stub;
  manual block is derived from `is_enabled` (or a client-side block set) until the backend adds one.

---

## 10. Suggested delivery order

1. Manifest + native service + MethodChannel + `AppBlockService` (Android enforcement working from hard-coded rules).
2. Permission onboarding gate.
3. Child app-usage repository + `syncRules` from backend.
4. Periodic usage reporting back to backend.
5. Parent status visibility (optional).
6. iOS Screen Time track (separate epic).
