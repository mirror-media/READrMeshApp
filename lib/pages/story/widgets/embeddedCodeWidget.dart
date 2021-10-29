import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:readr/pages/story/widgets/fbEmbeddedCodeWidget.dart';
import 'package:readr/pages/story/widgets/googleFormEmbeddedCodeWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCoede;
  final double? aspectRatio;
  const EmbeddedCodeWidget({
    required this.embeddedCoede,
    this.aspectRatio,
  });

  @override
  _EmbeddedCodeWidgetState createState() => _EmbeddedCodeWidgetState();
}

class _EmbeddedCodeWidgetState extends State<EmbeddedCodeWidget>
    with AutomaticKeepAliveClientMixin {
  late WebViewController _webViewController;
  late bool _screenIsReseted;

  double? _webViewWidth;
  double? _webViewHeight;
  late double _webViewAspectRatio;
  late double _webViewBottomPadding;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    _screenIsReseted = false;
    _webViewAspectRatio = widget.aspectRatio ?? 16 / 9;
    _webViewBottomPadding = 16;
    super.initState();
  }

  _loadHtmlFromAssets(String embeddedCoede, double width) {
    String html = _getHtml(embeddedCoede, width);

    _webViewController.loadUrl(Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }

  String _getHtml(String embeddedCoede, double width) {
    double scale = 1.0001;
    if (widget.embeddedCoede.contains('www.facebook.com/plugins')) {
      RegExp widthRegExp = RegExp(
        r'width="(.[0-9]*)"',
        caseSensitive: false,
      );
      double facebookIframeWidth =
          double.parse(widthRegExp.firstMatch(widget.embeddedCoede)!.group(1)!);
      scale = width / facebookIframeWidth;
    }

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
        $embeddedCoede
      </div>
    </center>
  </body>
</html>
        ''';
  }

  // refer to the link(https://github.com/flutter/flutter/issues/2897)
  // webview will cause the device to crash in some physical android device,
  // when the webview height is higher than the physical device screen height.
  // --------------------------------------------------
  // width : device screen width - 32(padding)
  // height : device screen height
  // ratio : webview aspect ratio
  // width / ratio + bottomPadding : webview height + bottomPadding(padding)
  bool _isHigherThanScreenHeight(
      double width, double height, double ratio, double bottomPadding) {
    double webviewHeight = width / ratio;
    return (webviewHeight + bottomPadding) > height;
  }

  double _getIframeHeight(
      double width, double height, double? ratio, double? bottomPadding) {
    if (Platform.isIOS) {
      return width / ratio! + bottomPadding!;
    }

    return _isHigherThanScreenHeight(width, height, ratio!, bottomPadding!)
        ? height
        : width / ratio + bottomPadding;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 32;
    var height = MediaQuery.of(context).size.height;

    super.build(context);
    // rendering a special iframe webview of facebook in android,
    // or it will be getting screen overflow.
    if (widget.embeddedCoede.contains('www.facebook.com/plugins') &&
        Platform.isAndroid) {
      return FbEmbeddedCodeWidget(
        embeddedCoede: widget.embeddedCoede,
      );
    }

    if (widget.embeddedCoede.contains('docs.google.com/forms')) {
      return GoogleFormEmbeddedCodeWidget(
        embeddedCoede: widget.embeddedCoede,
      );
    }

    return SizedBox(
      width: width,
      height: _getIframeHeight(
        width,
        height,
        _webViewAspectRatio,
        _webViewBottomPadding,
      ),
      child: Stack(
        children: [
          // display iframe
          SizedBox(
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
                _loadHtmlFromAssets(widget.embeddedCoede, width);
              },
              javascriptMode: JavascriptMode.unrestricted,
              gestureRecognizers: null,
              onPageFinished: (e) async {
                if (widget.embeddedCoede.contains('instagram-media')) {
                  await _webViewController
                      .evaluateJavascript('instgrm.Embeds.process();');
                  // waiting for iframe rendering(workaround)
                  await Future.delayed(const Duration(seconds: 5));
                  _webViewWidth = double.tryParse(
                    await _webViewController.evaluateJavascript(
                        "document.documentElement.scrollWidth;"),
                  );
                  _webViewHeight = double.tryParse(
                    await _webViewController.evaluateJavascript(
                        'document.querySelector(".instagram-media").getBoundingClientRect().height;'),
                  );
                } else if (widget.embeddedCoede.contains('twitter-tweet')) {
                  // waiting for iframe rendering(workaround)
                  while (_webViewHeight == null || _webViewHeight == 0) {
                    await Future.delayed(const Duration(seconds: 1));
                    _webViewHeight = double.tryParse(
                      await _webViewController.evaluateJavascript(
                          'document.querySelector(".twitter-tweet").getBoundingClientRect().height;'),
                    );
                  }
                  _webViewWidth = double.tryParse(
                    await _webViewController.evaluateJavascript(
                        'document.querySelector(".twitter-tweet").getBoundingClientRect().width;'),
                  );
                } else if (widget.embeddedCoede
                    .contains('www.facebook.com/plugins')) {
                  if (widget.embeddedCoede
                      .contains('www.facebook.com/plugins/video.php')) {
                    _webViewAspectRatio = 16 / 9;
                  }
                  _webViewBottomPadding = 0;
                } else {
                  _webViewWidth = double.tryParse(
                    await _webViewController.evaluateJavascript(
                        "document.documentElement.scrollWidth;"),
                  );
                  _webViewHeight = double.tryParse(
                    await _webViewController.evaluateJavascript(
                        "document.documentElement.scrollHeight;"),
                  );
                }
                // reset the webview size
                if (mounted && !_screenIsReseted) {
                  if (widget.embeddedCoede
                      .contains('www.facebook.com/plugins')) {
                    setState(() {
                      _screenIsReseted = true;
                    });
                  } else {
                    setState(() {
                      _screenIsReseted = true;
                      if (_webViewWidth != null && _webViewHeight != null) {
                        _webViewAspectRatio = _webViewWidth! / _webViewHeight!;
                      }
                    });
                  }
                }
              },
            ),
          ),
          // display watching more widget when meeting some conditions.
          if (_isHigherThanScreenHeight(
                  width, height, _webViewAspectRatio, _webViewBottomPadding) &&
              Platform.isAndroid)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildWatchingMoreWidget(width),
            ),
          // cover a launching url widget over the iframe
          // when the iframe is not google map.
          if (!widget.embeddedCoede
              .contains('https://www.google.com/maps/embed'))
            InkWell(
              onTap: () {
                _launchUrl(widget.embeddedCoede);
              },
              child: Container(
                width: width,
                height: _getIframeHeight(
                    width, height, _webViewAspectRatio, _webViewBottomPadding),
                color: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWatchingMoreWidget(double width) {
    return Container(
      height: width / 16 * 9 / 3,
      color: Colors.black.withOpacity(0.6),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Center(
          child: Text(
            '點擊觀看更多',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(String embeddedCoede) async {
    RegExp? regExp;
    if (embeddedCoede.contains('instagram-media')) {
      // permalink="(https:\/\/www\.instagram\.com\/p\/\w+\/)
      regExp = RegExp(
        r'permalink="(https:\/\/www\.instagram\.com\/p\/\w+\/)',
        caseSensitive: false,
      );
    } else if (embeddedCoede.contains('twitter-tweet')) {
      // (?>(https:\/\/twitter\.com\/\w{1,15}\/status\/\d+))
      regExp = RegExp(
        r'(https?:\/\/twitter\.com\/\w{1,15}\/status\/\d+)',
        caseSensitive: false,
      );
    } else if (embeddedCoede.contains('www.facebook.com/plugins')) {
      // refer to https://www.facebook.com/help/105399436216001
      regExp = RegExp(
        r'https:\/\/www\.facebook\.com\/plugins\/(?:post|video)\.php\?.*&href=(https?(%3A|\:)(%2F|\\)(%2F|\\)www\.facebook\.com(%2F|\\)(?:[a-zA-Z0-9.]+)(%2F|\\)(?:posts|videos)(%2F|\\)[0-9]+)(%2F?|\\?)\&',
        caseSensitive: false,
      );
    }

    if (regExp != null) {
      var url = regExp.firstMatch(embeddedCoede)!.group(1)!;
      url = Uri.decodeFull(url);
      print(url);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
