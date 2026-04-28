import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

// MARK: - Share Plugin
// Handles images shared to MiRRA via the iOS share sheet ("Open In MiRRA").
// Registers as an application delegate so it receives application(_:open:options:)
// via the FlutterAppDelegate → FlutterSceneDelegate plugin bridge.
private class MirraSharePlugin: NSObject, FlutterPlugin {

  static var channel: FlutterMethodChannel?
  private static let pendingKey = "mirra_pending_shared_image"
  private static let tempFilename = "mirra_shared_image"

  static func register(with registrar: FlutterPluginRegistrar) {
    let ch = FlutterMethodChannel(name: "mirra/share",
                                  binaryMessenger: registrar.messenger())
    let instance = MirraSharePlugin()
    registrar.addMethodCallDelegate(instance, channel: ch)
    registrar.addApplicationDelegate(instance)
    MirraSharePlugin.channel = ch
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPendingSharedImage":
      getPendingSharedImage(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Called by FlutterAppDelegate when the app is opened with a URL.
  // FlutterSceneDelegate also delegates scene-based URL opens here.
  func application(_ application: UIApplication, open url: URL,
                   options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    guard url.isFileURL else { return false }
    saveSharedImage(from: url)
    // Notify Flutter (may be nil if engine isn't ready yet; Flutter checks on resume)
    MirraSharePlugin.channel?.invokeMethod("sharedImage", arguments: nil)
    return true
  }

  // MARK: - Private helpers

  private func saveSharedImage(from url: URL) {
    guard let data = try? Data(contentsOf: url) else { return }
    let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
    let tempPath = (NSTemporaryDirectory() as NSString)
      .appendingPathComponent("\(MirraSharePlugin.tempFilename).\(ext)")
    try? data.write(to: URL(fileURLWithPath: tempPath))
    UserDefaults.standard.set(tempPath, forKey: MirraSharePlugin.pendingKey)
  }

  private func getPendingSharedImage(result: @escaping FlutterResult) {
    guard let path = UserDefaults.standard.string(forKey: MirraSharePlugin.pendingKey) else {
      result(nil)
      return
    }
    defer {
      UserDefaults.standard.removeObject(forKey: MirraSharePlugin.pendingKey)
      try? FileManager.default.removeItem(atPath: path)
    }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
      result(nil)
      return
    }
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

  // Show notifications when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([[.banner, .sound, .badge]])
  }

  // FCM token received via delegate
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
