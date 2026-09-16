import DeviceActivity
import FamilyControls
import ManagedSettings
import SwiftUI
import UIKit

/// Native authorization, rule linking, and private report presentation.
/// Release policy is stored in the App Group and enforced by ScreenTimeMonitor.
/// Apple tokens and report data never cross the network bridge.
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
    let status = AuthorizationCenter.shared.authorizationStatus
    switch status {
    case .notDetermined: return "notDetermined"
    case .denied: return "denied"
    case .approved: return "approved"
    default:
      // iOS 26.4 added `.approvedWithDataAccess`, a strictly wider grant than
      // `.approved`. Reporting it as "unavailable" left `authorized` false in
      // Dart, so the setup gate could never become ready on a 26.4 device.
      // Compare raw values rather than naming the case, which needs iOS 26.4.
      return status.rawValue >= AuthorizationStatus.approved.rawValue
        ? "approved" : "unavailable"
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
    if authorizationStatus() != "approved" {
      let shared = ScreenTimeStore()
      let policy = shared.policy
      shared.resetAfterRevocation()
      shared.policy = policy
    }
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


extension ScreenTimeManager {
  func configurePolicy(_ data: Data) throws {
    let incoming = try JSONDecoder().decode(ScreenTimePolicy.self, from: data)
    guard incoming.apps.count <= 50,
          Set(incoming.apps.map(\.app_slug)).count == incoming.apps.count,
          incoming.apps.allSatisfy({ !$0.app_slug.isEmpty && $0.daily_limit_minutes >= 0 && $0.bonus_minutes >= 0 }),
          incoming.global_limit_minutes.map({ $0 >= 0 && $0 <= 1440 }) ?? true,
          TimeZone(identifier: incoming.family_timezone) != nil else {
      throw NSError(domain: "Safini", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid Screen Time policy."])
    }
    let shared = ScreenTimeStore()
    let authorized = authorizationStatus() == "approved"
    if let previous = shared.policy, previous.child_id != incoming.child_id {
      guard !authorized else {
        throw NSError(domain: "Safini", code: 2, userInfo: [NSLocalizedDescriptionKey: "Ask your parent to revoke Safini's Screen Time access in Settings before changing the child account on this device."])
      }
      shared.resetAfterRevocation()
    }
    let previous = shared.policy
    shared.policy = incoming
    guard authorized else { return }
    if shared.allApplications.isEmpty {
      DeviceActivityCenter().stopMonitoring([ScreenTimeStore.activity])
      ScreenTimeStore.managed.clearAllSettings()
      shared.defaults.set(false, forKey: "shieldActive")
      return
    }
    if previous != incoming || !DeviceActivityCenter().activities.contains(ScreenTimeStore.activity) {
      do { try shared.installMonitoring() }
      catch { shared.policy = previous; throw error }
    } else { shared.refreshShields() }
  }

  func releaseStatus() -> [String: Any] {
    let shared = ScreenTimeStore()
    let authorized = authorizationStatus() == "approved"
    let mapped = shared.selections
    let slugs = shared.policy?.apps.compactMap { mapped[$0.app_slug]?.applicationTokens.isEmpty == false ? $0.app_slug : nil } ?? []
    if authorized { shared.refreshShields() }
    return [
      "child_id": shared.policy?.child_id ?? "",
      "policy_loaded": shared.policy != nil,
      "all_mapped": shared.policy.map { $0.apps.allSatisfy { mapped[$0.app_slug]?.applicationTokens.isEmpty == false } } ?? false,
      "authorization": authorizationStatus(),
      "selected_applications": shared.allApplications.count,
      "selected_categories": 0,
      "shield_active": authorized && shared.defaults.bool(forKey: "shieldActive"),
      "monitoring_active": authorized && DeviceActivityCenter().activities.contains(ScreenTimeStore.activity),
      "global_blocked": shared.policy?.global_limit_minutes.map { $0 == 0 || shared.reached("@global", minutes: $0) } ?? false,
      "mapped_slugs": slugs,
    ]
  }

  func selectRule(_ slug: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let shared = ScreenTimeStore()
    guard authorizationStatus() == "approved", shared.policy?.apps.contains(where: { $0.app_slug == slug }) == true,
          shared.selections[slug] == nil, let presenter = Self.topViewController() else {
      completion(.failure(NSError(domain: "Safini", code: 3, userInfo: [NSLocalizedDescriptionKey: "Authorize Screen Time and select an unlinked app. To change a saved selection, ask your parent to revoke access in Settings first."])))
      return
    }
    var hosting: UIViewController?
    let picker = FamilyPickerContainer(selection: FamilyActivitySelection()) { selection in
      hosting?.dismiss(animated: true)
      hosting = nil
      let alreadySelected = Set(shared.selections.values.flatMap { $0.applicationTokens })
      guard selection.applicationTokens.count == 1, selection.categoryTokens.isEmpty,
            selection.webDomainTokens.isEmpty,
            selection.applicationTokens.isDisjoint(with: alreadySelected) else {
        completion(.failure(NSError(domain: "Safini", code: 4, userInfo: [NSLocalizedDescriptionKey: "Choose exactly one app that has not already been linked. Do not select a whole category or website."])))
        return
      }
      let old = shared.selections
      var updated = old
      updated[slug] = selection
      shared.selections = updated
      do { try shared.installMonitoring(); completion(.success(())) }
      catch { shared.selections = old; completion(.failure(error)) }
    }
    hosting = UIHostingController(rootView: picker)
    presenter.present(hosting!, animated: true)
  }

  func showReport(_ labels: [String: String]) throws {
    guard authorizationStatus() == "approved", let presenter = Self.topViewController() else {
      throw NSError(domain: "Safini", code: 5, userInfo: [NSLocalizedDescriptionKey: "Authorize Screen Time before viewing activity."])
    }
    var host: UIViewController?
    host = UIHostingController(rootView: ScreenTimeReportHost(
      title: labels["title"] ?? "Screen Time", privacy: labels["privacy"] ?? "",
      today: labels["today"] ?? "Today", week: labels["week"] ?? "7 days", done: labels["done"] ?? "Done",
      dismiss: { host?.dismiss(animated: true); host = nil }))
    presenter.present(host!, animated: true)
  }
}
