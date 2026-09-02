import FamilyControls
import ManagedSettings
import SwiftUI
import UIKit

/// Native entry point for the iOS Screen Time / FamilyControls blocking path.
///
/// This is the iOS counterpart to the Android `AppBlockForegroundService`, but
/// the mechanism is fundamentally different (see `observation/screenzen_research.md`):
///  - We never enumerate or name apps. The user picks them in Apple's own
///    `FamilyActivityPicker`, which hands back **opaque tokens**.
///  - Blocking is Apple's **system shield**, applied by writing those tokens to a
///    `ManagedSettingsStore`. The OS draws the overlay; we don't.
///
/// Everything here links and compiles without the FamilyControls entitlement, but
/// `requestAuthorization` fails at runtime until an approved provisioning profile
/// carries `com.apple.developer.family-controls`. That failure is reported back to
/// Dart as a `PlatformException`, not a crash.
///
/// Scope of this first increment (main app target only):
///  - authorization + status
///  - present the picker, persist the selection
///  - apply / clear the shield immediately ("block now" / "unblock now")
///
/// Deferred to a follow-up (needs separate Xcode app-extension targets + App Group):
///  - `DeviceActivityMonitor` for time-of-day / usage-threshold scheduling
///  - `ShieldConfiguration` / `ShieldAction` extensions to brand the overlay
final class ScreenTimeManager {
  static let shared = ScreenTimeManager()

  private let store = ManagedSettingsStore()
  private let selectionKey = "safini.screenTime.selection"
  private var selection = FamilyActivitySelection()

  private init() {
    restoreSelection()
  }

  // MARK: - Authorization

  /// Current authorization state as a stable string for the Dart bridge.
  func authorizationStatus() -> String {
    switch AuthorizationCenter.shared.authorizationStatus {
    case .notDetermined: return "notDetermined"
    case .denied: return "denied"
    case .approved: return "approved"
    @unknown default: return "unknown"
    }
  }

  /// Requests Screen Time authorization.
  ///
  /// - `member`: `"individual"` (self-control, no Family Sharing needed — best for
  ///   dev testing) or `"child"` (parent-managed device enrolled in Family Sharing).
  ///
  /// Must run on the main actor: the Screen Time helper rejects off-main calls
  /// with "Couldn't communicate with a helper application".
  func requestAuthorization(
    member: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let target: FamilyControlsMember = (member == "child") ? .child : .individual
    Task { @MainActor in
      do {
        try await AuthorizationCenter.shared.requestAuthorization(for: target)
        completion(.success(self.authorizationStatus()))
      } catch {
        completion(.failure(error))
      }
    }
  }

  // MARK: - App selection

  /// Presents Apple's `FamilyActivityPicker` on top of the current view
  /// controller. Completion returns the resulting token counts. The selection is
  /// persisted so a later `applyShield()` (or a re-open of the picker) reuses it.
  func presentPicker(completion: @escaping (Result<[String: Int], Error>) -> Void) {
    guard let presenter = Self.topViewController() else {
      completion(.failure(ScreenTimeError.noPresenter))
      return
    }

    var hostingRef: UIViewController?
    let container = FamilyPickerContainer(selection: selection) { [weak self] newSelection in
      guard let self else { return }
      self.selection = newSelection
      self.persistSelection()
      hostingRef?.dismiss(animated: true)
      completion(.success(self.selectionCounts()))
    }

    let hosting = UIHostingController(rootView: container)
    hosting.modalPresentationStyle = .overFullScreen
    hosting.view.backgroundColor = .clear
    hostingRef = hosting
    presenter.present(hosting, animated: false)
  }

  /// Token counts of the current selection (`applications`, `categories`).
  func selectionCounts() -> [String: Int] {
    [
      "applications": selection.applicationTokens.count,
      "categories": selection.categoryTokens.count,
    ]
  }

  // MARK: - Shield

  /// Applies the shield to the current selection. Returns `false` if nothing is
  /// selected (nothing to block).
  @discardableResult
  func applyShield() -> Bool {
    let apps = selection.applicationTokens
    let categories = selection.categoryTokens
    if apps.isEmpty && categories.isEmpty { return false }
    store.shield.applications = apps.isEmpty ? nil : apps
    store.shield.applicationCategories =
      categories.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(categories)
    return true
  }

  /// Lifts the shield from every previously blocked app/category.
  func clearShield() {
    store.shield.applications = nil
    store.shield.applicationCategories = nil
  }

  // MARK: - Persistence

  private func persistSelection() {
    if let data = try? JSONEncoder().encode(selection) {
      UserDefaults.standard.set(data, forKey: selectionKey)
    }
  }

  private func restoreSelection() {
    guard
      let data = UserDefaults.standard.data(forKey: selectionKey),
      let restored = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    else { return }
    selection = restored
  }

  // MARK: - Helpers

  private static func topViewController() -> UIViewController? {
    let scene = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive }
    let root = scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
    var top = root
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}

enum ScreenTimeError: Error, LocalizedError {
  case noPresenter

  var errorDescription: String? {
    switch self {
    case .noPresenter: return "No view controller available to present the picker."
    }
  }
}

/// Invisible SwiftUI host whose only job is to drive `familyActivityPicker`.
private struct FamilyPickerContainer: View {
  @State private var isPresented = true
  @State var selection: FamilyActivitySelection
  let onDismiss: (FamilyActivitySelection) -> Void

  var body: some View {
    Color.clear
      .familyActivityPicker(isPresented: $isPresented, selection: $selection)
      .onChange(of: isPresented) { _, presented in
        if !presented { onDismiss(selection) }
      }
  }
}
