import FamilyControls
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
      case "configurePolicy":
        do {
          let data = try JSONSerialization.data(withJSONObject: call.arguments ?? [:])
          try manager.configurePolicy(data)
          result(manager.releaseStatus())
        } catch { result(FlutterError(code: "policy_failed", message: error.localizedDescription, details: nil)) }
      case "releaseStatus":
        result(manager.releaseStatus())
      case "selectRule":
        let slug = (call.arguments as? [String: Any])?["slug"] as? String ?? ""
        manager.selectRule(slug) { outcome in
          switch outcome {
          case .success: result(manager.releaseStatus())
          case .failure(let error): result(FlutterError(code: "selection_failed", message: error.localizedDescription, details: nil))
          }
        }
      case "showReport":
        do { try manager.showReport(call.arguments as? [String: String] ?? [:]); result(nil) }
        catch { result(FlutterError(code: "report_failed", message: error.localizedDescription, details: nil)) }
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
                code: Self.familyControlsCode(error),
                message: error.localizedDescription,
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

  /// A stable code for the Dart bridge, matched on the `FamilyControlsError`
  /// case itself.
  ///
  /// Do not read `NSError.code` against a hand-written table. Those raw values
  /// are only the declaration order of `FamilyControlsError`, which is
  /// `restricted, unavailable, invalidAccountType, invalidArgument,
  /// authorizationConflict, authorizationCanceled, networkError, ...`. The old
  /// table began at `invalidAccountType`, so every error was reported one case
  /// off: App Review hit `invalidAccountType` on 2026-09-15 and was shown the
  /// "rebuild with Family Controls in the signed app" text meant for
  /// `unavailable`.
  ///
  /// The message stays Apple's own `errorDescription`; Dart localizes off the
  /// code and only falls back to this text for an unrecognized one.
  private static func familyControlsCode(_ error: Error) -> String {
    guard let error = error as? FamilyControlsError else {
      return "authorization_failed"
    }
    switch error {
    case .restricted: return "restricted"
    case .unavailable: return "unavailable"
    case .invalidAccountType: return "invalid_account"
    case .invalidArgument: return "invalid_argument"
    case .authorizationConflict: return "authorization_conflict"
    case .authorizationCanceled: return "canceled"
    case .networkError: return "network"
    default: return "authorization_failed"
    }
  }
}
