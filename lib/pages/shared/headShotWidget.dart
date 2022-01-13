import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';

class HeadShotWidget extends StatelessWidget {
  final String nameOrImageUrl;
  final double radius;
  const HeadShotWidget(this.nameOrImageUrl, this.radius);

  @override
  Widget build(BuildContext context) {
    bool isUrl = Uri.tryParse(nameOrImageUrl)?.hasAbsolutePath ?? false;
    if (isUrl) {
      return CircleAvatar(
        foregroundImage: NetworkImage(nameOrImageUrl),
        backgroundImage: const AssetImage(authorDefaultPng),
        radius: radius,
      );
    }
    Color randomColor =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];
    Color textColor =
        randomColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    String firstLetter = nameOrImageUrl.split('')[0];
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
