import DeviceActivity
import SwiftUI

struct ScreenTimeReportHost: View {
  let title: String
  let privacy: String
  let today: String
  let week: String
  let done: String
  let dismiss: () -> Void
  @State private var days = 1
  var body: some View {
    NavigationStack {
      VStack {
        Text(privacy).font(.footnote).foregroundStyle(.secondary).padding(.horizontal)
        Picker(title, selection: $days) {
          Text(today).tag(1)
          Text(week).tag(7)
        }.pickerStyle(.segmented).padding()
        DeviceActivityReport(.init("safini.usage"), filter: .init(
          segment: .daily(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: 1 - days, to: Calendar.current.startOfDay(for: Date()))!,
            end: Date()))))
          .id(days)
      }
      .navigationTitle(title)
      .toolbar { ToolbarItem(placement: .confirmationAction) { Button(done, action: dismiss) } }
    }
  }
}
