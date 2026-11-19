/// Platform-selected video controller factory.
/// `dart:io` does not exist on web, so the file-playback implementation
/// lives in video_source_io.dart and a network-only stub in
/// video_source_stub.dart.
library;
export 'video_source_stub.dart'
    if (dart.library.io) 'video_source_io.dart';
