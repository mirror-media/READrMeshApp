import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:readr/helpers/themes.dart';

class ParseTheTextToHtmlWidget extends StatelessWidget {
  final String? html;
  final Color? color;
  final double fontSize;
  final bool isCitation;
  const ParseTheTextToHtmlWidget({
    required this.html,
    this.color,
    this.fontSize = 20.0,
    this.isCitation = false,
  });

  @override
  Widget build(BuildContext context) {
    if (html == null) {
      return Container();
    }

    String textColor = Theme.of(context).brightness == Brightness.light
        ? '#DE000928'
        : '#F6F6FB ';

    if (color != null) {
      textColor = '#${color!.value.toRadixString(16)}';
    }

    return HtmlWidget(
      html!,
      customStylesBuilder: (element) {
        if (element.localName == 'a' && isCitation) {
          return {
            'text-decoration-line': 'none',
            'color': textColor,
          };
        } else if (element.localName == 'a') {
          return {
            'text-decoration-color': textColor,
            'color': textColor,
            'text-decoration-thickness': '100%',
          };
        } else if (element.localName == 'h1') {
          return {
            'line-height': '140%',
            'font-weight': '600',
            'font-size': '20px',
          };
        } else if (element.localName == 'h2') {
          return {
            'line-height': '140%',
            'font-weight': '600',
            'font-size': '20px',
          };
        }
        return null;
      },
      textStyle: TextStyle(
        fontSize: fontSize,
        height: 1.8,
        color: color ?? Theme.of(context).extension<CustomColors>()?.primaryLv1,
      ),
    );
  }
}
