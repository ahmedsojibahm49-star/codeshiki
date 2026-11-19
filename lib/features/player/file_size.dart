/// Platform-selected file-size helper for the storage screen.
/// `dart:io` does not exist on web, so the real implementation lives in
/// file_size_io.dart and a zero-returning stub in file_size_stub.dart.
library;
export 'file_size_stub.dart'
    if (dart.library.io) 'file_size_io.dart';
