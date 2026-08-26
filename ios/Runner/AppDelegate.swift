import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let screenTimeChannelName = "com.safini.app/screen_time"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SafiniScreenTime") {
      setUpScreenTimeChannel(messenger: registrar.messenger())
    }
  }

  /// Bridges Dart's `ScreenTimeService` to the native `ScreenTimeManager`.
  private func setUpScreenTimeChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: Self.screenTimeChannelName,
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      let manager = ScreenTimeManager.shared
      switch call.method {
      case "authorizationStatus":
        result(manager.authorizationStatus())

      case "requestAuthorization":
        let member =
          (call.arguments as? [String: Any])?["member"] as? String ?? "individual"
        manager.requestAuthorization(member: member) { outcome in
          switch outcome {
          case .success(let status):
            result(status)
          case .failure(let error):
            result(
              FlutterError(
                code: "authorization_failed",
                message: error.localizedDescription,
                details: nil
              )
            )
          }
        }

      case "presentPicker":
        manager.presentPicker { outcome in
          switch outcome {
          case .success(let counts):
            result(counts)
          case .failure(let error):
            result(
              FlutterError(
                code: "picker_failed",
                message: error.localizedDescription,
                details: nil
              )
            )
          }
        }

      case "applyShield":
        result(manager.applyShield())

      case "clearShield":
        manager.clearShield()
        result(nil)

      case "selectionCounts":
        result(manager.selectionCounts())

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
