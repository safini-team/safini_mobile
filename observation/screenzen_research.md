# ScreenZen — Reverse-Engineering the iOS Blocking Flow

> How [ScreenZen](https://apps.apple.com/us/app/screenzen-screen-time-control/id1541027222)
> asks for Screen Time, lets you pick app categories, and shows a block
> "overlay" on iOS — and what that means for Safini's own iOS blocking track.
>
> This is a design/research note, not an implementation. It complements
> `child_get_apps.md` §6 (iOS options) and `app_blocking.md` §9 (iOS constraints).

---

## 1. TL;DR

ScreenZen does **not** draw its own overlay window the way an Android app does.
On iOS that is impossible for a sandboxed app. Instead it drives Apple's
**Screen Time API**, and the block screen is Apple's **system "shield"** that the
OS draws over a restricted app. ScreenZen only customizes that shield's look and
its buttons.

Three Apple frameworks + one UI framework do the work:

| Framework | Role in ScreenZen |
|-----------|-------------------|
| **FamilyControls** | Gateway: requests Screen Time authorization; provides the `FamilyActivityPicker` and the opaque app/category tokens. |
| **ManagedSettings** | Enforcer: `ManagedSettingsStore.shield.*` = the tokens → the OS shields (blocks) those apps/categories. |
| **DeviceActivity** | Scheduler: decides *when* the rules are active (time ranges, usage thresholds) via a `DeviceActivityMonitor` extension. |
| **ManagedSettingsUI** | The block screen: `ShieldConfigurationDataSource` (look) + `ShieldActionDelegate` (button taps). |

On top of Screen Time, ScreenZen also uses a **Shortcuts "Open App" automation**
to get its richer full-screen "breathe / wait / is this important?" interstitial,
which the shield alone cannot render. That is why its setup asks for **both
Screen Time and Shortcuts** permissions.

---

## 2. Step 1 — Asking for Screen Time (authorization)

ScreenZen is a **self-control** app (you restrict your own device), so it uses
**individual authorization** — added in iOS 16, it lets an app manage the device
it runs on without Family Sharing or a separate parent device.

```swift
import FamilyControls

try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
// .child would be used on a device managed by a parent (Family Sharing).
```

- First call shows a system alert, then requires Face ID / Touch ID / passcode.
- Once granted, subsequent calls silently succeed.
- The user can revoke it in **Settings → Screen Time → Apps with Screen Time
  Access**, and there is a per-app "Screen Time Restrictions" switch.
- **Entitlement:** requires `com.apple.developer.family-controls`. This is a
  **special entitlement you must request from Apple** (it is gated, not part of
  the normal provisioning profile). Without it the frameworks throw at runtime.

> This authentication step is exactly what the user described as "asking for
> screen time."

Sources: [WWDC22 "What's new in Screen Time API"](https://developer.apple.com/videos/play/wwdc2022/110336/),
[Developer's guide to the Screen Time APIs](https://medium.com/@juliusbrussee/a-developers-guide-to-apple-s-screen-time-apis-familycontrols-managedsettings-deviceactivity-e660147367d7).

---

## 3. Step 2 — Selecting the category of apps

ScreenZen presents Apple's system **`FamilyActivityPicker`** (SwiftUI). The user
ticks individual apps **and/or whole categories** (Social, Games, Entertainment,
…). The picker runs out-of-process so ScreenZen never sees the raw list.

```swift
import FamilyControls
import SwiftUI

struct PickerView: View {
  @State private var selection = FamilyActivitySelection()
  var body: some View {
    Text("Choose apps to block")
      .familyActivityPicker(isPresented: $showing, selection: $selection)
  }
}
```

What you get back is a `FamilyActivitySelection` of **opaque tokens**:

- `selection.applicationTokens`  → `Set<ApplicationToken>`
- `selection.categoryTokens`     → `Set<ActivityCategoryToken>`  ← "category of apps"
- `selection.webDomainTokens`    → `Set<WebDomainToken>`

**Critical privacy limit:** these tokens carry **no name and no bundle id**. You
cannot read what the user picked, list it, or show your own labels — you can only
hand the tokens back to the OS to shield. (This is the same limitation noted in
`child_get_apps.md` §6, Option B.)

---

## 4. Step 3 — Blocking with the "overlay" (the shield)

### 4.1 Applying the block

Assigning tokens to a `ManagedSettingsStore`'s `shield.*` makes the OS shield
(block) them immediately; setting them back to `nil` lifts the block.

```swift
import ManagedSettings

let store = ManagedSettingsStore(named: .init("screenzen.block"))

func apply(_ sel: FamilyActivitySelection) {
  store.shield.applications = sel.applicationTokens.isEmpty ? nil : sel.applicationTokens
  store.shield.applicationCategories =
    sel.categoryTokens.isEmpty ? nil : .specific(sel.categoryTokens)
  store.shield.webDomains = sel.webDomainTokens.isEmpty ? nil : sel.webDomainTokens
}

func clear() { store.clearAllSettings() }
```

- iOS 16+ allows **up to 50 named stores per process**, auto-shared with the
  app's extensions — ScreenZen can keep a separate store per rule/schedule.
- **Where this runs matters:** the shield should be written from the
  **`DeviceActivityMonitor` extension**, not the app, so the block survives the
  app being closed or killed and fires on schedule/threshold events.

### 4.2 What the "overlay" actually is

When the user opens a shielded app, **the system draws the shield** over it —
ScreenZen is not drawing a window. This is the fundamental difference from the
Android overlay (`WindowManager` + `SYSTEM_ALERT_WINDOW`) in `app_blocking.md`.

### 4.3 Customizing the shield — needs **two** extensions

Customizing the shield's look and buttons requires two separate app extension
targets (a very common first-timer trap — one is not enough):

1. **Shield Configuration extension** — subclass `ShieldConfigurationDataSource`.
   Extension point id `com.apple.ManagedSettingsUI.shield-configuration-service`.
   Controls appearance only.

   ```swift
   import ManagedSettingsUI
   import ManagedSettings

   class ShieldConfigExtension: ShieldConfigurationDataSource {
     override func configuration(shielding app: Application) -> ShieldConfiguration {
       ShieldConfiguration(
         backgroundBlurStyle: .systemUltraThinMaterial,
         backgroundColor: UIColor(named: "brand"),
         icon: UIImage(named: "logo"),
         title: .init(text: "Take a breath", color: .label),
         subtitle: .init(text: "Do you really need this right now?", color: .secondaryLabel),
         primaryButtonLabel: .init(text: "Not now", color: .white),
         primaryButtonBackgroundColor: .systemIndigo,
         secondaryButtonLabel: .init(text: "Open anyway", color: .secondaryLabel))
     }
     // Also override the category and webDomain variants.
   }
   ```

2. **Shield Action extension** — subclass `ShieldActionDelegate`. Handles taps on
   the primary/secondary buttons.

   ```swift
   class ShieldActionExtension: ShieldActionDelegate {
     override func handle(action: ShieldAction, for app: ApplicationToken,
                          completionHandler: @escaping (ShieldActionResponse) -> Void) {
       switch action {
       case .primaryButtonPressed:   completionHandler(.close)   // dismiss to Home
       case .secondaryButtonPressed: completionHandler(.defer)   // redraw the shield
       @unknown default:             completionHandler(.none)
       }
     }
   }
   ```

**Hard constraints on the shield UI:**

- It runs **out-of-process** → **no SwiftUI, no app code**. Only system types:
  `UIImage`, `UIColor`, `AttributedString`, background blur/color, an icon, a
  title, a subtitle, and up to two buttons. No custom views, no live countdown,
  no animation. This is why the shield itself looks simple.
- The extension is handed **only a token**; it cannot tell *why* the token was
  shielded. Apps keep a **token → metadata lookup table** in a shared App Group
  and best-guess.

### 4.4 App Groups tie it together

The main app, the `DeviceActivityMonitor` extension, the Shield Configuration
extension, and the Shield Action extension **cannot pass data directly**. They
must all share **one App Group** (`UserDefaults(suiteName:)` / a shared file) to
exchange the selection tokens, the token→metadata map, and unlock state. Missing
the group on even one target silently breaks sharing on device.

To update the shield after a button tap, the Action extension writes new state to
the App Group and returns `.defer`, which makes the OS re-ask the Configuration
extension for a fresh `ShieldConfiguration`.

Sources: [An iOS Shield UI Needs Two Extensions, Not One](https://hsb.horse/en/blog/shield-extension-two-targets/),
[Update ShieldConfigurationExtension after action click (SO)](https://stackoverflow.com/questions/76775859/update-shieldconfigurationextension-after-action-click),
[SwiftUI: Screen Time API (iOS 17+)](https://soarias.com/swiftui/how-to-build-screen-time-api/).

---

## 5. The "delay / breathe / friction" experience

The shield alone can't show ScreenZen's animated breathing timer (no custom
views out-of-process). ScreenZen gets the rich interstitial two ways:

1. **Shield-only friction (hard block):** the shield's buttons drive behavior via
   `ShieldActionResponse` — `.close` (send to Home), `.defer` (redraw, e.g. show
   "still blocked"), or a temporary unlock: remove the token from the store for a
   few seconds/minutes, then re-apply it with a short `DeviceActivitySchedule` /
   timer. Increasing the wait on each open (a ScreenZen feature) is just growing
   that timer.

2. **Shortcuts "Open App" automation (the rich screen):** iOS Shortcuts can run
   an **automation when a chosen app is opened**. ScreenZen has the user create
   an automation "When [app] is opened → open ScreenZen" (this is why setup asks
   for **Shortcuts** permission, per the
   [Nibble write-up](https://nibble-app.com/blog/screenzen)). That launches the
   **ScreenZen app itself**, which *can* render a full SwiftUI breathing/countdown
   screen, log the open, and then either bounce the user back or let them through.
   The Screen Time shield is the hard enforcement; the Shortcut is the friendly
   friction UI.

This dual mechanism is the key reverse-engineering insight: **Screen Time shield
for the block that can't be bypassed, Shortcuts automation for the nice UX.**

---

## 6. Constraints & gotchas (verified)

- **Entitlement approval:** `com.apple.developer.family-controls` must be granted
  by Apple; expect a review/justification step before you can even build for
  device with it.
- **Real device only:** `FamilyActivityPicker` renders in the Simulator (iOS
  16+), but `ManagedSettingsStore` shields **do not actually block** there. Test
  restrictions on hardware.
- **No identities:** tokens are opaque; you can never display the real app names
  the user picked.
- **Out-of-process shield UI:** system types only, no SwiftUI, no animation.
- **Persistence:** write shields from the `DeviceActivityMonitor` extension so
  they survive app termination; keep all cross-target state in an App Group.
- **iOS versions:** core frameworks iOS 15; individual authorization, named
  stores, web-domain shielding, and `ManagedSettingsUI` shields are **iOS 16+**.

---

## 7. How this maps to Safini

Safini's model is **parent configures, child device enforces** (see
`app_blocking.md`). ScreenZen is self-control, but the machinery is the same:

| Safini need | ScreenZen / Screen Time equivalent |
|-------------|-----------------------------------|
| "Ask for screen time" on the child device | `AuthorizationCenter.requestAuthorization(for: .child)` (Family Sharing) or `.individual` if the child self-enrolls; needs the family-controls entitlement. |
| Parent picks which apps to control | `FamilyActivityPicker` on the **child** device (the parent can't pick remotely — Screen Time is on-device). We'd store the returned tokens on-device. |
| Block with an overlay | `ManagedSettingsStore.shield.*` + a branded shield via the two ManagedSettingsUI extensions. |
| Time limits / redemptions | `DeviceActivity` schedules + thresholds writing/clearing the shield from the monitor extension. |
| Show the child's real app list to the parent | **Not possible** — tokens have no names. iOS can only ever show "you picked N apps", not which. This is the wall from `child_get_apps.md` §6. |

**Minimum iOS target set** (separate epic, mirrors ScreenZen):

1. Main app: request authorization, present `FamilyActivityPicker`, persist the
   selection to a shared App Group.
2. `DeviceActivityMonitor` extension: apply/clear shields on schedule/threshold.
3. Shield **Configuration** extension: branded block screen.
4. Shield **Action** extension: button handling (Home / defer / temporary unlock).
5. One **App Group** shared by all four targets.
6. (Optional, for the friction UX) a Shortcuts "Open App" automation flow.

Divergence to accept up front: the Safini parent UI can show limits and usage
(backend numbers), but on iOS it **cannot** list or name the child's controlled
apps — only the on-device picker knows them.

---

## 8. Sources

- [ScreenZen on the App Store](https://apps.apple.com/us/app/screenzen-screen-time-control/id1541027222) — feature list (delays, cooldowns, breathing, strict block).
- [Nibble: How ScreenZen blocks apps, sites, scrolls](https://nibble-app.com/blog/screenzen) — needs "Screen Time and Shortcuts" on iPhone.
- [Apple WWDC22 — What's new in Screen Time API](https://developer.apple.com/videos/play/wwdc2022/110336/) — individual authorization, named stores.
- [A developer's guide to FamilyControls / ManagedSettings / DeviceActivity](https://medium.com/@juliusbrussee/a-developers-guide-to-apple-s-screen-time-apis-familycontrols-managedsettings-deviceactivity-e660147367d7).
- [An iOS Shield UI Needs Two Extensions, Not One](https://hsb.horse/en/blog/shield-extension-two-targets/) — Config + Action extensions, App Groups.
- [SwiftUI: Screen Time API (iOS 17+)](https://soarias.com/swiftui/how-to-build-screen-time-api/) — shield apply/clear, out-of-process limits, simulator caveats.
- [Update ShieldConfigurationExtension after action click (Stack Overflow)](https://stackoverflow.com/questions/76775859/update-shieldconfigurationextension-after-action-click) — `.defer` + App Group redraw pattern.
