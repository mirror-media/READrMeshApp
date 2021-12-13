import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/blocs/story/bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/services/storyService.dart';
import 'package:readr/pages/story/storyWidget.dart';

class StoryPage extends StatefulWidget {
  final String id;
  final bool useWebview;
  const StoryPage({
    required this.id,
    this.useWebview = false,
  });

  @override
  _StoryPageState createState() => _StoryPageState();

  static _StoryPageState? of(BuildContext context) =>
      context.findAncestorStateOfType<_StoryPageState>();
}

class _StoryPageState extends State<StoryPage> {
  late String _id;
  set id(String value) => _id = value;
  final StoryBloc _bloc = StoryBloc(storyRepos: StoryServices());

  @override
  void initState() {
    _id = widget.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildBar(context),
        backgroundColor: Colors.white,
        body: BlocProvider(
          create: (context) => _bloc,
          child: SafeArea(
            child: widget.useWebview ? _webViewWidget() : StoryWidget(id: _id),
          ),
        ));
  }

  Widget _webViewWidget() {
    String url = Environment().config.readrWebsiteLink + 'post/' + _id;
    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
        ));
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse(url),
      ),
      initialOptions: options,
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
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.share : Icons.ios_share,
            color: Colors.black,
          ),
          tooltip: 'Share',
          onPressed: () {
            String url = Environment().config.readrWebsiteLink + 'post/' + _id;
            Share.share(url);
          },
        ),
      ],
    );
  }
}
