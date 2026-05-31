import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

// MARK: - Shared store

// Written by MirraSceneDelegate (before engine starts), read by MirraSharePlugin (Flutter side).
enum ShareStore {
  static let pendingKey    = "mirra_pending_shared_image"
  static let pendingUrlKey = "mirra_pending_shared_url"   // web image URL for Flutter to download
  static let tempFilename  = "mirra_shared_image"

  private static let imageExtensions: Set<String> = [
    "jpg", "jpeg", "png", "gif", "webp", "heic", "heif", "bmp", "tiff", "tif"
  ]

  // MARK: File URL (Photos app, Files app, downloaded files)

  /// Reads a file URL, copies data to tmp, stores path. Returns true if handled.
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

  // MARK: Web URL (Safari web images)

  static func isWebImageURL(_ url: URL) -> Bool {
    guard let scheme = url.scheme,
          scheme == "http" || scheme == "https" else { return false }
    let ext = url.pathExtension.lowercased()
    return imageExtensions.contains(ext)
  }

  /// Stores the web URL for Flutter to download (cold launch path).
  static func saveWebURL(_ url: URL) {
    UserDefaults.standard.set(url.absoluteString, forKey: pendingUrlKey)
    print("[Share] ✅ stored web URL for Flutter: \(url)")
  }

  /// Downloads web image asynchronously, persists to tmp, calls completion on main. (warm launch path)
  static func downloadAndPersist(url: URL, completion: @escaping () -> Void) {
    print("[Share] ⬇️ downloading: \(url)")
    URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data, error == nil else {
        print("[Share] ❌ download failed: \(error?.localizedDescription ?? "unknown")")
        return
      }
      if persist(data: data, ext: url.pathExtension) {
        print("[Share] ✅ downloaded \(data.count) bytes")
        DispatchQueue.main.async { completion() }
      }
    }.resume()
  }

  // MARK: Private

  @discardableResult
  private static func persist(data: Data, ext: String) -> Bool {
    let fileExt = ext.isEmpty ? "jpg" : ext
    let path = (NSTemporaryDirectory() as NSString)
      .appendingPathComponent("\(tempFilename).\(fileExt)")
    do {
      try data.write(to: URL(fileURLWithPath: path))
      UserDefaults.standard.set(path, forKey: pendingKey)
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
      let url = ctx.url
      if ShareStore.saveFile(url: url) { break }
      if ShareStore.isWebImageURL(url) {
        // Store URL for Flutter fallback download; also start native download in parallel.
        ShareStore.saveWebURL(url)
        ShareStore.downloadAndPersist(url: url) {}
        break
      }
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  // Warm launch: app is in background, user picks "Open In MiRRA".
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    print("[Share] openURLContexts — count: \(URLContexts.count)")
    for ctx in URLContexts {
      let url = ctx.url
      if ShareStore.saveFile(url: url) {
        MirraSharePlugin.channel?.invokeMethod("sharedImage", arguments: nil)
        break
      }
      if ShareStore.isWebImageURL(url) {
        // Download in background; notify Flutter when done.
        ShareStore.downloadAndPersist(url: url) {
          MirraSharePlugin.channel?.invokeMethod("sharedImage", arguments: nil)
        }
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
    case "getPendingSharedImageUrl":
      getPendingSharedImageUrl(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Returns raw bytes of a locally saved image (file:// share path).
  private func getPendingSharedImage(result: @escaping FlutterResult) {
    guard let path = UserDefaults.standard.string(forKey: ShareStore.pendingKey) else {
      result(nil); return
    }
    defer {
      UserDefaults.standard.removeObject(forKey: ShareStore.pendingKey)
      try? FileManager.default.removeItem(atPath: path)
    }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
      result(nil); return
    }
    print("[Share] returning \(data.count) bytes to Flutter")
    result(FlutterStandardTypedData(bytes: data))
  }

  // Returns web image URL string for Flutter to download (cold-launch web-URL path).
  private func getPendingSharedImageUrl(result: @escaping FlutterResult) {
    let url = UserDefaults.standard.string(forKey: ShareStore.pendingUrlKey)
    UserDefaults.standard.removeObject(forKey: ShareStore.pendingUrlKey)
    result(url)
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
