import FamilyControls
import DeviceActivity
import SwiftUI
import ManagedSettings

@main
struct SafiniReportExtension: DeviceActivityReportExtension {
  var body: some DeviceActivityReportScene {
    UsageReport { UsageView(configuration: $0) }
  }
}

struct UsageConfiguration {
  struct App: Identifiable {
    let id = UUID()
    let token: ApplicationToken?
    let duration: TimeInterval
  }
  let total: TimeInterval
  let apps: [App]
}

struct UsageReport: DeviceActivityReportScene {
  let context = DeviceActivityReport.Context("safini.usage")
  let content: (UsageConfiguration) -> UsageView
  func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> UsageConfiguration {
    var total: TimeInterval = 0
    var totals: [ApplicationToken: TimeInterval] = [:]
    for await device in data {
      for await segment in device.activitySegments {
        total += segment.totalActivityDuration
        for await category in segment.categories {
          for await app in category.applications {
            if let token = app.application.token {
              totals[token, default: 0] += app.totalActivityDuration
            }
          }
        }
      }
    }
    // Rendering only. No App Group, UserDefaults, file writes or networking.
    return UsageConfiguration(total: total, apps: totals.map {
      .init(token: $0.key, duration: $0.value)
    }.sorted { $0.duration > $1.duration })
  }
}

struct UsageView: View {
  let configuration: UsageConfiguration
  private func duration(_ seconds: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: max(60, seconds)) ?? "0"
  }
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text(configuration.total == 0 ? "0 min" : duration(configuration.total))
          .font(.largeTitle.bold())
        ForEach(configuration.apps) { app in
          if let token = app.token {
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Label(token).labelStyle(.titleAndIcon)
                Spacer()
                Text(duration(app.duration)).monospacedDigit()
              }
              ProgressView(value: app.duration, total: max(configuration.total, app.duration))
                .tint(.purple)
            }
          }
        }
      }.padding()
    }
  }
}
