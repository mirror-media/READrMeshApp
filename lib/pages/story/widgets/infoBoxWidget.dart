import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:readr/helpers/themes.dart';

class InfoBoxWidget extends StatelessWidget {
  final String title;
  final String description;
  final double textSize;
  const InfoBoxWidget({
    required this.title,
    required this.description,
    this.textSize = 16,
  });
  @override
  Widget build(BuildContext context) {
    String textColor = Theme.of(context).brightness == Brightness.light
        ? '#DE000928'
        : '#F6F6FB ';
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 32),
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).extension<CustomColors>()?.primary700,
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: textSize),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: HtmlWidget(
              description,
              customStylesBuilder: (element) {
                if (element.localName == 'a') {
                  return {
                    'text-decoration-color': textColor,
                    'color': textColor,
                    'text-decoration-thickness': '100%',
                  };
                } else if (element.localName == 'h1') {
                  return {
                    'line-height': '130%',
                    'font-weight': '600',
                    'font-size': '22px',
                  };
                } else if (element.localName == 'h2') {
                  return {
                    'line-height': '150%',
                    'font-weight': '500',
                    'font-size': '18px',
                  };
                } else if (element.localName == 'strong') {
                  return {
                    'color': textColor,
                    'font-weight': '700',
                  };
                } else if (element.localName == 'ul') {
                  return {
                    'padding-left': '18px',
                  };
                }
                return null;
              },
              textStyle: TextStyle(
                fontSize: textSize,
                height: 1.8,
                color: Theme.of(context).extension<CustomColors>()?.primary700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
