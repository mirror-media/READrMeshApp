import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dateTimeFormat.dart';
import 'package:readr/helpers/themes.dart';

class READrAudioPlayer extends StatefulWidget {
  /// The baseUrl of the audio
  final String audioUrl;

  /// The title of audio
  final String? title;

  /// The description of audio
  final String? description;
  final double textSize;
  const READrAudioPlayer(
      {required this.audioUrl,
      this.title,
      this.description,
      this.textSize = 20});

  @override
  State<READrAudioPlayer> createState() => _READrAudioPlayerState();
}

class _READrAudioPlayerState extends State<READrAudioPlayer>
    with AutomaticKeepAliveClientMixin {
  late AudioPlayer _audioPlayer;
  bool get _checkIsPlaying => !(_audioPlayer.state == PlayerState.completed ||
      _audioPlayer.state == PlayerState.stopped ||
      _audioPlayer.state == PlayerState.paused);
  Duration _duration = const Duration();
  late double _textSize;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _initAudioPlayer();
    _textSize = widget.textSize;
    super.initState();
  }

  void _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setSourceUrl(widget.audioUrl);
  }

  _start() async {
    try {
      _duration = await _audioPlayer.getDuration() ?? const Duration();
      if (_duration.inMilliseconds < 0) {
        _duration = const Duration();
      }
    } catch (e) {
      _duration = const Duration();
    }

    await _audioPlayer.play(UrlSource(widget.audioUrl));
  }

  _play() async {
    await _audioPlayer.resume();
  }

  _pause() async {
    await _audioPlayer.pause();
  }

  _playAndPause() {
    if (_audioPlayer.state == PlayerState.completed ||
        _audioPlayer.state == PlayerState.stopped) {
      _start();
    } else if (_audioPlayer.state == PlayerState.playing) {
      _pause();
    } else if (_audioPlayer.state == PlayerState.paused) {
      _play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.release();
    super.dispose();
  }

  @override
  void didUpdateWidget(READrAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _textSize = widget.textSize;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.onPlayerStateChanged,
              builder: (context, snapshot) {
                return InkWell(
                  child: _checkIsPlaying
                      ? Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 3,
                                color: Theme.of(context)
                                    .extension<CustomColors>()!
                                    .primary700!,
                              )),
                          child: Icon(
                            Icons.pause,
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .primary700!,
                            size: 40,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 3,
                                color: Theme.of(context)
                                    .extension<CustomColors>()!
                                    .primary700!,
                              )),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .primary700!,
                            size: 40,
                          ),
                        ),
                  onTap: () {
                    _playAndPause();
                  },
                );
              },
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null) ...[
                    Text(
                      widget.title!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: _textSize - 4),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                  StreamBuilder<Duration>(
                    stream: _audioPlayer.onPositionChanged,
                    builder: (context, snapshot) {
                      double sliderPosition = snapshot.data == null
                          ? 0.0
                          : snapshot.data!.inMilliseconds.toDouble();
                      String position =
                          DateTimeFormat.stringDuration(snapshot.data);
                      String duration =
                          DateTimeFormat.stringDuration(_duration);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              overlayShape: SliderComponentShape.noThumb,
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 0.0),
                            ),
                            child: _duration.inMilliseconds == 0
                                ? Slider(
                                    value: 0,
                                    inactiveColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .primary300!,
                                    thumbColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .primary700!,
                                    onChanged: (v) {},
                                  )
                                : Slider(
                                    min: 0.0,
                                    max: _duration.inMilliseconds.toDouble(),
                                    value: sliderPosition,
                                    activeColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .primary700!,
                                    inactiveColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .primary300!,
                                    thumbColor: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .primary700!,
                                    onChanged: (v) {
                                      _audioPlayer.seek(
                                          Duration(milliseconds: v.toInt()));
                                    },
                                  ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  position,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                                VerticalDivider(
                                  color: Theme.of(context)
                                      .extension<CustomColors>()!
                                      .primaryLv6!,
                                  thickness: 1,
                                  width: 17,
                                ),
                                Text(
                                  duration,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
