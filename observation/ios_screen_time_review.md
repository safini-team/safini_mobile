# Screen Time release verification

## Before signing

Register/approve Family Controls **distribution** for all three bundle IDs:

- `com.safini.app`
- `com.safini.app.ScreenTimeMonitor`
- `com.safini.app.ScreenTimeReport`

Register App Group `group.com.safini.app` and attach it to Runner and
ScreenTimeMonitor only. Refresh provisioning profiles. The report extension
intentionally has no App Group. Do not add the EU-only app-and-website-usage
entitlement. Keep Sign in with Apple enabled on Runner.

The Xcode project includes both extension targets and embeds them in Runner.
They inherit the app version/build number from Flutter/Generated.xcconfig.
Increment the build number before the next App Store upload.

Deploy the companion API migration and routes before distributing this build.

## Real-device verification (required before submission)

Simulator compilation checks wiring; it cannot validate Screen Time behavior.
Use a real iPhone or iPad with a child Apple Account in the supervising parent's
Apple Family Sharing group. A Safini family invite alone does not establish that
Apple relationship. Provide the reviewer both Safini test accounts and explain
this device prerequisite in App Review Information.

1. Parent signs into Safini and adds at least one rule under Limits.
2. Child signs in / claims their profile. Screen Time setup opens automatically.
3. Tap Allow Screen Time; the Apple Family Sharing parent approves.
4. Tap the rule and select its matching installed app in Apple's picker.
   Select exactly one app, not the category. Completing all links opens child mode.
5. Child opens Me → Screen Time → View activity report. Today and 7 days display
   Apple's local usage report. No usage report is uploaded.
6. Set a low per-app cap, reopen child Safini to sync, use the selected app, and
   verify Apple's shield appears at the threshold with Safini closed.
7. Earn coins from an approved task, buy extra minutes in Store, and verify the
   selected app unlocks up to the extended threshold. A manual block or exhausted
   global cap must still block it. A failed policy sync shows a retry notice;
   retry syncing, not buying the same minutes again.
8. Verify midnight in the family's timezone removes yesterday's bonus and resets
   daily thresholds while offline. Verify a zero base cap blocks again tomorrow.
9. Change the parent rule, reopen child Safini, and verify the updated limit.
   Remove all rules and confirm previously shielded apps are released.
10. Revoke authorization, test denied access and retries, then authorize again.
    Sign out and verify that doing so does not lift parental controls. A different
    child account must not inherit the previous child's mappings.
11. Parent Limits shows last-reported iOS status and directs usage viewing to the
    child's device. Do not interpret an old timestamp as current protection.

## App Review Notes (adapt after real-device verification)

Safini includes Apple Screen Time functionality. On the child's iPhone/iPad,
complete the Screen Time setup after signing in: Allow Screen Time → parent
approval → select the matching app for each parent-configured rule. The child
Apple Account must be in the parent's Apple Family Sharing group.

Navigate to Me → Screen Time → View activity report to view today's or the last
seven days' activity. Rules are configured in the parent's Limits tab and sync
when Safini is open on the child device. Daily thresholds are enforced by the
Device Activity Monitor extension; selected apps are shielded using Managed
Settings. Detailed usage reports stay on device and are not stored on our server.

Safini has parental-control functionality but does not provide age assurance.
Age Assurance remains None. Review all metadata against the verified build.
