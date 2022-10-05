import 'dart:io';

import 'package:flutter/material.dart';
import 'package:readr/helpers/themes.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _isLoading = true;
  late WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
          color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        WebView(
          initialUrl: 'https://www.readr.tw/about',
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          onWebViewCreated: (webViewController) =>
              controller = webViewController,
          onPageFinished: (url) async {
            controller.runJavascript(
                "document.getElementsByTagName('header')[0].style.display = 'none';");
            controller.runJavascript(
                "document.getElementsByTagName('footer')[0].style.display = 'none';");
            controller.runJavascript(
                "document.getElementsByTagName('footer')[1].style.display = 'none';");
            controller.runJavascript(
                "document.getElementsByTagName('readr-footer')[0].style.display = 'none';");
            controller.runJavascript(
                "document.getElementsByClassName('the-gdpr')[0].style.display = 'none';");
            await Future.delayed(const Duration(milliseconds: 150));
            setState(() {
              _isLoading = false;
            });
          },
        ),
        _isLoading
            ? Container(
                color: Theme.of(context).backgroundColor,
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            : Container(),
      ],
    );
  }
}
