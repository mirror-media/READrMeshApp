import 'package:flutter/material.dart';
import 'package:readr/helpers/themes.dart';

class QuoteByWidget extends StatelessWidget {
  final String quote;
  final String? quoteBy;
  final double textSize;
  const QuoteByWidget({required this.quote, this.quoteBy, this.textSize = 20});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      padding: const EdgeInsets.only(top: 8, left: 32, right: 32, bottom: 32),
      child: Column(
        children: [
          RotatedBox(
            quarterTurns: 2,
            child: Icon(
              Icons.format_quote,
              size: 60,
              color: Theme.of(context).extension<CustomColors>()?.primary400,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: width,
            child: Text(
              quote,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(height: 1.5),
            ),
          ),
          if (quoteBy != null && quoteBy != '') ...[
            const SizedBox(
              height: 16,
            ),
            Container(
              width: width,
              alignment: Alignment.centerRight,
              child: Text(
                '—— $quoteBy',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
