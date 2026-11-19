import 'dart:typed_data';

/// Web has no filesystem: downloads are recorded with a `web:` marker path
/// instead of a real file. The lesson still counts as downloaded in the UI;
/// playback falls back to streaming the original URL.
Future<String> saveDownload(String lessonId, Uint8List bytes) async =>
    'web:$lessonId';

Future<bool> deleteDownload(String path) async => true;
