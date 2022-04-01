import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:readr/models/annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnotationWidget extends StatefulWidget {
  final double textSize;
  final bool showAnnotations;
  final List<String>? annotationData;
  final ItemScrollController? itemScrollController;
  final int annotationNumber;
  const AnnotationWidget({
    this.textSize = 20,
    required this.showAnnotations,
    required this.annotationData,
    this.annotationNumber = 1,
    this.itemScrollController,
  });

  @override
  _AnnotationWidgetState createState() => _AnnotationWidgetState();
}

class _AnnotationWidgetState extends State<AnnotationWidget> {
  late double textSize;
  late bool _showAnnotations;
  late List<String>? _annotationList;

  @override
  void initState() {
    textSize = widget.textSize;
    _showAnnotations = widget.showAnnotations;
    _annotationList = widget.annotationData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildHtmlWidget(context),
    );
  }

  Widget _buildHtmlWidget(BuildContext context) {
    if (_annotationList == null) {
      return Container();
    }
    String newHtml = '';
    RegExp annotationExp = RegExp(
      r'__ANNOTATION__=(.*)',
      caseSensitive: false,
    );
    for (int i = 0; i < _annotationList!.length; i++) {
      if (annotationExp.hasMatch(_annotationList![i])) {
        String body = annotationExp.firstMatch(_annotationList![i])!.group(1)!;
        Annotation annotation = Annotation.parseResponseBody(body);
        if (!_showAnnotations) {
          newHtml = newHtml + annotation.text;
        } else {
          String annotationTextHtml;
          annotationTextHtml = '<a id="annotation" href="annotation">' +
              annotation.text +
              '</a>' +
              '<sup id="annotationNumber">' +
              widget.annotationNumber.toString() +
              '</sup> ';
          newHtml = newHtml + annotationTextHtml;
        }
      } else {
        newHtml = newHtml + _annotationList![i];
      }
    }
    return HtmlWidget(
      newHtml,
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          if (element.id == 'annotation') {
            return {
              'text-decoration-color': 'black',
              'color': 'black',
              'text-decoration-thickness': '100%',
              'font-weight': '500',
            };
          }
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
        } else if (element.id == 'annotationNumber') {
          return {
            'font-size': '12px',
            'color': '#04295E',
          };
        }
        return null;
      },
      textStyle: TextStyle(
        fontSize: textSize,
        height: 1.8,
      ),
      onTapUrl: (url) async {
        if (url == 'annotation') {
          if (widget.itemScrollController != null) {
            widget.itemScrollController!.scrollTo(
                index: 13, duration: const Duration(milliseconds: 800));
            return true;
          } else {
            return false;
          }
        } else {
          await launch(url);
          return true;
        }
      },
    );
  }
}
