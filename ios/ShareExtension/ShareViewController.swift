import UIKit
import UniformTypeIdentifiers

private let kAppGroup    = "group.mirra.app"
private let kPendingKey  = "mirra_pending_shared_image"
private let kTempFile    = "mirra_shared_image"

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

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.01)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    processSharedContent()
  }

  // MARK: - Processing

  private func processSharedContent() {
    guard let item     = extensionContext?.inputItems.first as? NSExtensionItem,
          let provider = item.attachments?.first else { finish(); return }

    if let typeID = imageTypes.first(where: { provider.hasItemConformingToTypeIdentifier($0) }) {
      provider.loadItem(forTypeIdentifier: typeID, options: nil) { [weak self] result, error in
        DispatchQueue.main.async {
          if let error { print("[ShareExt] ❌ \(error)"); self?.finish(); return }
          self?.handleLoaded(result)
        }
      }
    } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] result, _ in
        DispatchQueue.main.async {
          if let url = result as? URL { self?.downloadAndSave(url: url) }
          else { self?.finish() }
        }
      }
    } else {
      finish()
    }
  }

  private func handleLoaded(_ item: NSSecureCoding?) {
    if let image = item as? UIImage, let data = image.jpegData(compressionQuality: 0.92) {
      saveAndOpen(data: data, ext: "jpg")
    } else if let url = item as? URL {
      if url.isFileURL, let data = try? Data(contentsOf: url) {
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
    print("[ShareExt] ⬇️ \(url)")
    URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
      DispatchQueue.main.async {
        if let data, error == nil { self?.saveAndOpen(data: data, ext: url.pathExtension) }
        else { self?.finish() }
      }
    }.resume()
  }

  // MARK: - Persistence & open main app

  private func saveAndOpen(data: Data, ext: String) {
    guard let container = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: kAppGroup) else {
      print("[ShareExt] ❌ no App Group container"); finish(); return
    }
    let fileURL = container.appendingPathComponent("\(kTempFile).\(ext.isEmpty ? "jpg" : ext)")
    do {
      try data.write(to: fileURL)
      UserDefaults(suiteName: kAppGroup)?.set(fileURL.path, forKey: kPendingKey)
      print("[ShareExt] ✅ saved \(data.count) bytes")
    } catch {
      print("[ShareExt] ❌ write: \(error)"); finish(); return
    }
    extensionContext?.completeRequest(returningItems: []) { [weak self] _ in
      self?.openMainApp()
    }
  }

  private func openMainApp() {
    guard let url = URL(string: "mirradev://share") else { return }
    extensionContext?.open(url, completionHandler: nil)
  }

  private func finish() {
    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }
}
