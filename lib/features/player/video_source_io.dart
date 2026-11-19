import 'dart:io';

import 'package:video_player/video_player.dart';

/// Builds a controller for a downloaded file when [localPath] is a real
/// local file, otherwise streams [url]. `web:` marker paths (recorded by
/// the downloads provider on web) are never local files.
VideoPlayerController controllerForVideo({
  String? localPath,
  required String url,
}) {
  if (localPath != null && !localPath.startsWith('web:')) {
    final file = File(localPath);
    if (file.existsSync()) {
      return VideoPlayerController.file(file);
    }
  }
  return VideoPlayerController.networkUrl(Uri.parse(url));
}
