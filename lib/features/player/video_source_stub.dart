import 'package:video_player/video_player.dart';

/// Web: no local files — always stream [url].
VideoPlayerController controllerForVideo({
  String? localPath,
  required String url,
}) {
  return VideoPlayerController.networkUrl(Uri.parse(url));
}
