import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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
    return Container(
      color: const Color.fromRGBO(246, 246, 251, 1),
      padding: const EdgeInsets.symmetric(vertical: 32),
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color.fromRGBO(4, 41, 94, 1),
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              color: const Color.fromRGBO(246, 246, 251, 1),
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: textSize,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
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
                } else if (element.localName == 'strong') {
                  return {
                    'color': 'black',
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
                //color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
