import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dateTimeFormat.dart';

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
  _READrAudioPlayerState createState() => _READrAudioPlayerState();
}

class _READrAudioPlayerState extends State<READrAudioPlayer>
    with AutomaticKeepAliveClientMixin {
  late AudioPlayer _audioPlayer;
  bool get _checkIsPlaying => !(_audioPlayer.state == PlayerState.COMPLETED ||
      _audioPlayer.state == PlayerState.STOPPED ||
      _audioPlayer.state == PlayerState.PAUSED);
  int _duration = 0;
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
    await _audioPlayer.setUrl(widget.audioUrl);
  }

  _start() async {
    try {
      _duration = await _audioPlayer.getDuration();
      if (_duration < 0) {
        _duration = 0;
      }
    } catch (e) {
      _duration = 0;
    }

    await _audioPlayer.play(widget.audioUrl);
  }

  _play() async {
    await _audioPlayer.resume();
  }

  _pause() async {
    await _audioPlayer.pause();
  }

  _playAndPause() {
    if (_audioPlayer.state == PlayerState.COMPLETED ||
        _audioPlayer.state == PlayerState.STOPPED) {
      _start();
    } else if (_audioPlayer.state == PlayerState.PLAYING) {
      _pause();
    } else if (_audioPlayer.state == PlayerState.PAUSED) {
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
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black12, width: 1.0),
        borderRadius: BorderRadius.circular(6.0),
      ),
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
                                color: readrBlack87,
                              )),
                          child: const Icon(
                            Icons.pause,
                            color: readrBlack87,
                            size: 40,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 3,
                                color: readrBlack87,
                              )),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: readrBlack87,
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
                      style: TextStyle(
                        fontSize: _textSize - 4,
                        fontWeight: FontWeight.w500,
                        color: readrBlack87,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                  StreamBuilder<Duration>(
                    stream: _audioPlayer.onAudioPositionChanged,
                    builder: (context, snapshot) {
                      double sliderPosition = snapshot.data == null
                          ? 0.0
                          : snapshot.data!.inMilliseconds.toDouble();
                      String position =
                          DateTimeFormat.stringDuration(snapshot.data);
                      String duration = DateTimeFormat.stringDuration(
                          Duration(milliseconds: _duration));
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
                            child: _duration == 0
                                ? Slider(
                                    value: 0,
                                    inactiveColor: Colors.black26,
                                    thumbColor: readrBlack87,
                                    onChanged: (v) {},
                                  )
                                : Slider(
                                    min: 0.0,
                                    max: _duration.toDouble(),
                                    value: sliderPosition,
                                    activeColor: readrBlack87,
                                    inactiveColor: Colors.black26,
                                    thumbColor: readrBlack87,
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
                                  style: const TextStyle(
                                    color: readrBlack50,
                                  ),
                                ),
                                const VerticalDivider(
                                  color: Colors.black12,
                                  thickness: 1,
                                  width: 17,
                                ),
                                Text(
                                  duration,
                                  style: const TextStyle(
                                    color: readrBlack50,
                                  ),
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
