import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:readr/blocs/news/news_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/pages/story/news/bottomCardWidget.dart';
import 'package:readr/services/pickService.dart';
import 'package:share_plus/share_plus.dart';

class NewsWebviewWidget extends StatefulWidget {
  final NewsListItem news;
  final Member member;
  const NewsWebviewWidget({
    required this.news,
    required this.member,
  });

  @override
  _NewsWebviewWidgetState createState() => _NewsWebviewWidgetState();
}

class _NewsWebviewWidgetState extends State<NewsWebviewWidget> {
  bool _isLoading = true;
  late NewsStoryItem _newsStoryItem;
  late Member _member;
  String _inputText = '';
  final PickService _pickService = PickService();
  bool _isPicked = false;
  bool _isSlideDown = false;
  int _originY = 0;
  bool _isBookmarked = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
    _member = widget.member;
  }

  _fetchNewsData() async {
    context.read<NewsBloc>().add(FetchNews(widget.news.id, widget.member));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        if (state is NewsError) {
          final error = state.error;
          print('NewsPageError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchNewsData(),
            hideAppbar: true,
          );
        }

        if (state is NewsLoaded) {
          _newsStoryItem = state.newsStoryItem;
          _member = state.member;
          if (_newsStoryItem.myPickId != null) {
            _isPicked = true;
          }

          if (_newsStoryItem.bookmarkId != null && !_isSending) {
            _isBookmarked = true;
          }
          return _webViewWidget(context);
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
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
              _appBar(context),
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
                  onScrollChanged: (controller, x, y) {
                    if (y > _originY) {
                      setState(() {
                        _isSlideDown = true;
                      });
                    } else if (y < _originY) {
                      setState(() {
                        _isSlideDown = false;
                      });
                    }
                    _originY = y;
                  },
                ),
              ),
            ],
          ),
          BottomCardWidget(
            news: _newsStoryItem,
            member: _member,
            onTextChanged: (value) => _inputText = value,
            isPicked: _isPicked,
            isSlideDown: _isSlideDown,
          ),
          _isLoading
              ? Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Text(
        widget.news.url,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            _isBookmarked
                ? Icons.bookmark_outlined
                : Icons.bookmark_border_outlined,
            color: Colors.black,
            size: 26,
          ),
          tooltip: _isBookmarked ? '移出書籤' : '加入書籤',
          onPressed: _isSending
              ? null
              : () async {
                  bool originState = _isBookmarked;
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                    _isSending = true;
                  });
                  if (originState) {
                    bool isDelete = await _pickService
                        .deletePick(_newsStoryItem.bookmarkId!);
                    PickToast.showBookmarkToast(context, isDelete, false);
                    if (!isDelete) {
                      _isBookmarked = originState;
                    } else {
                      _newsStoryItem.bookmarkId = null;
                    }
                  } else {
                    String? pickId = await _pickService.createPick(
                      memberId: widget.member.memberId,
                      targetId: _newsStoryItem.id,
                      objective: PickObjective.story,
                      state: PickState.private,
                      kind: PickKind.bookmark,
                    );
                    PickToast.showBookmarkToast(context, pickId != null, true);
                    if (pickId != null) {
                      _newsStoryItem.bookmarkId = pickId;
                    } else {
                      _isBookmarked = originState;
                    }
                  }
                  setState(() {
                    _isSending = false;
                  });
                },
        ),
        IconButton(
          icon: Icon(
            Platform.isAndroid
                ? Icons.share_outlined
                : Icons.ios_share_outlined,
            color: Colors.black,
            size: 26,
          ),
          tooltip: '分享',
          onPressed: () {
            Share.share(widget.news.url);
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.close_outlined,
            color: Colors.black,
            size: 26,
          ),
          tooltip: '回前頁',
          onPressed: () async {
            if (_inputText.trim().isNotEmpty) {
              Widget dialogTitle = const Text(
                '確定要刪除留言？',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              );
              Widget dialogContent = const Text(
                '系統將不會儲存您剛剛輸入的內容',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              );
              List<Widget> dialogActions = [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '刪除留言',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '繼續輸入',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ];
              if (!Platform.isIOS) {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: dialogTitle,
                    content: dialogContent,
                    buttonPadding: const EdgeInsets.only(left: 32, right: 8),
                    actions: dialogActions,
                  ),
                );
              } else {
                await showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: dialogTitle,
                    content: dialogContent,
                    actions: dialogActions,
                  ),
                );
              }
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
