import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class MNewsVideoPlayer extends StatefulWidget {
  /// The baseUrl of the video
  final String videourl;

  /// Play the video as soon as it's displayed
  final bool autoPlay;

  /// Start video at a certain position
  final Duration? startAt;

  /// Whether or not the video should loop
  final bool looping;

  /// The Aspect Ratio of the Video. Important to get the correct size of the
  /// video!
  ///
  /// Will fallback to fitting within the space allowed.
  final double aspectRatio;

  /// Whether or not the video muted
  final bool muted;

  const MNewsVideoPlayer({
    Key? key,
    required this.videourl,
    required this.aspectRatio,
    this.autoPlay = false,
    this.startAt,
    this.muted = false,
    this.looping = false,
  }) : super(key: key);

  @override
  State<MNewsVideoPlayer> createState() => _MNewsVideoPlayerState();
}

class _MNewsVideoPlayerState extends State<MNewsVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late Future<bool> _configChewieFuture;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _configChewieFuture = _configVideoPlayer();
    super.initState();
  }

  Future<bool> _configVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videourl);
    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoInitialize: true,
        autoPlay: widget.autoPlay,
        showOptions: false,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
      if (widget.muted) _chewieController.setVolume(0.0);
      _isInitialized = true;
    } catch (e) {
      print("Video Player error:$e");
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _videoPlayerController.dispose();
      _chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<bool>(
        initialData: false,
        future: _configChewieFuture,
        builder: (context, snapshot) {
          return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            if (!snapshot.data!) {
              return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth / widget.aspectRatio,
                  child: const Center(
                      child: CircularProgressIndicator.adaptive()));
            }

            Widget videoPlayer = Chewie(
              controller: _chewieController,
            );

            if (Platform.isAndroid) {
              videoPlayer = Theme(
                data: ThemeData.light().copyWith(
                  platform: TargetPlatform.windows,
                ),
                child: Chewie(
                  controller: _chewieController,
                ),
              );
            }

            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxWidth /
                  _videoPlayerController.value.aspectRatio,
              child: videoPlayer,
            );
          });
        });
  }
}
