import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:readr/pages/story/storySkeletonScreen.dart';

class NewsWebviewWidget extends StatefulWidget {
  final NewsListItem news;
  const NewsWebviewWidget({
    required this.news,
  });

  @override
  _NewsWebviewWidgetState createState() => _NewsWebviewWidgetState();
}

class _NewsWebviewWidgetState extends State<NewsWebviewWidget> {
  bool _isLoading = true;
  late NewsStoryItem _newsStoryItem;
  String _inputText = '';
  bool _isPicked = false;

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
  }

  _fetchNewsData() async {
    context.read<NewsCubit>().fetchNewsData(newsId: widget.news.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsError) {
          final error = state.error;
          print('NewsPageError: ${error.message}');

          return Column(
            children: [
              StoryAppBar(
                newsStoryItem: null,
                inputText: _inputText,
                url: widget.news.url,
              ),
              Expanded(
                child: ErrorPage(
                  error: error,
                  onPressed: () => _fetchNewsData(),
                  hideAppbar: true,
                ),
              ),
            ],
          );
        }

        if (state is NewsLoaded) {
          _newsStoryItem = state.newsStoryItem;
          if (_newsStoryItem.myPickId != null) {
            _isPicked = true;
          }
          return _webViewWidget(context);
        }

        return StorySkeletonScreen(widget.news.url);
      },
    );
  }

  Widget _webViewWidget(BuildContext context) {
    String url = widget.news.url;
    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
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
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              StoryAppBar(
                newsStoryItem: _newsStoryItem,
                inputText: _inputText,
                url: widget.news.url,
              ),
              Expanded(
                child: InAppWebView(
                  initialOptions: options,
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  onLoadStop: (controller, url) async {
                    await Future.delayed(const Duration(milliseconds: 150));
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ),
            ],
          ),
          BottomCardWidget(
            item: NewsStoryItemPick(_newsStoryItem),
            onTextChanged: (value) => _inputText = value,
            isPicked: _isPicked,
          ),
          _isLoading ? StorySkeletonScreen(widget.news.url) : Container(),
        ],
      ),
    );
  }
}
