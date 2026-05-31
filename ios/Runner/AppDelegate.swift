import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

// MARK: - Shared store

// Written by MirraSceneDelegate (before engine starts), read by MirraSharePlugin (Flutter side).
enum ShareStore {
  static let pendingKey   = "mirra_pending_shared_image"
  static let tempFilename = "mirra_shared_image"

  @discardableResult
  static func save(url: URL) -> Bool {
    print("[Share] incoming URL: \(url) isFileURL=\(url.isFileURL) scheme=\(url.scheme ?? "nil")")
    guard url.isFileURL else { return false }
    let needsScope = url.startAccessingSecurityScopedResource()
    defer { if needsScope { url.stopAccessingSecurityScopedResource() } }
    guard let data = try? Data(contentsOf: url) else {
      print("[Share] ❌ could not read data")
      return false
    }
    let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
    let path = (NSTemporaryDirectory() as NSString)
      .appendingPathComponent("\(tempFilename).\(ext)")
    try? data.write(to: URL(fileURLWithPath: path))
    UserDefaults.standard.set(path, forKey: pendingKey)
    print("[Share] ✅ saved \(data.count) bytes → \(path)")
    return true
  }
}

// MARK: - Scene delegate
//
// Subclasses FlutterSceneDelegate to capture URLs before the Flutter engine
// initialises — fixes cold-launch "Open In MiRRA" from third-party apps.

@objc(MirraSceneDelegate)
@available(iOS 13.0, *)
class MirraSceneDelegate: FlutterSceneDelegate {

  // Cold launch: image URL is in connectionOptions, not a later callback.
  override func scene(_ scene: UIScene,
                      willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    print("[Share] willConnectToSession — urlContexts: \(connectionOptions.urlContexts.count)")
    for ctx in connectionOptions.urlContexts {
      if ShareStore.save(url: ctx.url) { break }
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  // Warm launch: app in background, user picks "Open In MiRRA".
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    print("[Share] openURLContexts — count: \(URLContexts.count)")
    for ctx in URLContexts {
      if ShareStore.save(url: ctx.url) {
        MirraSharePlugin.channel?.invokeMethod("sharedImage", arguments: nil)
        break
      }
    }
    super.scene(scene, openURLContexts: URLContexts)
  }
}

// MARK: - Share plugin

class MirraSharePlugin: NSObject, FlutterPlugin {

  static var channel: FlutterMethodChannel?

  static func register(with registrar: FlutterPluginRegistrar) {
    let ch = FlutterMethodChannel(name: "mirra/share",
                                  binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(MirraSharePlugin(), channel: ch)
    MirraSharePlugin.channel = ch
    print("[Share] plugin channel ready")
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPendingSharedImage":
      getPendingSharedImage(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getPendingSharedImage(result: @escaping FlutterResult) {
    guard let path = UserDefaults.standard.string(forKey: ShareStore.pendingKey) else {
      result(nil)
      return
    }
    defer {
      UserDefaults.standard.removeObject(forKey: ShareStore.pendingKey)
      try? FileManager.default.removeItem(atPath: path)
    }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
      result(nil)
      return
    }
    print("[Share] returning \(data.count) bytes to Flutter")
    result(FlutterStandardTypedData(bytes: data))
  }
}

// MARK: - AppDelegate

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([])
  }

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("[FCM] Token: \(fcmToken ?? "nil")")
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MirraSharePlugin") {
      MirraSharePlugin.register(with: registrar)
    }
  }

  override func application(_ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("[APNs] ✅ Device token: \(token)")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("[APNs] ❌ Failed to register: \(error)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
