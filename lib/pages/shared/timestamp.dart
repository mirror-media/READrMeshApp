import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readr/helpers/dataConstants.dart';

class Timestamp extends StatefulWidget {
  final DateTime dateTime;
  final double textSize;
  final Color textColor;
  const Timestamp(
    this.dateTime, {
    this.textSize = 12.0,
    this.textColor = readrBlack50,
  });

  @override
  _TimestampState createState() => _TimestampState();
}

class _TimestampState extends State<Timestamp> {
  late Duration _duration;
  late Timer _timer;
  bool _timerIsSet = false;

  @override
  void initState() {
    super.initState();
    _duration = DateTime.now().difference(widget.dateTime);
    if (_duration.inMinutes < 60) {
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        setState(() {
          _duration = DateTime.now().difference(widget.dateTime);
        });
        if (_duration.inMinutes >= 60) {
          _timerIsSet = false;
          _timer.cancel();
        }
      });
      _timerIsSet = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_timerIsSet) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = '';
    double fontSize = widget.textSize;
    if (_duration.inSeconds < 60) {
      text = '剛剛';
    } else if (_duration.inMinutes < 60) {
      text = '${_duration.inMinutes}分鐘前';
    } else if (_duration.inHours < 24) {
      text = '${_duration.inHours}小時前';
    } else if (_duration.inDays < 8) {
      text = '${_duration.inDays}天前';
    } else {
      text = DateFormat('yyyy/MM/dd').format(widget.dateTime);
      fontSize = widget.textSize + 0.1;
    }
    return Text(
      text,
      softWrap: true,
      style: TextStyle(
        fontSize: fontSize,
        color: widget.textColor,
      ),
    );
  }
}
