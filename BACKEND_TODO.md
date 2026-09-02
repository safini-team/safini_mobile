# Safini Backend TODO

Findings from integrating the Flutter app against `safini-api`
(verified by reading the backend source, not just the OpenAPI examples).

---

## ✅ Child profile & avatar — NO backend change needed

`GET /v1/children/{child_id}/home` is child-accessible and already returns
`"child": serialize_child_row(child)`. And `serialize_child_row`
(`app/services/safini_support.py`) already includes everything:

```
avatar_state, level, xp, current_streak_days, longest_streak_days,
tasks_completed_count, coins_balance, achievements_count
```

The OpenAPI example for `/home` is abbreviated (`{child: {id, nickname}}`),
which is what misled the mobile side.

**The bugs were in the mobile app — already fixed there:**

1. It called the **parent-only** `/children/{id}/dashboard`, which correctly
   returns **403** for a child. Now it calls `/home`.
2. It wrote the face emoji into `avatar_state.equipped`. The backend correctly
   validates `equipped` against the child's owned inventory
   (`app/controllers/children.py::update_avatar`), so a raw emoji was rejected
   with **400 "Avatar state references items the child does not own"** — the
   save silently failed. The face now goes only into the free-form
   `avatar_state.emojis`, and `equipped` is echoed back untouched.

Backend behaviour here is correct. Nothing to change.

---

## 1. Controlled apps catalog — ✅ DONE (backend live; client wired)

**Was:** the parent "Add app" flow hardcoded the list
(`youtube-kids`, `roblox`, `brawl-stars`, `minecraft`) because no catalog
endpoint existed.

**Now:** `GET /v1/apps` is live (verified against `https://api.safini.fun/openapi.json`
on 2026-08-24) **and the client already consumes it** — `CatalogAppModel`,
`IParentAppUsageRepository.fetchCatalog()` →
`ParentAppUsageRepositoryImpl` (`GET /v1/apps`), `ParentAppsCubit.loadCatalog()`,
and `add_app_sheet.dart` (filters already-added slugs, seeds defaults from the
catalog). The old `_knownApps` list is gone. It returns:

```json
{
  "apps": [
    {
      "app_slug": "youtube-kids",
      "display_name": "YouTube Kids",
      "default_daily_limit_minutes": 60,
      "default_redeem_coin_cost": 100,
      "default_redeem_reward_minutes": 30,
      "default_is_limited": true,
      "default_can_redeem": true,
      "is_default_for_new_child": true
    }
  ]
}
```

Note: `GET /children/{id}/app-usage` also gained `bonus_minutes_remaining` and
`total_minutes_available` fields (additive; existing parsing still works).

---

## 2. Monitor activity (steps + weekly screen-time) — MISSING

**Problem:** the parent monitor widgets "Steps today" and "Weekly screen time"
are hidden in the app because there is no data source. `steps` is POST-only and
`app-usage` GET returns today only.

**Fix:**

```
GET /v1/children/{child_id}/activity?days=7
Auth: Bearer <access_token> (parent of this child)
```

```json
{
  "steps_today": 4230,
  "steps_change_pct": 12,
  "weekly_screen_time_minutes": [40, 55, 30, 70, 100, 80, 60],
  "week_start": "2026-07-02"
}
```

- `weekly_screen_time_minutes` — daily sums of `used_minutes` over 7 days,
  aggregated from `child_app_usage`.
- `steps_today` — from the latest `POST /steps` for today.

**Unblocks:** re-enabling the hidden monitor widgets (`hasActivityData` flag in
`ParentMonitorLoaded`).

---

## 4. Child installed-apps list — ✅ DONE (backend live; client wired)

**Was:** the parent needed to see the apps actually installed on the child's
device, but there was no endpoint to store or read that list.

**Now:** both endpoints are live and the client consumes them —
`ChildAppRulesService.reportInstalledApps` (child `PUT` on app start),
`ParentAppBlockingService.fetchInstalledApps` →
`InstalledAppsSnapshot` (apps + `updated_at`) → `ParentInstalledAppsCubit` →
`ParentInstalledAppsScreen`. `AppConstants.childInstalledAppsShipped` is now
`true`, so the "See all apps on this phone" row shows on the Limits screen.
A parent `PUT` correctly returns **403** (child token only). `updated_at: null`
is rendered as "no apps synced yet"; a non-null value shows a "Last synced …"
line above the list.

