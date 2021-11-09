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
            '{text-decoration-color: #ebf02c; color: black; text-decoration-thickness: 200%}',
      },
      textStyle: TextStyle(
        fontSize: fontSize,
        height: 1.8,
        color: color,
      ),
    );
  }
}
