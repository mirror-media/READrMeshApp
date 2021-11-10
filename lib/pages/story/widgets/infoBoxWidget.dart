import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:readr/helpers/dataConstants.dart';

class InfoBoxWidget extends StatelessWidget {
  final String title;
  final String description;
  final double textSize;
  const InfoBoxWidget({
    required this.title,
    required this.description,
    this.textSize = 20,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: textSize,
                  color: infoBoxTitleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            HtmlWidget(
              description,
              customStylesBuilder: (element) {
                if (element.localName == 'a') {
                  return {
                    'text-decoration-color': '#ebf02c',
                    'color': 'black',
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
                }
                return null;
              },
              textStyle: TextStyle(
                fontSize: textSize,
                height: 1.8,
                //color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
