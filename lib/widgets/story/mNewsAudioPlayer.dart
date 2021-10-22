import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dateTimeFormat.dart';

class MNewsAudioPlayer extends StatefulWidget {
  /// The baseUrl of the audio
  final String audioUrl;

  /// The title of audio
  final String? title;

  /// The description of audio
  final String? description;
  final double textSize;
  const MNewsAudioPlayer(
      {required this.audioUrl,
      this.title,
      this.description,
      this.textSize = 20});

  @override
  _MNewsAudioPlayerState createState() => _MNewsAudioPlayerState();
}

class _MNewsAudioPlayerState extends State<MNewsAudioPlayer>
    with AutomaticKeepAliveClientMixin {
  final Color _audioColor = const Color(0xff014DB8);
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
  void didUpdateWidget(MNewsAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _textSize = widget.textSize;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      elevation: 10,
      color: const Color(0xffD8EAEB),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: TextStyle(
                  fontSize: _textSize + 4,
                  fontWeight: FontWeight.w600,
                  color: _audioColor,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
            Row(
              children: [
                StreamBuilder<PlayerState>(
                    stream: _audioPlayer.onPlayerStateChanged,
                    builder: (context, snapshot) {
                      return InkWell(
                        child: _checkIsPlaying
                            ? const ClipOval(
                                child: Material(
                                  color: Color(0xff003366),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.pause,
                                      color: Color(0xffFFCC00),
                                      size: 40,
                                    ),
                                  ),
                                ),
                              )
                            : const ClipOval(
                                child: Material(
                                  color: Color(0xff003366),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Color(0xffFFCC00),
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                        onTap: () {
                          _playAndPause();
                        },
                      );
                    }),
                Expanded(
                  child: StreamBuilder<Duration>(
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
                            _duration == 0
                                ? Slider(
                                    value: 0,
                                    onChanged: (v) {},
                                  )
                                : Slider(
                                    min: 0.0,
                                    max: _duration.toDouble(),
                                    value: sliderPosition,
                                    activeColor: _audioColor,
                                    inactiveColor: const Color(0xff979797),
                                    onChanged: (v) {
                                      _audioPlayer.seek(
                                          Duration(milliseconds: v.toInt()));
                                    },
                                  ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 24.0, left: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    position,
                                    style: TextStyle(
                                      color: _audioColor,
                                    ),
                                  ),
                                  Text(
                                    duration,
                                    style: TextStyle(
                                      color: _audioColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
