import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FbEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCoede;
  const FbEmbeddedCodeWidget({
    required this.embeddedCoede,
  });

  @override
  _FbEmbeddedCodeWidgetState createState() => _FbEmbeddedCodeWidgetState();
}

class _FbEmbeddedCodeWidgetState extends State<FbEmbeddedCodeWidget> {
  late WebViewController _webViewController;
  String _htmlPage = '';
  double _ratio = 16 / 9;
  RegExpMatch? _regExpMatch;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    // username refer to https://www.facebook.com/help/105399436216001
    // facebook url ex.
    // https://www.facebook.com/ facebookapp              / posts                                / 10160138384851729
    // https://www.facebook.com/ 563994370665617          / videos                               / 397668314698045
    // https://www.facebook.com/ DonDonDonkiTW            / photos           /a.3857266087638216 / 3902755526422605
    // https://www.facebook.com/ permalink.php?story_fbid = 1777370489206638 &id                 = 1765245810419106
    RegExp regExp = RegExp(
      r'src="https:\/\/www\.facebook\.com\/plugins\/(?:post|video)\.php\?(?:.*)href=(https?(?:%3A%2F%2F|\:\/\/)www\.facebook\.com(?:%2F|\/)(?:permalink\.php(?:%3F|\?)story_fbid|[a-zA-Z0-9.]+)(?:%2F|\/|=|%3D)(?:posts|videos|photos|[0-9]+)(?:%2F[a-z].[0-9]+|\/[a-z].[0-9]+|\&id|%26id)?(?:%2F|\/|=|%3D)[0-9]+)(?:%2F?|\\?)\&',
      caseSensitive: false,
    );
    _regExpMatch = regExp.firstMatch(widget.embeddedCoede);

    if (_regExpMatch != null) {
      String fbUrl = _regExpMatch!.group(1)!;
      _htmlPage = 'https://www.facebook.com/plugins/post.php?href=' + fbUrl;
      print(_htmlPage);
      RegExp widthRegExp = RegExp(
        r'width="(.[0-9]*)"',
        caseSensitive: false,
      );
      RegExp heightRegExp = RegExp(
        r'height="(.[0-9]*)"',
        caseSensitive: false,
      );
      double w =
          double.parse(widthRegExp.firstMatch(widget.embeddedCoede)!.group(1)!);
      double h = double.parse(
          heightRegExp.firstMatch(widget.embeddedCoede)!.group(1)!);
      _ratio = w / h;
    }
    super.initState();
  }

  // refer to the link(https://github.com/flutter/flutter/issues/2897)
  // webview will cause the device to crash in some physical android device,
  // when the webview height is higher than the physical device screen height.
  // --------------------------------------------------
  // width : device screen width - 32(padding)
  // height : device screen height
  // ratio : webview aspect ratio
  // width / ratio : webview height
  bool _isHigherThanScreenHeight(double width, double height, double ratio) {
    double webviewHeight = width / ratio;
    return webviewHeight > height;
  }

  double _getIframeHeight(double width, double height, double ratio) {
    if (Platform.isIOS) {
      return width / ratio;
    }

    return _isHigherThanScreenHeight(width, height, ratio)
        ? height
        : width / ratio;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 32;
    var height = MediaQuery.of(context).size.height;

    return SizedBox(
      width: width,
      height: _getIframeHeight(width, height, _ratio),
      child: Stack(
        children: [
          // display iframe
          SizedBox(
            width: width,
            height: _getIframeHeight(width, height, _ratio),
            child: WebView(
              initialUrl: _htmlPage,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
              },
              //userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (e) async {
                double? w = double.tryParse(
                  await _webViewController.evaluateJavascript(
                      'document.querySelector("._li").getBoundingClientRect().width;'),
                );
                double? h = double.tryParse(
                  await _webViewController.evaluateJavascript(
                      'document.querySelector("._li").getBoundingClientRect().height;'),
                );

                if (w != null && h != null) {
                  double ratio = w / h;
                  if (ratio != _ratio) {
                    if (mounted) {
                      setState(() {
                        _ratio = ratio;
                      });
                    }
                  }
                }
              },
            ),
          ),
          // display watching more widget when meeting some conditions.
          if (_isHigherThanScreenHeight(width, height, _ratio) &&
              Platform.isAndroid)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildWatchingMoreWidget(width),
            ),
          // cover a launching url widget over the iframe
          InkWell(
            onTap: () async {
              if (_regExpMatch != null) {
                var url = _regExpMatch!.group(1)!;
                url = Uri.decodeFull(url);
                print(url);
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              }
            },
            child: Container(
              width: width,
              height: _getIframeHeight(width, height, _ratio),
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
}
