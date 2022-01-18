import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';

class HeadShotWidget extends StatelessWidget {
  final Member member;
  final double radius;
  const HeadShotWidget(this.member, this.radius);

  @override
  Widget build(BuildContext context) {
    Color randomColor =
        Colors.primaries[int.parse(member.memberId) % Colors.primaries.length];
    Color textColor =
        randomColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    List<String> splitNickname = member.nickname.split('');
    String firstLetter = '';
    for (int i = 0; i < splitNickname.length; i++) {
      if (splitNickname[i] != " ") {
        firstLetter = splitNickname[i];
        break;
      }
    }

    if (member.headshotUrl != null) {
      return CircleAvatar(
        foregroundImage: NetworkImage(member.headshotUrl!),
        backgroundColor: randomColor,
        child: AutoSizeText(
          firstLetter,
          style: TextStyle(color: textColor),
          minFontSize: 5,
        ),
        radius: radius,
      );
    }
    return CircleAvatar(
      backgroundColor: randomColor,
      radius: radius,
      child: AutoSizeText(
        firstLetter,
        style: TextStyle(color: textColor),
        minFontSize: 5,
      ),
    );
  }
}
