import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:readr/helpers/dataConstants.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _isLoading = true;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        disableContextMenu: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
        allowsLinkPreview: false,
        disableLongPressContextMenuOnLinks: true,
      ));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      shadowColor: Colors.white70,
      leading: IconButton(
        icon: Icon(
          Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
          color: Colors.black,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialOptions: options,
          initialUrlRequest:
              URLRequest(url: Uri.parse("https://www.readr.tw/about")),
          onLoadStop: (controller, url) async {
            controller.evaluateJavascript(
                source:
                    "document.getElementsByTagName('header')[0].style.display = 'none';");
            controller.evaluateJavascript(
                source:
                    "document.getElementsByTagName('footer')[0].style.display = 'none';");
            controller.evaluateJavascript(
                source:
                    "document.getElementsByTagName('footer')[1].style.display = 'none';");
            controller.evaluateJavascript(
                source:
                    "document.getElementsByTagName('readr-footer')[0].style.display = 'none';");
            await Future.delayed(const Duration(milliseconds: 1));
            setState(() {
              _isLoading = false;
            });
          },
        ),
        _isLoading
            ? Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: hightLightColor,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
