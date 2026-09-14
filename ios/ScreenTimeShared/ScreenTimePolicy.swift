import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Configuration and threshold state only. DeviceActivityReport data never
/// enters this App Group or the Flutter/backend bridge.

final class ScreenTimeStore {
  static let group = "group.com.safini.app"
  static let activity = DeviceActivityName("safini.daily")
  static let managed = ManagedSettingsStore(named: .init("safini.rules"))
  let defaults: UserDefaults
  init() { defaults = UserDefaults(suiteName: Self.group)! }

  var policy: ScreenTimePolicy? {
    get { defaults.data(forKey: "policy").flatMap { try? JSONDecoder().decode(ScreenTimePolicy.self, from: $0) } }
    set { defaults.set(try? JSONEncoder().encode(newValue), forKey: "policy") }
  }
  var selections: [String: FamilyActivitySelection] {
    get { defaults.data(forKey: "selections").flatMap { try? JSONDecoder().decode([String: FamilyActivitySelection].self, from: $0) } ?? [:] }
    set { defaults.set(try? JSONEncoder().encode(newValue), forKey: "selections") }
  }
  var allApplications: Set<ApplicationToken> {
    guard let policy else { return [] }
    let mapped = selections
    return policy.apps.reduce(into: []) { $0.formUnion(mapped[$1.app_slug]?.applicationTokens ?? []) }
  }
  private func dayKey(_ date: Date) -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = policy?.timeZone ?? .gmt
    let d = calendar.dateComponents([.year, .month, .day], from: date)
    return "\(d.year!)-\(d.month!)-\(d.day!)"
  }
  // Each event gets a separate preference key to avoid read/modify/write races
  // between the extension and the foreground app. Never synced to the server.
  func reached(_ scope: String, minutes: Int, at date: Date = Date()) -> Bool {
    let values = defaults.dictionary(forKey: "threshold.\(dayKey(date)).\(scope)") ?? [:]
    return values.keys.compactMap(Int.init).contains { $0 >= minutes }
  }
  func record(_ event: DeviceActivityEvent.Name) {
    guard let decoded = Self.decodeEvent(event) else { return }
    let key = "threshold.\(dayKey(Date())).\(decoded.0)"
    var values = defaults.dictionary(forKey: key) ?? [:]
    values[String(decoded.1)] = true
    defaults.set(values, forKey: key)
    refreshShields()
  }
  static func event(_ scope: String, minutes: Int) -> DeviceActivityEvent.Name {
    .init("\(Data(scope.utf8).base64EncodedString())|\(minutes)")
  }
  static func decodeEvent(_ event: DeviceActivityEvent.Name) -> (String, Int)? {
    let parts = event.rawValue.split(separator: "|")
    guard parts.count == 2, let data = Data(base64Encoded: String(parts[0])),
          let scope = String(data: data, encoding: .utf8), let minutes = Int(parts[1]) else { return nil }
    return (scope, minutes)
  }
  func refreshShields(at now: Date = Date()) {
    guard let policy else { return }
    let mapped = selections
    let globalBlocked = policy.global_limit_minutes.map { $0 == 0 || reached("@global", minutes: $0, at: now) } ?? false
    var blocked = Set<ApplicationToken>()
    for rule in policy.apps {
      let exhausted = policy.allowance(rule, at: now).map { $0 == 0 || reached(rule.app_slug, minutes: $0, at: now) } ?? false
      if globalBlocked || rule.is_blocked || exhausted {
        blocked.formUnion(mapped[rule.app_slug]?.applicationTokens ?? [])
      }
    }
    Self.managed.shield.applications = blocked.isEmpty ? nil : blocked
    Self.managed.shield.applicationCategories = nil
    defaults.set(!blocked.isEmpty, forKey: "shieldActive")
  }
  func installMonitoring() throws {
    guard let policy else { return }
    let mapped = selections
    var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
    func add(_ scope: String, _ minutes: Int, _ tokens: Set<ApplicationToken>) {
      guard minutes > 0, minutes < 1440, !tokens.isEmpty else { return }
      events[Self.event(scope, minutes: minutes)] = DeviceActivityEvent(
        applications: tokens, threshold: DateComponents(minute: minutes), includesPastActivity: true)
    }
    for rule in policy.apps where rule.is_limited {
      let tokens = mapped[rule.app_slug]?.applicationTokens ?? []
      // Keep the base event as well: tomorrow it takes over when bonuses expire,
      // even if Safini hasn't been opened and the policy is still cached.
      add(rule.app_slug, rule.daily_limit_minutes, tokens)
      if let total = policy.allowance(rule, at: Date()) { add(rule.app_slug, total, tokens) }
    }
    if let limit = policy.global_limit_minutes { add("@global", limit, allApplications) }
    var start = DateComponents(hour: 0, minute: 0, second: 0)
    var end = DateComponents(hour: 23, minute: 59, second: 59)
    start.timeZone = policy.timeZone
    end.timeZone = policy.timeZone
    try DeviceActivityCenter().startMonitoring(Self.activity,
      during: DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: true), events: events)
    refreshShields()
  }
  func resetAfterRevocation() {
    DeviceActivityCenter().stopMonitoring([Self.activity])
    Self.managed.clearAllSettings()
    defaults.removePersistentDomain(forName: Self.group)
  }
}
