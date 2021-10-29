import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/story/widgets/quoteByFrameClipper.dart';

class QuoteByWidget extends StatelessWidget {
  final String quote;
  final String? quoteBy;
  final double textSize;
  const QuoteByWidget({required this.quote, this.quoteBy, this.textSize = 20});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          quote,
          style: TextStyle(
            fontSize: textSize,
            height: 1.8,
          ),
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: ClipPath(
            clipper: QuoteByTopFrameClipper(),
            child: Container(
              height: width / 8,
              width: width / 8,
              decoration: const BoxDecoration(
                color: quotebyColor,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (quoteBy != null && quoteBy != '') ...[
              Text(
                '—— $quoteBy',
                style: TextStyle(
                  fontSize: textSize - 2,
                  color: quotebyColor,
                ),
              ),
              const SizedBox(width: 8.0),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ClipPath(
                clipper: QuoteByBottomFrameClipper(),
                child: Container(
                  height: width / 8,
                  width: width / 8,
                  decoration: const BoxDecoration(
                    color: quotebyColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
