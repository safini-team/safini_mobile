# Next: backend + parent for app blocking

> **Where we are:** Android can enforce and (client-side) upload apps. iOS Screen
> Time Increment 1 works **on the child's iPhone only**. The parent app still
> cannot see iOS Screen Time state, and iOS does not apply parent-set rules.
>
> Linear parent: [SAF-93](https://linear.app/safini-team/issue/SAF-93/randd-app-blocking)

---

## Do next (in this order)

| # | Do this | Owner | Linear |
|---|---------|--------|--------|
| **1** | Ship `PUT/GET /installed-apps`. Flip `childInstalledAppsShipped`. | Backend, then mobile | [SAF-153](https://linear.app/safini-team/issue/SAF-153) |
| **2** | Child iOS `PUT` Screen Time **status**; parent `GET` + UI. | Backend + mobile | [SAF-154](https://linear.app/safini-team/issue/SAF-154) |
| **3** | iOS child `GET /app-usage` and apply/clear the **local** shield from parent rules. | Mobile | [SAF-156](https://linear.app/safini-team/issue/SAF-156) |
| **4** | DeviceActivityMonitor + shield extensions (daily limits that survive app kill). | Mobile / Xcode | [SAF-155](https://linear.app/safini-team/issue/SAF-155) |
| — | Confirm Family Controls on **TestFlight + App Store**, not development-only. | Account Holder | [SAF-135](https://linear.app/safini-team/issue/SAF-135) |

**Start with 1 and 2 in parallel.** 3 can start on Increment 1 (block/unblock only). 4 is required before iOS daily *minute* limits match Android.

---

## What already talks to the backend (Android)

Parent sets catalog rules (`PUT /app-rules/{slug}`). Child device enforces.

| Flow | Endpoint | Status |
|------|----------|--------|
| Catalog | `GET /v1/apps` | Live, parent Add-app uses it |
| Rules + remaining today | `GET /v1/children/{id}/app-usage` | Live; Android child syncs into native overlay |
| Usage minutes | `POST /v1/children/{id}/app-usage` `{app_slug, used_minutes}` | Live; Android reports since-midnight |
| Installed apps | `PUT/GET /v1/children/{id}/installed-apps` | **Missing** — client built, flag off |
| iOS Screen Time status | (none) | **Missing** — see § proposed API |

Code: `ChildAppBlockCubit` + `ChildAppRulesService` (child), `ParentAppBlockingService` + Limits UI (parent). Cubit **returns immediately on iOS** (`AppBlockService.isSupported` is Android-only).

---

## What iOS can and cannot send to the parent

Apple's Screen Time API returns **opaque tokens**. No names, no bundle IDs, no
per-app minutes we can read. Tokens are **per-device** and must **never** go to
the backend.

| Parent wants | Android | iOS |
|--------------|---------|-----|
| List of apps on the phone | Yes (`PackageManager`) | **Impossible** (sandbox) |
| Minutes used per catalog app | Yes (`UsageStatsManager`) | **No** (only DeviceActivity *thresholds* in Increment 2) |
| Screen Time authorized? | n/a | Yes — `AuthorizationCenter` |
| How many apps/categories picked? | n/a | Yes — token **counts** only |
| Shield on/off? | Overlay state (local) | Yes — we know if we wrote the store |
| "Block Roblox specifically" | slug → package | **No 1:1 map.** Parent limit applies to whatever the child picked in Apple's picker. |

So the parent iOS story is **status**, not an app list. UX copy: *Screen Time on · 3 apps selected · shield active* — not a named list.

---

## Proposed API for (2) — Screen Time status

```
PUT /v1/children/{child_id}/screen-time-status    // child
GET /v1/children/{child_id}/screen-time-status    // parent or child
```

```json
{
  "platform": "ios",
  "authorization": "approved",
  "selected_applications": 3,
  "selected_categories": 1,
  "shield_active": true,
  "updated_at": "2026-08-27T00:00:00Z"
}
```

`authorization`: `notDetermined | denied | approved | unavailable`.

Child writes after auth, picker, apply, clear (`ScreenTimeService` already
exposes these fields). Parent Limits / child detail **reads** it.

Android does not use this; it keeps `POST /app-usage`.

---

## How parent rules become an iOS shield (3)

Do **not** port `ControlledApps.slugToPackage`. There is no package.

1. Parent still edits catalog slugs (`is_limited`, `daily_limit_minutes`) — same UI.
2. On the iPhone, someone picks apps in `FamilyActivityPicker` (tokens stay local).
3. Child `GET /app-usage`. If any controlled app is blocked or `remaining_minutes_today <= 0`, **apply shield to the whole local selection**. If all have remaining time, **clear shield** (Increment 1) or schedule a threshold (Increment 2).
4. Consequence: we cannot shield "only YouTube Kids" unless that is what was picked. Parent copy must say the iPhone selection is the enforcement set.

---

## Related docs

- `observation/block_flow.md` — the Android‑vs‑iOS setup fork and unified flow
- `observation/app_blocking.md` — Android engine + architecture
- `observation/ios_screen_time_impl.md` — iOS Increment 1 status
- `observation/child_get_apps.md` — why iOS has no app list
- `observation/screenzen_research.md` — shield / extensions
- `BACKEND_TODO.md` — §4 installed-apps, §5 screen-time-status
