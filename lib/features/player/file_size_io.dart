import 'dart:io';

/// Size of a downloaded file in bytes. Returns 0 for `web:` marker paths,
/// missing files, or any read error.
Future<int> downloadedFileSize(String path) async {
  if (path.startsWith('web:')) return 0;
  try {
    final file = File(path);
    if (await file.exists()) return await file.length();
  } catch (_) {
    // File gone or unreadable — treat as 0 bytes.
  }
  return 0;
}
