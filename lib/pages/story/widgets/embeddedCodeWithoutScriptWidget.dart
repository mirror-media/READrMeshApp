import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmbeddedCodeWithoutScriptWidget extends StatefulWidget {
  final String embeddedCode;
  final double? aspectRatio;

  const EmbeddedCodeWithoutScriptWidget(
      {required this.embeddedCode, this.aspectRatio});

  @override
  _EmbeddedCodeWithoutScriptWidgetState createState() =>
      _EmbeddedCodeWithoutScriptWidgetState();
}

class _EmbeddedCodeWithoutScriptWidgetState
    extends State<EmbeddedCodeWithoutScriptWidget>
    with AutomaticKeepAliveClientMixin {
  bool _screenIsReseted = false;
  late WebViewController _webViewController;
  double? _webViewWidth;
  double? _webViewHeight;
  late double _webViewAspectRatio;
  late double _webViewBottomPadding;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _webViewAspectRatio = widget.aspectRatio ?? 16 / 9;
    _webViewBottomPadding = 16;
    super.initState();
  }

  _loadHtmlFromAssets(String embeddedCode, double width) {
    String html = _getHtml(embeddedCode, width);
    _webViewController.loadUrl(Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  String _getHtml(String embeddedCode, double width) {
    double scale = 1.0001;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=$width, user-scalable=no, initial-scale=$scale, maximum-scale=$scale, minimum-scale=$scale, shrink-to-fit=no">
  <meta http-equiv="X-UA-Compatible" content="chrome=1">

  <title>Document</title>
  <style>
    body {
      margin: 0;
      padding: 0; 
      background: #F5F5F5;
    }
    div.iframe-width {
      width: 100%;
    }
  </style>
</head>
  <script src="https://www.instagram.com/embed.js"></script>
  <body>
    <center>
      <div class="iframe-width">
        $embeddedCode
      </div>
    </center>
  </body>
</html>
        ''';
  }

  bool _isHigherThanScreenHeight(
      double width, double height, double ratio, double bottomPadding) {
    double webviewHeight = width / ratio;
    return (webviewHeight + bottomPadding) > height;
  }

  double _getIframeHeight(
      double width, double height, double ratio, double bottomPadding) {
    if (Platform.isIOS) {
      return width / ratio + bottomPadding;
    }

    return _isHigherThanScreenHeight(width, height, ratio, bottomPadding)
        ? height
        : width / ratio + bottomPadding;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 40;
    var height = MediaQuery.of(context).size.height;
    super.build(context);
    return SizedBox(
      width: width,
      height: _getIframeHeight(
        width,
        height,
        _webViewAspectRatio,
        _webViewBottomPadding,
      ),
      child: WebView(
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
          _loadHtmlFromAssets(widget.embeddedCode, width);
        },
        javascriptMode: JavascriptMode.unrestricted,
        gestureRecognizers: null,
        onPageFinished: (e) async {
          _webViewWidth = double.tryParse(
            await _webViewController
                .evaluateJavascript("document.documentElement.scrollWidth;"),
          );
          _webViewHeight = double.tryParse(
            await _webViewController
                .evaluateJavascript("document.documentElement.scrollHeight;"),
          );
        },
      ),
    );
  }
}
