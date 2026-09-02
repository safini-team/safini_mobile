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
            let ns = error as NSError
            result(
              FlutterError(
                code: Self.familyControlsCode(ns),
                message: Self.familyControlsMessage(ns),
                details: ["domain": ns.domain, "code": ns.code]
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

  /// FamilyControlsError.Code raw values as reported on NSError.
  private static func familyControlsCode(_ error: NSError) -> String {
    switch error.code {
    case 0: return "invalid_account"
    case 1: return "restricted"
    case 2: return "unavailable"
    case 3: return "invalid_argument"
    case 4: return "canceled"
    case 5: return "network"
    case 6: return "auth_failed"
    default: return "authorization_failed"
    }
  }

  private static func familyControlsMessage(_ error: NSError) -> String {
    switch error.code {
    case 0:
      return "This Apple ID cannot use Individual Screen Time auth. Use a personal Apple ID, or Family Sharing with .child."
    case 1:
      return "Screen Time is restricted on this device (MDM or parent controls)."
    case 2:
      return "Couldn't talk to the Screen Time helper. Rebuild so Family Controls is in the signed app, turn Screen Time on in Settings, delete Safini from the phone, then reinstall."
    case 4:
      return "Authorization was canceled."
    default:
      return error.localizedDescription
    }
  }
}
