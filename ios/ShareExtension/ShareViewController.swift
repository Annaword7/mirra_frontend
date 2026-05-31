import UIKit
import UniformTypeIdentifiers

// App Group shared between Runner and ShareExtension.
private let kAppGroup = "group.mirra.app"
private let kPendingKey = "mirra_pending_shared_image"
private let kTempFilename = "mirra_shared_image"

class ShareViewController: UIViewController {

  private let imageTypes: [String] = [
    UTType.image.identifier,
    UTType.jpeg.identifier,
    UTType.png.identifier,
    "public.heic",
    UTType.gif.identifier,
    UTType.webP.identifier,
    UTType.bmp.identifier,
    UTType.tiff.identifier,
  ]

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.01)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    processSharedContent()
  }

  // MARK: - Core

  private func processSharedContent() {
    guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
          let provider = item.attachments?.first else {
      finish()
      return
    }

    // Find the first matching image type
    let matchedType = imageTypes.first { provider.hasItemConformingToTypeIdentifier($0) }

    if let typeID = matchedType {
      provider.loadItem(forTypeIdentifier: typeID, options: nil) { [weak self] result, error in
        DispatchQueue.main.async {
          if let error {
            print("[ShareExt] ❌ loadItem error: \(error)")
            self?.finish()
            return
          }
          self?.handleLoadedItem(result)
        }
      }
    } else {
      // Fallback: try as URL (web image link)
      provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] result, _ in
        DispatchQueue.main.async {
          if let url = result as? URL {
            self?.downloadAndSave(url: url)
          } else {
            self?.finish()
          }
        }
      }
    }
  }

  private func handleLoadedItem(_ item: NSSecureCoding?) {
    if let image = item as? UIImage {
      guard let data = image.jpegData(compressionQuality: 0.92) else { finish(); return }
      saveAndOpen(data: data, ext: "jpg")
    } else if let url = item as? URL {
      if url.isFileURL {
        guard let data = try? Data(contentsOf: url) else { finish(); return }
        saveAndOpen(data: data, ext: url.pathExtension)
      } else {
        downloadAndSave(url: url)
      }
    } else if let data = item as? Data {
      saveAndOpen(data: data, ext: "jpg")
    } else {
      finish()
    }
  }

  private func downloadAndSave(url: URL) {
    print("[ShareExt] ⬇️ downloading: \(url)")
    URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
      DispatchQueue.main.async {
        if let data, error == nil {
          self?.saveAndOpen(data: data, ext: url.pathExtension)
        } else {
          print("[ShareExt] ❌ download error: \(error?.localizedDescription ?? "?")")
          self?.finish()
        }
      }
    }.resume()
  }

  // MARK: - Persistence & opening main app

  private func saveAndOpen(data: Data, ext: String) {
    guard let container = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: kAppGroup) else {
      print("[ShareExt] ❌ no App Group container")
      finish(); return
    }

    let fileExt = ext.isEmpty ? "jpg" : ext
    let fileURL = container.appendingPathComponent("\(kTempFilename).\(fileExt)")
    do {
      try data.write(to: fileURL)
      UserDefaults(suiteName: kAppGroup)?.set(fileURL.path, forKey: kPendingKey)
      print("[ShareExt] ✅ saved \(data.count) bytes → \(fileURL.path)")
    } catch {
      print("[ShareExt] ❌ write failed: \(error)")
      finish(); return
    }

    // Close sheet and open main app via URL scheme
    extensionContext?.completeRequest(returningItems: []) { [weak self] _ in
      self?.openMainApp()
    }
  }

  private func openMainApp() {
    guard let url = URL(string: "mirradev://share") else { return }
    // Walk responder chain to reach UIApplication
    var responder: UIResponder? = self
    while let r = responder {
      if let app = r as? UIApplication {
        app.perform(#selector(UIApplication.open(_:options:completionHandler:)),
                    with: url,
                    afterDelay: 0)
        return
      }
      responder = r.next
    }
  }

  private func finish() {
    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }
}
