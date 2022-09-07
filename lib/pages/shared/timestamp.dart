import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readr/helpers/dataConstants.dart';

class Timestamp extends StatefulWidget {
  final DateTime dateTime;
  final double textSize;
  final Color textColor;
  final bool isEdited;
  const Timestamp(
    this.dateTime, {
    this.textSize = 12.0,
    this.textColor = readrBlack50,
    this.isEdited = false,
    required Key key,
  }) : super(key: key);

  @override
  State<Timestamp> createState() => _TimestampState();
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
    bool isEnglish = Get.locale?.languageCode == 'en';
    if (_duration.inSeconds < 60) {
      text = 'just'.tr;
    } else if (_duration.inMinutes < 60) {
      if (isEnglish && _duration.inMinutes == 1) {
        text = 'A minute ago';
      } else {
        text = '${_duration.inMinutes}${'minutesAgo'.tr}';
      }
    } else if (_duration.inHours < 24) {
      if (isEnglish && _duration.inHours == 1) {
        text = 'An hour ago';
      } else {
        text = '${_duration.inHours}${'hoursAgo'.tr}';
      }
    } else if (_duration.inDays < 8) {
      if (isEnglish && _duration.inDays == 1) {
        text = 'One day ago';
      } else {
        text = '${_duration.inDays}${'daysAgo'.tr}';
      }
    } else {
      if (isEnglish) {
        text = DateFormat('MM/dd/yyyy').format(widget.dateTime);
      } else {
        text = DateFormat('yyyy/MM/dd').format(widget.dateTime);
      }
    }

    if (widget.isEdited) {
      text += 'edited'.tr;
    }

    return Text(
      text,
      softWrap: true,
      strutStyle: const StrutStyle(
        forceStrutHeight: true,
        leading: 0.5,
      ),
      style: TextStyle(
        fontSize: fontSize,
        color: widget.textColor,
      ),
    );
  }
}
