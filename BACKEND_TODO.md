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

## 1. Controlled apps catalog — MISSING

**Problem:** the parent "Add app" flow fails with
`Controlled app was not found`, because `PUT /children/{id}/app-rules/{slug}`
only accepts a slug from the server-side `app_catalog`, and there is **no
endpoint to fetch that catalog**. The mobile app currently hardcodes the list
(`youtube-kids`, `roblox`, `brawl-stars`, `minecraft`).

**Fix:**

```
GET /v1/apps
Auth: Bearer <access_token> (parent)
```

```json
{
  "apps": [
    {
      "app_slug": "youtube-kids",
      "display_name": "YouTube Kids",
      "default_daily_limit_minutes": 60,
      "default_redeem_coin_cost": 100,
      "default_redeem_reward_minutes": 30
    }
  ]
}
```

Source: the same `app_catalog` table that validates `PUT /app-rules`.

**Unblocks:** the real, current catalog in "Add app" with no client hardcoding.

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
| 1 | `GET /apps` | new | needed — unblocks "Add app" |
| 2 | `GET /children/{id}/activity` | new | needed — unblocks monitor widgets |
| 3 | `avatar_state` in `families/current.children[]` | change | optional |

Per `AGENTS.md`: branch `codex/...`, test-first, access control on every route,
Alembic migration if schema changes, update the Scalar docs, then
`pre-commit run --all-files` and `pytest`.
