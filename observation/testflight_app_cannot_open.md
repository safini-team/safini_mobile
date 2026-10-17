# TestFlight "app cannot be opened"

## What this error actually means

iOS validates code signature + entitlements against the provisioning profile
**at launch**, not just at install. "Cannot be opened" is that validation
failing — an entitlement the binary claims that the embedded provisioning
profile doesn't grant. It is not a Dart/Flutter runtime crash, so stack
traces / Crashlytics won't show it. Check `Settings > Privacy & Security >
Analytics Data` or a sysdiagnose on the test device for the actual
`Trust`/`amfid` denial reason if a fix below doesn't stick.

Already fixed once (see commit `9b0d946`): Runner's shared
`Runner.entitlements` had `aps-environment: development`, which is invalid in
a Release/distribution profile (App Store profiles only grant `production`).
Release now signs with its own `Runner-Release.entitlements`
(`aps-environment: production`); Debug/Profile keep the development one.

If it recurs after that fix, work down this list.

## Checklist

1. ✅ **Automatic-signing capability drift.** Entitlements files here are edited
   by hand, not through Xcode's Signing & Capabilities UI. Xcode's automatic
   signing only requests capabilities it sees added through that UI, or that
   already exist on the App ID in the Developer Portal. Editing the `.plist`
   directly can silently outrun what's registered for `com.safini.app`,
   `com.safini.app.ScreenTimeMonitor`, `com.safini.app.ScreenTimeReport` on
   developer.apple.com. Open each target's Signing & Capabilities tab in
   Xcode and confirm the capability list matches every key in its
   entitlements file (family-controls, app-groups, applesignin,
   aps-environment on Runner only). — checked, matches.

2. ✅ **Family Controls distribution approval.** `com.apple.developer.family-controls`
   for **development** is self-service, but Apple must separately approve it
   for **App Store distribution**. If that approval is still pending/missing
   for this Team ID, the distribution profile is issued without the
   entitlement even though the App ID page shows it enabled — binary claims
   it, profile doesn't grant it, launch fails. Check
   developer.apple.com → Certificates, IDs & Profiles → the app's Family
   Controls entitlement request status. — approved.

3. **Stale cached provisioning profiles.** Automatic signing caches profiles
   locally and doesn't always refetch after a portal-side change. After
   touching entitlements or capabilities: Xcode → Settings → Accounts →
   select team → "Download Manual Profiles", or delete
   `~/Library/MobileDevice/Provisioning Profiles/*` and re-archive so Xcode
   is forced to regenerate. Cache was already empty on this machine
   (`rm` found no matches) — if a stale profile is still getting embedded,
   the cache isn't the culprit; also try wiping DerivedData
   (`~/Library/Developer/Xcode/DerivedData/Runner-*`), since a full re-archive
   can otherwise reuse a cached `embedded.mobileprovision` from a prior build.

4. ✅ **App Group registration.** `group.com.safini.app` must exist as a
   registered App Group in the portal and be attached to both the Runner and
   ScreenTimeMonitor App IDs (ScreenTimeReport intentionally has no App
   Group — don't add one). A literal string match in the `.entitlements`
   file isn't sufficient if the portal-side App Group attachment is missing.
   — confirmed registered and attached.

   ⚠️ Side finding while checking this: `ScreenTimeReport.entitlements` now
   has an empty `com.apple.security.application-groups` array (previously no
   App Groups key at all). That's Xcode's Signing & Capabilities UI adding
   the capability with nothing selected — decide whether to revert to no key
   (matches the "intentionally no App Group" design in
   `ios_screen_time_review.md`) or actually attach the group and register it
   for this App ID in the portal. Left as-is pending that decision.

5. ✅🎯 **ROOT CAUSE, found and fixed.** Every framework in the archive —
   including `Runner.app` itself — was signed `Apple Development: Ramil
   Salikhar`, not `Apple Distribution`. Verified with:
   ```bash
   for fw in build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/*; do
     codesign -dvvv "$fw" 2>&1 | grep -i authority
   done
   ```
   Cause: `project.pbxproj` pinned
   `"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer"` at the
   **project level**, in all three build configs (Debug/Release/Profile —
   `project.pbxproj:732,946,1003` before the fix). No target overrode it, so
   every target inherited it. `CODE_SIGN_STYLE = Automatic` only controls
   which *profile* gets picked; this pinned line forced the *identity class*
   to Development even for the Release archive, so the export step's
   `ExportOptions.plist` saying `app-store-connect` never mattered — the
   binary was already wrong before export.

   Likely a leftover from this project's original Xcode 7.3.1 template
   (`CreatedOnToolsVersion = 7.3.1` on the Runner target) predating modern
   Automatic Signing, never cleaned up since.

   **Fixed**: removed all three occurrences of that line from
   `project.pbxproj`. Re-archive and re-run the `codesign -dvvv` loop above —
   every framework should now show `Apple Distribution: ...`.

6. **`ExportOptions.plist` regenerated with the wrong method.** The one at
   `build/ios/ipa/ExportOptions.plist` is Xcode-generated (not committed);
   confirm `method` is `app-store-connect` and `signingStyle` is
   `automatic` before every export — a stray manual edit or a different
   local Xcode default can silently switch it to `development`/`ad-hoc`,
   which produces an IPA that only runs on UDID-registered devices and
   "cannot be opened" for everyone else in TestFlight.

7. **Build number not bumped.** Lower priority (usually a rejected/stuck
   upload rather than a launch crash), but confirm `pubspec.yaml`'s build
   number increased since the last accepted TestFlight build before
   re-uploading, so you're not chasing a stale cached build on the test
   device.

8. ✅ **Push Notifications capability not enabled on the App ID.** New since
   commit `1509cc4` (Enable push notifications on iOS). The `aps-environment`
   entitlement key alone isn't sufficient — the App ID in the portal needs
   the Push Notifications capability explicitly turned on, or the
   distribution profile won't carry it even though the entitlements file
   asks for it. Same failure shape as #2/#4: entitlement claimed, profile
   doesn't grant it. — confirmed enabled for `com.safini.app`.

9. **Stale `embedded.mobileprovision` from DerivedData**, not just the
   profile cache checked in #3. A full re-archive can still re-embed a
   profile cached inside `~/Library/Developer/Xcode/DerivedData/Runner-*` /
   the local `build/ios/` output rather than the freshly downloaded one.
   Worth a `flutter clean` + DerivedData wipe if #1–#8 all check out and the
   crash persists.

Ruled out this round: `IPHONEOS_DEPLOYMENT_TARGET` (17.4, consistent across
all 9 build configs and all 3 targets), `Podfile` (no custom signing
overrides — stock `flutter_additional_ios_build_settings`, so pods inherit
whatever Xcode picks, consistent with #5 being the thing to check if it's
pods-related), `GoogleService-Info.plist` `BUNDLE_ID` (matches
`com.safini.app` exactly).

## Related but distinct: missing dSYM for `objective_c.framework`

Different symptom (Xcode Organizer / archive validation, not a device launch
crash), surfaced during this same investigation:

> The archive did not include a dSYM for the objective_c.framework with the
> UUIDs [...]. Ensure that the archive's dSYM folder includes a DWARF file
> for objective_c.framework with the expected UUIDs.

`objective_c.framework` isn't built by Xcode — it's built by Dart's
native-assets hooks runner (`.dart_tool/hooks_runner`), a transitive
dependency pulled in by `google_sign_in_ios` (from `google_sign_in: ^7.2.0`,
which uses FFI bindings via `package:objective_c`). That build path compiles
with clang directly and never gets Xcode's
`DEBUG_INFORMATION_FORMAT = dwarf-with-dsym` (confirmed set correctly for
Release at `project.pbxproj:1005` — the setting is fine, it just never
applies to this framework), so no dSYM is generated or embedded.

Options, in order:
1. `flutter upgrade` (currently 3.41.6, ~6 months stale) — actively-tracked
   native-assets gap, may already be fixed upstream.
2. Try distributing anyway — this is sometimes a non-blocking warning in
   Organizer.
3. Stopgap, generate the dSYM manually and drop it into the archive before
   export:
   ```bash
   dsymutil build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c \
     -o build/ios/archive/Runner.xcarchive/dSYMs/objective_c.framework.dSYM
   ```

## Related but distinct: "The requested app is not available or doesn't exist"

Third symptom in this same investigation, appearing *after* #5's signing fix
was confirmed correct (export IPA's `DistributionSummary.plist` shows every
binary signed `Apple Distribution: Ramil Salikhar (X3B4RJS8GN)`, no errors in
`Packaging.log`). Build uploads and appears in App Store Connect, but tapping
Install in the TestFlight app on a test device shows this exact message.

This is TestFlight's stock error for "the build exists, but this tester
can't actually reach it" — an App Store Connect distribution/config problem,
not a code or signing one. None of it is checkable from this repo; walk the
App Store Connect side:

1. **Export Compliance not answered.** TestFlight tab → this build. A
   "Missing Compliance" flag hides the build from testers even though it
   finished processing.
2. **Build not attached to a test group.** Uploading only makes the build
   exist in App Store Connect — it isn't visible to anyone until it's added
   to an Internal or External testing group the tester is a member of.
3. **Tester's Apple ID ≠ invited email.** The TestFlight app on the device
   must be signed into the exact Apple ID that was added as a tester.
4. **Wrong Team.** The local keychain has Distribution/Development
   identities for multiple people (Nino Jangavadze, Aziret Karashev, Ramil
   Salikhar) across different teams. Confirm the App Store Connect app
   record for `com.safini.app` is the one under Team `X3B4RJS8GN`, and that
   the invite link/QR the tester used points at that same record — not a
   stale duplicate app record under a different team.
5. **Expired build or invite link.** TestFlight builds expire ~90 days after
   upload; old invite links/QR codes stop resolving.

## Verifying a fix

Simulator can't validate any of this — it doesn't enforce provisioning at
all. Confirm on a real device:

1. Archive with the exact Xcode/`flutter build ipa` flow used for upload.
2. Install via TestFlight (not a direct Xcode run — that uses a different,
   more permissive development signing path).
3. Cold-launch from the TestFlight app itself, not from the home screen icon
   left over from a previous install.
