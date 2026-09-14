import Foundation

struct ScreenTimePolicy: Codable, Equatable {
  struct Rule: Codable, Equatable {
    let app_slug: String
    let display_name: String
    let is_blocked: Bool
    let is_limited: Bool
    let daily_limit_minutes: Int
    let bonus_minutes: Int
  }
  let child_id: String
  let family_timezone: String
  let global_limit_minutes: Int?
  let bonus_expires_at: String
  let apps: [Rule]

  var timeZone: TimeZone { TimeZone(identifier: family_timezone) ?? .gmt }
  func bonusIsCurrent(at now: Date) -> Bool {
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: bonus_expires_at) { return date > now }
    formatter.formatOptions.insert(.withFractionalSeconds)
    return (formatter.date(from: bonus_expires_at) ?? .distantPast) > now
  }
  func allowance(_ rule: Rule, at now: Date) -> Int? {
    guard rule.is_limited else { return nil }
    return min(1440, rule.daily_limit_minutes + (bonusIsCurrent(at: now) ? rule.bonus_minutes : 0))
  }
}

