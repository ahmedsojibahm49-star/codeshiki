/// Platform-selected download file helpers.
/// `dart:io` does not exist on web, so the real implementation lives in
/// download_io.dart and a no-op stub in download_stub.dart.
library;
export 'download_stub.dart'
    if (dart.library.io) 'download_io.dart';
