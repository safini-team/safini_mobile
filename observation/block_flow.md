# App‑blocking flow — Android vs iOS

> How a parent's intent ("limit Roblox to 60 min") becomes an actual block on
> the child's phone, and why the **setup flow forks by platform**:
>
> - **Android** — the child device enumerates every installed app. The parent
>   picks apps; the child device blocks *exactly those packages*.
> - **iOS** — nothing can list installed apps. The **child** must open Apple's
>   `FamilyActivityPicker` once and choose apps by hand. The parent never sees
>   an app list — only counts and status.
>
> This doc designs one flow that feels coherent on both. Engine details live in
> `observation/app_blocking.md` (Android) and `observation/ios_screen_time_impl.md`
> (iOS). Parent/backend split: `observation/ios_parent_backend_sync.md`.
>
> Linear parent: [SAF-93](https://linear.app/safini-team/issue/SAF-93/randd-app-blocking)

---

## 1. TL;DR — the fork

| Step | Android | iOS |
|------|---------|-----|
| Who chooses which apps | **Parent** (from catalog + real installed list) | **Child** (Apple's picker, on their own iPhone) |
| App identity we hold | Package name (`com.roblox.client`) | Opaque `ApplicationToken` — no name, per‑device, never leaves the phone |
| Enforcement granularity | Per app | Whole picked selection (shield all‑or‑nothing in Increment 1) |
| Parent visibility of the phone's apps | Full list (`GET /installed-apps`) | Counts only (`GET /screen-time-status`) |
| Backend rule keying | Catalog **slug** → `ControlledApps.slugToPackage` | Catalog **slug**, but slug→token mapping is **impossible** |
| One‑time child setup step | Grant 2 permissions | Grant Screen Time auth **+ pick apps in Apple's picker** |

**The invariant that keeps both sane:** the parent always edits the same thing —
a list of catalog **slugs** with `is_limited` / `daily_limit_minutes` /
redemption cost. Only *how that list is resolved into a block* differs.

---

## 2. One mental model, two engines

```
                    ┌─────────────────────────────────────────┐
                    │  CONTROL LIST  (backend, platform-free)  │
                    │  catalog slug + is_limited +             │
                    │  daily_limit_minutes + redeem cost       │
                    │  — the PARENT owns this, same UI both OS │
                    └─────────────────────────────────────────┘
                                     │
              GET /app-usage  (child device pulls it, both platforms)
                                     │
             ┌───────────────────────┴───────────────────────┐
             ▼                                               ▼
   ANDROID: resolve slug→package                   iOS: cannot resolve slug→app
   block those exact packages                      block the child's whole
   (UsageStatsManager + overlay)                   FamilyActivitySelection when
                                                   ANY controlled app is over
   ParentInstalledAppsScreen shows                 limit / blocked
   the real installed list                         (ManagedSettingsStore shield)

                                                   Parent sees status only:
                                                   "Screen Time on · 3 apps · shield active"
```

`AppBlockService` (Android) and `ScreenTimeService` (iOS) share **no
primitives** on purpose — a single cross‑platform interface would leak Android
assumptions (named app lists, per‑app minutes) onto iOS where they can't hold.

---

## 3. The Control List is the contract

Everything the parent touches is slug‑based and identical across platforms:

| Field | Set where | Android use | iOS use |
|-------|-----------|-------------|---------|
| slug in list | Add‑app sheet (from `GET /v1/apps`) | pick `ControlledApps.slugToPackage[slug]` | display name only, as *guidance* to the child |
| `is_limited` / `is_enabled` | per‑app row toggle | `false` → block package outright | `false` → contributes "shield the whole selection" |
| `daily_limit_minutes` (+ redemptions) | stepper / coin redeem | native limit for that package | if `remaining_minutes_today <= 0` for any app → shield selection |

The parent never learns whether their child's iPhone selection actually
*contains* Roblox. That's a platform limit, not a bug — §7 covers how the copy
handles it.

---

## 4. Android flow

### 4.1 Child device setup (one time)

```
child opens Safini
  │
  ▼
ChildAppBlockGate: has PACKAGE_USAGE_STATS && SYSTEM_ALERT_WINDOW?
  │  no ─► onboarding screen ─► deep-link to Settings ─► re-check on resume
  │  yes
  ▼
ChildAppBlockCubit.start()
  ├─ enumerate launchable apps  ─►  PUT /installed-apps   (parent can now browse them)
  └─ syncNow():  POST /app-usage  →  GET /app-usage  →  syncRules(pkg → limitMs / blocked)  →  startForegroundService
  │
  ▼  every 5 min + on resume: report → fetch → sync
ACTIVE — overlay fires within ~500 ms of a rule breach
```

### 4.2 Parent flow

1. Limits screen → **Add app** → catalog sheet (slug, default limit, redeem cost).
2. Per‑app row: toggle on/off, adjust the daily limit.
3. **See all apps on this phone** → `ParentInstalledAppsScreen` (real list +
   "Last synced …"). Rows for catalog‑mapped apps are tappable → add / limit /
   block (Option D, §10).
4. *(next, Option A/C in §10)* limit an app that isn't in the catalog — pick
   straight from the installed list, backend accepts an ad‑hoc slug/package.

Propagation is eventually‑consistent: a parent change lands when the child device
next runs its 5‑min cycle.

---

## 5. iOS flow

### 5.1 Child device setup (one time) — the extra step

```
child opens Safini on iPhone
  │
  ▼
Screen Time authorization?   (AuthorizationCenter)
  │  notDetermined ─► "Turn on Screen Time" ─► system prompt ─► approved
  │  denied ─► dead end: copy points to iOS Settings ▸ Screen Time
  │  approved
  ▼
Has a saved FamilyActivitySelection?   ◄── THE iOS-ONLY GATE
  │  no  ─► "Choose the apps to limit" screen
  │         shows the parent's Control List names as guidance:
  │         "Your parent set limits for: Roblox, YouTube Kids.
  │          Tap Choose apps and pick those (plus anything else)."
  │         ─► presentPicker()  →  Apple's FamilyActivityPicker  →  tokens saved locally
  │         ─► PUT /screen-time-status { authorization, selected_applications, selected_categories, shield_active }
  │  yes
  ▼
ChildAppBlockCubit.start() on iOS:
  GET /app-usage
    any controlled app blocked or remaining_minutes_today <= 0
      ─► applyShield()   (shield the whole local selection)
    else
      ─► clearShield()   (Increment 1)  |  schedule a DeviceActivity threshold (Increment 2)
  PUT /screen-time-status  (keep shield_active fresh)
```

### 5.2 Why the guidance text matters

The picker returns opaque tokens, so we can't pre‑select or verify apps. The
only bridge between "what the parent wants" and "what the child picks" is
**showing the parent's slug display‑names as a checklist prompt** before opening
the picker. It's advisory, but it makes the two sides line up in practice.

### 5.3 Parent flow (iOS child)

Same Add‑app sheet, same per‑app rows — the parent workflow does not change.
What changes is the **status card** in place of "See all apps":

```
Screen Time · on
3 apps · 1 category selected by <child>
Shield: active
Last updated 2 h ago
```

Plus a one‑line nudge whenever the parent edits the list:
*"Ask <child> to open Safini on their iPhone so the new limit takes effect."*

---

## 6. Unified child‑setup state machine

Both platforms collapse to the same five states; only the transitions differ.

| State | Android reaches ACTIVE when… | iOS reaches ACTIVE when… |
|-------|------------------------------|--------------------------|
| `unsupported` | n/a (always supported) | < iOS 17.4, or Simulator |
| `needsPermissions` | Usage Access + overlay granted | Screen Time authorization `approved` |
| `needsSelection` | **skipped** (parent already chose) | a `FamilyActivitySelection` is saved |
| `syncing` | first `GET /app-usage` + `syncRules` done | first `GET /app-usage` + `applyShield/clearShield` done |
| `active` | foreground service running | `ManagedSettingsStore` reflects intent |

`needsSelection` is the fork. On Android the cubit never emits it. On iOS it sits
between `needsPermissions` and `syncing`, and the parent can't clear it for the
child — only the child can, on their device.

---

## 7. The mismatch iOS can't close

| Parent expectation | iOS reality | How the flow copes |
|--------------------|-------------|--------------------|
| "I limited Roblox, so Roblox is limited" | Only true if the child picked Roblox in Apple's picker | Setup screen lists the parent's app names as the pick prompt; parent copy says "apps your child selected", never "Roblox specifically" |
| "Show me which apps are limited" | We hold tokens, not names | Status card shows **counts** ("3 apps"), not a list |
| "Block just one app now" | Shield is all‑or‑nothing in Increment 1 | Increment 2 (`DeviceActivityMonitor`) narrows this to per‑app thresholds; until then, blocking one app shields the whole selection |
| "Per‑app minutes used, like Android" | Not readable — only threshold callbacks | No iOS `used_minutes`; parent monitor hides those widgets for iOS children |

Design rule: **iOS parent surfaces describe state, not a roster.** Any copy that
implies a named, per‑app guarantee is wrong on iOS.

---

## 8. Cross‑cutting transitions

- **Parent adds an app after child setup.**
  Android: picked up on the next 5‑min sync, no child action.
  iOS: limit is stored but inert until the child re‑opens the picker and adds
  it. Fire the "ask your child to confirm" nudge; consider a push later.
- **Child revokes permission / Screen Time auth.**
  Android: gate reappears on next resume; enforcement stops.
  iOS: `authorizationStatus` flips to `denied`; child PUTs the new status;
  parent card shows "Screen Time off".
- **Child reinstalls / new device.**
  Android: re‑enumerates, re‑`PUT /installed-apps`.
  iOS: tokens are per‑device and non‑portable → child must pick apps again.
- **`updated_at == null`** on either status endpoint = the device has never
  synced. Parent surfaces show "waiting for <child>'s phone", not an error.

---

## 9. What to build

| # | Item | Platform | Linear |
|---|------|----------|--------|
| ✅ | `PUT/GET /installed-apps`, parent list screen, `childInstalledAppsShipped` | Android | [SAF-153](https://linear.app/safini-team/issue/SAF-153) |
| ~ | `screen-time-status` **client** plumbing — `ScreenTimeStatus` model, `ChildAppRulesService.report/fetchScreenTimeStatus`, iOS dev-screen round-trip button (endpoint still 404s) | iOS | [SAF-154](https://linear.app/safini-team/issue/SAF-154) |
| — | `needsSelection` state in the iOS branch of `ChildAppBlockCubit` + "Choose the apps to limit" screen (with parent‑name guidance) | iOS | SAF-156 scope |
| — | Deploy `PUT/GET /screen-time-status` + parent status card replacing "See all apps" for iOS children | both | [SAF-154](https://linear.app/safini-team/issue/SAF-154) |
| — | iOS child: `GET /app-usage` → apply/clear shield from parent rules | iOS | [SAF-156](https://linear.app/safini-team/issue/SAF-156) |
| — | "ask your child to confirm" nudge when parent edits the list for an iOS child | parent app | with SAF-154 |
| — | `DeviceActivityMonitor` + shield extensions → per‑app iOS thresholds (closes part of §7) | iOS / Xcode | [SAF-155](https://linear.app/safini-team/issue/SAF-155) |
| — | Confirm Family Controls entitlement on TestFlight + App Store | account holder | [SAF-135](https://linear.app/safini-team/issue/SAF-135) |

---

## 10. Blocking an arbitrary installed app (Android) — options

Today the parent can only limit an app that exists in the `GET /v1/apps`
**catalog** and has a hand‑written `ControlledApps.slugToPackage` entry (4 apps).
The `ParentInstalledAppsScreen` list is read‑only. Goal: parent taps a *real*
app on the child's phone → limit or block it.

Native Android already supports this — `AppBlockService.syncRules` /
`setManualBlock` take **raw package names**, and `QUERY_ALL_PACKAGES` is
declared. The gap is entirely (a) backend rule storage keyed by slug only, and
(b) the read‑only parent UI.

| # | Approach | Backend work | Persist / coins / usage | Effort | iOS |
|---|----------|-------------|-------------------------|--------|-----|
| **A** | Per‑child **custom app** rows — `{package_name, app_name, is_limited, daily_limit_minutes}`, or a synthetic `pkg:<package>` slug. `GET /app-usage` returns them with the package inline. | New table/columns + access control; `POST /app-usage` accepts the synthetic slug | Full (reuses redemption + usage) | M–L | n/a |
| **B** | Dedicated `PUT/GET /children/{id}/blocked-packages` — **parent writes**, child reads `{packages:[…]}`. Child concatenates into `syncRules`. | One new endpoint + migration | Block/limit only; no coins, no per‑app usage | M | n/a |
| **C** | Backend keeps a big internal `package → slug` dictionary; auto‑adds matches to a child's controllable set when `PUT /installed-apps` lands. Parent picks from "detected on the phone". | Dictionary + match logic | Full (catalog path) | M backend / S mobile | n/a |
| **D** | **Client‑only.** Make the installed‑apps rows tappable *iff* `ControlledApps.slugFor(package)` resolves → open the existing add/limit sheet. Unknown apps show "not controllable yet". | None | Full (catalog path) — but only the 4 mapped apps | S | n/a |
| **E** | Replace the rule key everywhere: `app_ref` = slug **or** package. Catalog becomes "suggestions". | Large migration, every app endpoint | Full | L | n/a |

**Decision:** ship **D** now (unblocks the mapped apps with zero backend risk,
gets the UX shape right), then **A + C** for the real feature — A to block
anything, C so the parent isn't handed a 120‑app list. B only if A's catalog
entanglement proves too heavy. E is the eventual tidy‑up, not urgent.

**iOS:** none of these apply. Package‑level blocking is impossible (opaque
tokens, child‑picks‑only). iOS stays on the FamilyActivityPicker selection +
`screen-time-status` counts — see §5 and §7.

### Rollout

| Step | Scope | Status |
|------|-------|--------|
| D — tappable rows → add/limit/block sheet for catalog‑mapped apps | mobile only | ✅ shipped |
| A — backend custom‑app rules + `GET /app-usage` returns package | backend + mobile | not started |
| C — package→slug dictionary, auto‑seed from `installed-apps` upload | backend + mobile | not started |
| Native: confirm `syncRules` enforces a package with no `<queries>` `<package>` line | Android | to verify on device |

**D as built** (`ParentInstalledAppsScreen`):

- Row for an app where `ControlledApps.slugFor(package) != null` shows a chevron
  and is tappable. Other rows tap to a "Safini can't limit this app yet" toast.
- Tap + rule already exists → opens `showAppLimitSheet` (the normal per‑app
  sheet).
- Tap + no rule → a small sheet: **Set a daily limit** (`addApp` with a 60‑min
  default, then opens the limit sheet to tune) or **Block completely**
  (`addApp` with `isLimited: false, canRedeem: false`).
- The screen is handed the Limits screen's `ParentAppsCubit` via
  `BlocProvider.value`, so the new rule shows on the Limits list on pop.
- Still catalog‑bounded: only the 4 apps in `ControlledApps.slugToPackage`.
  Broadening this is Step A/C.

---

## 11. Related docs

- `observation/app_blocking.md` — Android engine, native service, backend contract
- `observation/ios_screen_time_impl.md` — iOS Increment 1 (authorize → pick → shield)
- `observation/ios_parent_backend_sync.md` — parent/backend sync plan, proposed `screen-time-status` API
- `observation/child_get_apps.md` — why iOS has no installed‑app list; `canOpenURL` probe option
- `observation/screenzen_research.md` — shield configuration, app‑extension targets
- `BACKEND_TODO.md` — §4 installed‑apps (done), §5 screen‑time‑status
