import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ParseTheTextToHtmlWidget extends StatelessWidget {
  final String? html;
  final Color? color;
  final double fontSize;
  const ParseTheTextToHtmlWidget({
    required this.html,
    this.color,
    this.fontSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    if (html == null) {
      return Container();
    }

    return HtmlWidget(
      html!,
      customStylesBuilder: (element) => {
        'a':
            '{text-decoration-color: #ebf02c; color: black; text-decoration-thickness: 100%}',
        'h1': '{line-height: 28.6px; font-weight: 600; font-size: 22px}',
        'h2': '{line-height: 27px; font-weight: 500; font-size: 18px}',
      },
      textStyle: TextStyle(
        fontSize: fontSize,
        height: 1.8,
        color: color,
      ),
    );
  }
}
