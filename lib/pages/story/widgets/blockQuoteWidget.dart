import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/story/widgets/parseTheTextToHtmlWidget.dart';

class BlockQuoteWidget extends StatelessWidget {
  final String content;
  final double textSize;
  const BlockQuoteWidget({required this.content, this.textSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.rotate(
          angle: 180 * math.pi / 180,
          child: Icon(
            Icons.format_quote,
            size: 60,
            color: Theme.of(context).extension<CustomColors>()?.primaryLv6,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ParseTheTextToHtmlWidget(
            html: content,
            color: Theme.of(context).extension<CustomColors>()?.primaryLv1,
            fontSize: textSize,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.format_quote,
          size: 60,
          color: Theme.of(context).extension<CustomColors>()?.primaryLv6,
        ),
      ],
    );
  }
}
