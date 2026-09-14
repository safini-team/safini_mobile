import DeviceActivity

final class ScreenTimeMonitor: DeviceActivityMonitor {
  override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
    guard activity == ScreenTimeStore.activity else { return }
    // Date-scoped thresholds reset naturally; manual blocks and zero limits
    // continue, while yesterday's earned minutes no longer extend the cap.
    ScreenTimeStore().refreshShields()
  }
  override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventDidReachThreshold(event, activity: activity)
    guard activity == ScreenTimeStore.activity else { return }
    ScreenTimeStore().record(event)
  }
}
