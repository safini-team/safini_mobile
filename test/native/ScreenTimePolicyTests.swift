import Foundation
import XCTest
@testable import SafiniScreenTimePolicy

final class ScreenTimePolicyTests: XCTestCase {
  func policy(base: Int = 30, bonus: Int = 15, limited: Bool = true) -> ScreenTimePolicy {
    ScreenTimePolicy(child_id: "child", family_timezone: "Asia/Bishkek", global_limit_minutes: 90,
      bonus_expires_at: "2026-09-14T18:00:00+00:00", apps: [
        .init(app_slug: "roblox", display_name: "Roblox", is_blocked: false,
              is_limited: limited, daily_limit_minutes: base, bonus_minutes: bonus)
      ])
  }
  func testEarnedMinutesExpireAtFamilyMidnightWithoutNetwork() {
    let p = policy()
    let midnight = ISO8601DateFormatter().date(from: p.bonus_expires_at)!
    XCTAssertEqual(p.allowance(p.apps[0], at: midnight.addingTimeInterval(-1)), 45)
    XCTAssertEqual(p.allowance(p.apps[0], at: midnight), 30)
    XCTAssertEqual(p.allowance(p.apps[0], at: midnight.addingTimeInterval(86400)), 30)
  }
  func testZeroLimitRequiresEarnedTime() {
    let p = policy(base: 0)
    let midnight = ISO8601DateFormatter().date(from: p.bonus_expires_at)!
    XCTAssertEqual(p.allowance(p.apps[0], at: midnight.addingTimeInterval(-1)), 15)
    XCTAssertEqual(p.allowance(p.apps[0], at: midnight), 0)
  }
  func testUncappedAppDoesNotBecomeCappedByBonusExpiry() {
    let p = policy(limited: false)
    XCTAssertNil(p.allowance(p.apps[0], at: Date()))
  }
  func testMalformedExpiryDoesNotGrantExtraTime() {
    let p = ScreenTimePolicy(child_id: "child", family_timezone: "UTC", global_limit_minutes: nil,
      bonus_expires_at: "invalid", apps: policy().apps)
    XCTAssertEqual(p.allowance(p.apps[0], at: Date()), 30)
  }
}

