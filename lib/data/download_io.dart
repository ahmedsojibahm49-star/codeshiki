import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Saves downloaded bytes to the app documents directory and returns the
/// local file path. (Mobile/desktop implementation — see download_stub.dart
/// for web.)
Future<String> saveDownload(String lessonId, Uint8List bytes) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/downloads/$lessonId.mp4');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
  return file.path;
}

/// Deletes a downloaded file if it exists. Returns true when a file was
/// actually removed.
Future<bool> deleteDownload(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
  } catch (_) {
    // File already gone or unreadable — treat as removed.
  }
  return false;
}
