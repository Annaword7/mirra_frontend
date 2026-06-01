import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

// MARK: - Shared store

// Written by MirraSceneDelegate or ShareExtension, read by MirraSharePlugin (Flutter side).
// Uses App Group container so ShareExtension (separate process) can pass data to the main app.
enum ShareStore {
  static let appGroup     = "group.mirra.app"
  static let pendingKey   = "mirra_pending_shared_image"
  static let tempFilename = "mirra_shared_image"

  /// Shared UserDefaults accessible by both main app and ShareExtension.
  static var defaults: UserDefaults { UserDefaults(suiteName: appGroup) ?? .standard }

  /// Shared file container directory (App Group).
  static var containerURL: URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
  }

  // MARK: File URL (Photos app, Files app — "Open In" path)

  @discardableResult
  static func saveFile(url: URL) -> Bool {
    print("[Share] incoming URL: \(url) isFileURL=\(url.isFileURL) scheme=\(url.scheme ?? "nil")")
    guard url.isFileURL else { return false }
    let needsScope = url.startAccessingSecurityScopedResource()
    defer { if needsScope { url.stopAccessingSecurityScopedResource() } }
    guard let data = try? Data(contentsOf: url) else {
      print("[Share] ❌ could not read file data")
      return false
    }
    return persist(data: data, ext: url.pathExtension)
  }

  // MARK: Private

  @discardableResult
  static func persist(data: Data, ext: String) -> Bool {
    let fileExt = ext.isEmpty ? "jpg" : ext
    // Prefer App Group container; fall back to tmp if not configured yet.
    let fileURL: URL
    if let base = containerURL {
      fileURL = base.appendingPathComponent("\(tempFilename).\(fileExt)")
    } else {
      fileURL = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString)
        .appendingPathComponent("\(tempFilename).\(fileExt)"))
    }
    do {
      try data.write(to: fileURL)
      defaults.set(fileURL.path, forKey: pendingKey)
      print("[Share] ✅ saved \(data.count) bytes → \(fileURL.path)")
      return true
    } catch {
      print("[Share] ❌ write failed: \(error)")
      return false
    }
  }
}

// MARK: - Scene delegate
//
// Subclasses FlutterSceneDelegate to capture URLs before the Flutter engine
// initialises — fixes cold-launch timing and handles both file:// and https:// images.

@objc(MirraSceneDelegate)
@available(iOS 13.0, *)
class MirraSceneDelegate: FlutterSceneDelegate {

  // Cold launch: URL arrives in connectionOptions before engine is ready.
  override func scene(_ scene: UIScene,
                      willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    print("[Share] willConnectToSession — urlContexts: \(connectionOptions.urlContexts.count)")
    for ctx in connectionOptions.urlContexts {
      if ShareStore.saveFile(url: ctx.url) { break }
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }


  // Clear app icon badge whenever the app becomes active.
  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  // Warm launch: app in background, opened by "Open In MiRRA" document handler (file:// URL).
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    print("[Share] openURLContexts — count: \(URLContexts.count)")
    for ctx in URLContexts {
      let url = ctx.url
      // ShareExtension already saved the image to App Group — just notify Flutter.
      if url.scheme == "mirradev" && url.host == "share" {
        print("[Share] opened by ShareExtension")
        MirraSharePlugin.channel?.invokeMethod("sharedImage", arguments: nil)
        break
      }
      // "Open In" direct file URL (Photos app, Files app).
      if ShareStore.saveFile(url: url) {
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
    guard let path = ShareStore.defaults.string(forKey: ShareStore.pendingKey) else {
      result(nil); return
    }
    defer {
      ShareStore.defaults.removeObject(forKey: ShareStore.pendingKey)
      try? FileManager.default.removeItem(atPath: path)
    }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
      result(nil); return
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

  // App fully active — safe moment for Flutter to navigate.
  // Fires after sceneWillEnterForeground, when GoRouter is ready to handle pushes.
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    if ShareStore.defaults.string(forKey: ShareStore.pendingKey) != nil {
      print("[Share] pending image found, app active → notifying Flutter")
      MirraSharePlugin.channel?.invokeMethod("sharedImage", arguments: nil)
    }
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
