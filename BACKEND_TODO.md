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

## 4. Child installed-apps list — MISSING (app-blocking feature)

**Problem:** the parent needs to see the apps that are actually installed on the
child's device (to monitor and, later, to pick which apps to control). The child
device can enumerate them natively, but there is **no endpoint to store or read
that list**. The mobile side is already built against the contract below (child
uploads on app start; parent reads).

**Fix:**

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

**Client status:** fully built and waiting on this endpoint. Child upload
(`ChildAppRulesService.reportInstalledApps`) and the parent read path
(`ParentAppBlockingService.fetchInstalledApps` → `ParentInstalledAppsScreen`,
reachable from the Limits screen) are done, gated behind
`AppConstants.childInstalledAppsShipped`. Flip that flag to `true` once this
endpoint ships.

**Unblocks:** parent visibility of the child's real apps; foundation for a
"pick from the child's apps" flow instead of the hardcoded catalog in #1.

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
| 4 | `PUT/GET /children/{id}/installed-apps` | new | needed — parent sees child's apps |

Per `AGENTS.md`: branch `codex/...`, test-first, access control on every route,
Alembic migration if schema changes, update the Scalar docs, then
`pre-commit run --all-files` and `pytest`.
