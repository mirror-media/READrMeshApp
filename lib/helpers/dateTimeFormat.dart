import 'package:intl/intl.dart';

class DateTimeFormat {
  /// format type:
  /// https://api.flutter.dev/flutter/intl/DateFormat-class.html
  /// format: 'EEE, d MMM yyyy HH:mm:ss vvv' ex: 'Fri, 05 Mar 2021 02:03:19 GMT'
  /// format: 'yyyy-MM-ddTHH:mm:ssZ' ex: '2020-09-02T09:30:38.355Z'
  String changeStringToDisplayString(
      String data, String originFormatType, String targetFormatType) {
    int gmtHour = DateTime.now().timeZoneOffset.inHours;

    DateTime parsedDate = DateFormat(originFormatType).parse(data);
    DateTime gmt8Date = parsedDate.add(Duration(hours: gmtHour));
    return DateFormat(targetFormatType).format(gmt8Date);
  }

  /// return string of duration in mm:ss form(has pending 0)
  static String stringDuration(Duration? duration) {
    if (duration == null) {
      return "00:00";
    }

    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