**Contract (as shipped):**

```
PUT /v1/children/{child_id}/installed-apps      (child uploads its own snapshot)
GET /v1/children/{child_id}/installed-apps      (parent of child, or the child, reads)
Auth: Bearer <access_token>
```

Request body for `PUT` (full snapshot — replace, not merge):

```json
{
  "apps": [
    { "package_name": "com.roblox.client", "app_name": "Roblox" },
    { "package_name": "com.google.android.apps.youtube.kids", "app_name": "YouTube Kids" }
  ]
}
```

Response for `GET`:

```json
{
  "apps": [
    { "package_name": "com.roblox.client", "app_name": "Roblox" }
  ],
  "updated_at": "2026-08-24T12:00:00Z"
}
```

- Access control: a child may write/read **only their own** row; a parent may
  read (and should not write) their child's row.
- Suggested storage: one `child_installed_apps` row per child holding the JSON
  array + `updated_at`, replaced wholesale on each `PUT`.
- Platform is Android-only for now (iOS cannot enumerate installed apps); an
  optional `platform` field can be added later if needed.

**Unblocks:** parent visibility of the child's real **Android** apps. iOS cannot
enumerate apps — that path is Screen Time **status** instead (see #5).

Linear: [SAF-153](https://linear.app/safini-team/issue/SAF-153/backend-putget-installed-apps-so-parent-can-see-childs-android-apps)

---

## 5. iOS Screen Time status for the parent — MISSING

**Problem:** iOS Screen Time Increment 1 works on-device, but the parent has no
signal that the child's iPhone authorized Screen Time, how many apps were
picked, or whether the shield is on. Apple does not allow an installed-app list
or per-app minutes on iOS.

**Fix:**

```
PUT /v1/children/{child_id}/screen-time-status    (child)
GET /v1/children/{child_id}/screen-time-status    (parent of child, or the child)
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

- Never store Screen Time **tokens** (not names, not portable, not ours to send).
- Access: child writes own row; parent reads.

**Client status:** plumbing built ahead of the endpoint — `ApiConst.childScreenTimeStatus`,
`ScreenTimeStatus` model, `ChildAppRulesService.reportScreenTimeStatus` /
`fetchScreenTimeStatus`, and a round-trip button on the iOS
`ChildScreenTimeDebugScreen` (Kid · Me → DEV · Screen Time). Until this ships
the GET returns 404, which the dev screen shows verbatim. No parent UI yet.

Linear: [SAF-154](https://linear.app/safini-team/issue/SAF-154/ios-report-screen-time-status-to-backend-so-parent-can-see-it)
Design: `observation/ios_parent_backend_sync.md`.

---

## 3. Child avatar in the family list — optional optimization

`GET /families/current` does not include `avatar_state` in `children[]`, so to
show each child's face the app fetches that child's `/dashboard` separately.

**Fix:** include `avatar_state` (or just a `face_emoji`) per `children[]` item.

**Unblocks:** parent sees every child's face with no extra request per child.

---

## Summary

| # | Endpoint | Type | Status |
|---|---|---|---|
| — | `GET /children/{id}/home` | — | ✅ already complete, no change |
| 1 | `GET /apps` | new | ✅ live — client wired (`fetchCatalog`) |
| 2 | `GET /children/{id}/activity` | new | needed — unblocks monitor widgets |
| 3 | `avatar_state` in `families/current.children[]` | change | optional |
| 4 | `PUT/GET /children/{id}/installed-apps` | new | ✅ live — client wired ([SAF-153](https://linear.app/safini-team/issue/SAF-153)) |
| 5 | `PUT/GET /children/{id}/screen-time-status` | new | needed — [SAF-154](https://linear.app/safini-team/issue/SAF-154) iOS parent status |

Per `AGENTS.md`: branch `codex/...`, test-first, access control on every route,
Alembic migration if schema changes, update the Scalar docs, then
`pre-commit run --all-files` and `pytest`.
