import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
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
          child: const Icon(
            Icons.format_quote,
            size: 60,
            color: blockquoteColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ParseTheTextToHtmlWidget(
            html: content,
            color: blockquoteColor,
            fontSize: textSize,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.format_quote,
          size: 60,
          color: blockquoteColor,
        ),
      ],
    );
  }
}
