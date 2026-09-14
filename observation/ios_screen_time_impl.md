# iOS Screen Time

The release implementation replaces the former debug-only prototype. Child mode
is enabled on iOS, with Apple Family Sharing child authorization required before
setup can complete. See `ios_screen_time_review.md` for provisioning and testing.

## Architecture

- Flutter: `IosScreenTimeCubit` loads the authenticated child's policy on entry,
  resume, every 30 seconds while foreground, and after successful redemption.
- Native setup: one app token is linked locally to each catalog rule. Apple does
  not tell Safini the selected app's identity; the supervising parent must choose
  the matching app. Categories, websites and overlapping selections are rejected.
- Links cannot be edited while authorized. The parent first revokes Safini's
  access in Apple Settings, then authorizes and links again. Signing out preserves
  enforcement. An authorized device cannot silently switch child accounts.
- `ScreenTimeMonitor` enforces daily per-app and aggregate limits through a named
  Managed Settings store, including manual blocks and zero-minute allowances.
  Events include past activity so foreground sync does not reset usage.
- Base and bonus thresholds are both scheduled. Bonuses expire at the family's
  midnight even while offline. A repeating base threshold remains for tomorrow.
- `ScreenTimeReport` renders today's / seven-day totals and app breakdown locally.
  It has no App Group entitlement and never writes or exports report data.
- `group.com.safini.app` is shared only by Runner and the monitor, for policy,
  opaque selection tokens and local threshold state. Tokens never reach the API.

## API dependency

Deploy the companion API migration and endpoints before releasing mobile:

- GET `/v1/children/{id}/screen-time-policy`: family timezone, global cap,
  per-app rules and today's granted bonus totals with expiry.
- PUT/GET `/v1/children/{id}/screen-time-status`: authorization, selected counts,
  monitoring/shield status, and server timestamp. Only the claimed child writes.
- Existing `/app-usage` includes `screen_time.usage_available=false` for a child
  with an iOS status. Parent views show local-report guidance instead of zeros.
- Existing app-time redemption remains the coin-ledger authority. Policy refresh
  failures after successful purchase are retried without repurchasing.

## Limits of this release

Rules update when the child opens Safini; background push policy delivery is not
implemented. Previously downloaded limits continue offline. Status is the last
foreground observation, not a live heartbeat or attestation.

Limits apply per child device, not as one shared multi-device budget. The global
cap covers the linked applications; it does not include unselected apps.
The parent cannot read the child's detailed iOS usage through Safini's backend.

No EU-only usage-export API or related entitlement is requested. This release
uses the standard privacy-preserving Screen Time reporting and controls APIs.
Shield appearance uses Apple's standard screen.
