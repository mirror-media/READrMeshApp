import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CollectionTimestamp extends StatefulWidget {
  final DateTime dateTime;
  final double textSize;
  final Color? textColor;
  const CollectionTimestamp(
    this.dateTime, {
    this.textSize = 12.0,
    this.textColor,
    required Key key,
  }) : super(key: key);

  @override
  State<CollectionTimestamp> createState() => _CollectionTimestampState();
}

class _CollectionTimestampState extends State<CollectionTimestamp> {
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
      text = 'justUpdated'.tr;
    } else if (_duration.inMinutes < 60) {
      if (isEnglish && _duration.inMinutes == 1) {
        text = 'Updated a minute ago';
      } else if (isEnglish) {
        text = 'Updated ${_duration.inMinutes}${'minutesAgo'.tr}';
      } else {
        text = '${_duration.inMinutes}${'minutesAgo'.tr}更新';
      }
    } else if (_duration.inHours < 24) {
      if (isEnglish && _duration.inHours == 1) {
        text = 'Updated an hour ago';
      } else if (isEnglish) {
        text = 'Updated ${_duration.inHours}${'hoursAgo'.tr}';
      } else {
        text = '${_duration.inHours}${'hoursAgo'.tr}更新';
      }
    } else if (_duration.inDays < 8) {
      if (isEnglish && _duration.inDays == 1) {
        text = 'Updated a day ago';
      } else if (isEnglish) {
        text = 'Updated ${_duration.inDays}${'daysAgo'.tr}';
      } else {
        text = '${_duration.inDays}${'daysAgo'.tr}更新';
      }
    } else {
      if (isEnglish) {
        text = 'Updated on ${DateFormat('MM/dd/yyyy').format(widget.dateTime)}';
      } else {
        text = '${DateFormat('yyyy/MM/dd').format(widget.dateTime)}更新';
      }
    }

    return Text(
      text,
      softWrap: true,
      strutStyle: const StrutStyle(
        forceStrutHeight: true,
        leading: 0.5,
      ),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
            color: widget.textColor,
          ),
    );
  }
}
