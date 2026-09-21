# Overall daily budget

Safini has two independent rules: each app's daily limit and an optional overall
budget across Safini-managed apps. The sum of app limits is never a spendable
budget. Phone, Messages, Settings, always-allowed apps, and apps without a
Safini rule are outside this budget.

## Parent experience

Today and Limits show the same canonical `screen_time` snapshot:

- `global_limit_minutes: null`: no overall daily budget; show used time only.
- `global_limit_minutes: 0`: no free screen time, not unlimited.
- Positive limit: show the budget, used today, and remaining time separately.
- `usage_available: false`: show the configured budget and explain that usage
  and remaining time stay on the child's device. Do not display false zeroes.
- Missing/failed snapshot: show unavailable information, not a fabricated budget.

Limits has an on/off switch and an explicit duration editor (0 to 1440 whole
minutes). Changes require Save; Cancel makes no request. The editor explains
that an exhausted budget pauses all managed apps even if an individual app has
minutes left. Removing the budget leaves recorded usage and app rules intact.

Today, Tasks and Limits share the selected child for the parent session.
Selecting Everyone in Tasks explicitly clears its child filter. Opening Today
or Limits again retains that tab's last child until another child is selected.
Signing out disposes the parent shell and its selection. Tapped notifications
select their child. Loads discard obsolete results when the child changes.

## API and device enforcement

`screen_time` is authoritative; clients do not sum visible app rows or calculate
shared remaining time. The API companion adds `budget_scope` and `next_reset_at`
to app usage, dashboard, home and today responses. Reset is computed at midnight
following the requested day in the family timezone, including DST. Clients
format the supplied instant in the parent's local time. Older servers omit the
reset label; clients never guess it from the phone's midnight.

Configuration, usage reporting and enforcement are separate capabilities.
The API reports `configuration_available`; `usage_available` remains independent.
`enforcement_available: null` means unknown, not disabled. The existing device
status endpoint/card remains authoritative about setup and device connectivity.

The enforcement policy remains unchanged: effective app remaining time is the
smaller of the individual allowance and shared remaining allowance. Manual
blocks still win. Bonus minutes extend only the selected app and cannot bypass
an exhausted shared budget. Android retains its offline snapshot/usage ledger;
iOS uses Family Controls, Device Activity and Managed Settings on linked apps.
iOS policy changes synchronize when the child opens Safini.

## Verification

Regression coverage includes off, zero, positive and exhausted budgets; private
usage; canonical remaining values; duration validation; save, cancel and failed
saves; English, Russian and Uzbek layout; child selection and stale loads.
API tests cover fixed-offset timezones and a daylight-saving transition.

Simulators can verify the parent UI and API wiring. iOS Family Sharing approval
and actual OS shielding still require a real child device. The API metadata must
be deployed before the reset timestamp appears against the hosted service.
