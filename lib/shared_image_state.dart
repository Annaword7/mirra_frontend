import 'dart:typed_data';

/// Singleton that carries an image shared from outside the app (e.g. via
/// "Open in MiRRA" from the iOS Photos share sheet) across the navigation
/// boundary to TakeorUploadPageWidget.
///
/// Usage:
///   Write:  SharedImageState.instance.pendingImage = bytes;
///   Read:   final bytes = SharedImageState.instance.pendingImage;
///           SharedImageState.instance.pendingImage = null; // consume
class SharedImageState {
  SharedImageState._();
  static final instance = SharedImageState._();

  Uint8List? pendingImage;
}
