# Daily screen-time budget: current behavior and proposed design

## Decision needed

Safini currently supports two independent controls:

1. A per-app daily limit, such as 30 minutes for Instagram.
2. An optional daily screen-time cap shared by all controlled apps, such as
   90 minutes across Instagram, YouTube, and Roblox.

The shared cap is useful as a family-wide upper bound, but the product must
present it as a separate, optional rule. The sum of app limits is not a budget
and must never be labelled as time a child can spend.

## What the app does today

The API returns a `screen_time` object containing:

- `global_limit_minutes`: the optional shared daily cap. `null` means no cap;
  `0` means no free time.
- `global_used_minutes`: time used today across controlled apps.
- `global_remaining_minutes`: remaining time under the shared cap.
- `usage_available`: whether the parent can see reliable device usage.

The Limits screen displays and edits `global_limit_minutes` in 15-minute
steps. When no shared cap exists, however, its allowance card falls back to
the sum of per-app limits. This is the main source of confusion: that sum is
not spendable across apps. A child with 60 minutes of YouTube and 30 minutes
of Instagram cannot spend all 90 minutes in either app.

The Today screen uses only the real shared cap for its ring. If there is no
cap, it shows usage without a remaining-time claim. This is more accurate than
the fallback currently used on Limits, but the two tabs can appear to describe
different systems.

## What happens if the parent sets 15 minutes

On Android, the enforcement policy calculates both the selected app's
remaining minutes and the shared remaining minutes, then uses the smaller of
the two. Once the combined usage of controlled apps reaches 15 minutes, every
controlled app is blocked for the rest of the family-local day. Phone,
Messages, Settings, always-allowed apps, and apps without a Safini rule are not
closed by this cap. A manual block still wins immediately, and an individual
app can run out before the shared cap.

Purchased bonus minutes extend an individual app allowance, but they do not
bypass an exhausted shared cap. The server refuses purchases after the shared
cap is spent. Both budgets reset at the next family-local midnight.

Android keeps a local snapshot and foreground-usage ledger so enforcement can
continue offline. It reconciles the local total with server-known usage to
avoid granting the same time twice after a restart or sync.

On iOS child devices, the same global cap is enforced across apps explicitly
linked during the Family Controls setup. Apple's Device Activity monitor and
Managed Settings shield enforce the thresholds, including while Safini is not
open. Detailed usage remains local to the child device, so the parent API marks
usage as unavailable instead of reporting false zeroes. Policy changes sync
when the child opens Safini; simulator builds verify wiring but only a real
device in Apple Family Sharing can verify authorization and enforcement.

## Problems to fix after product approval

- Limits uses the sum of per-app limits when the shared cap is off.
- Plus/minus controls mutate a powerful whole-device rule without a clear
  explanation of which apps it covers.
- The Today data model converts both “no cap” and a zero-minute cap to `0`, so
  it cannot communicate those states differently.
- Some UI calculations sum app rows instead of using the API's canonical
  `global_used_minutes` and `global_remaining_minutes`.
- “All apps combined” sounds like every installed app, while enforcement only
  covers apps with Safini rules.

## Recommended product design

Keep the shared budget, but make it explicitly optional and distinct from app
limits.

### Today

When a shared budget is enabled, show one card with three explicit values:

- Daily budget: 1 h 30 m
- Used today: 45 m
- Remaining: 45 m

The supporting text should say “Across apps managed by Safini.” When the cap
is exhausted, show that managed apps are paused until the reset time. When the
cap is off, show “No overall daily budget” and only “Used today”; do not invent
remaining time from app limits.

### Limits

Place a separate “Overall daily budget” control above the app list. Use an
on/off switch plus an explicit duration editor instead of an unexplained
stepper. Before saving, explain that reaching it pauses all apps managed by
Safini even when an individual app still has time. Keep per-app rows and their
limits below as independent rules.

### Architecture

- Preserve nullable cap semantics end to end: `null` is off and `0` is a real
  zero-minute cap.
- Treat the backend `screen_time` object as the source of truth on both Today
  and Limits.
- Use `global_used_minutes` and `global_remaining_minutes` directly for shared
  budget UI; do not recompute them from visible rows.
- Keep per-app remaining time as `min(app remaining, global remaining)` in
  enforcement.
- Return the next reset timestamp and budget scope from the API so clients do
  not infer timezone or coverage.
- Track separately whether configuration, usage reporting, and enforcement are
  available on the selected child's platform.

## Acceptance scenarios for the future redesign

1. No shared cap: Today shows real usage and no remaining-time claim; per-app
   limits continue independently.
2. A 15-minute shared cap with two managed apps: 10 minutes in one leaves 5
   minutes in both; another 5 minutes blocks both.
3. One app reaches its own limit first: that app blocks while another managed
   app remains usable until its own or the shared limit is reached.
4. A zero-minute cap: managed apps are immediately blocked and the UI says
   “No free screen time,” never “unlimited.”
5. The cap is removed: managed apps return to their individual rules without
   losing usage already recorded that day.
6. A bonus is purchased: it extends the selected app only while shared budget
   remains.
7. Offline use and a device restart do not reset either consumed allowance.
8. Parent views in English, Russian, and Uzbek describe the same scope and
   values.

This document intentionally does not change the shared-budget product in this
PR. The onboarding exit, installed-app limit flow, and task-template changes
can ship independently while the product decision above is reviewed.
