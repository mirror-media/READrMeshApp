import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/news/news_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/pages/story/news/bottomCardWidget.dart';
import 'package:readr/services/pickService.dart';
import 'package:share_plus/share_plus.dart';

class NewsWebviewWidget extends StatefulWidget {
  final NewsListItem news;
  final Member member;
  final bool isBookmarked;
  const NewsWebviewWidget({
    required this.news,
    required this.member,
    required this.isBookmarked,
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
          return _webViewWidget(context);
        }

        return const Center(
          child: CircularProgressIndicator(),
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
          if (!_isPicked && _isSlideDown) _floatPickButton(),
          if (!_isSlideDown)
            BottomCardWidget(
              news: _newsStoryItem,
              member: _member,
              onTextChanged: (value) => _inputText = value,
              isPickedButton: (value) => _isPicked = value,
              isPicked: _isPicked,
            ),
          _isLoading
              ? Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(),
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
            widget.isBookmarked
                ? Icons.bookmark_outlined
                : Icons.bookmark_border_outlined,
            color: Colors.black,
          ),
          tooltip: widget.isBookmarked ? '移出書籤' : '加入書籤',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.share : Icons.ios_share,
            color: Colors.black,
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

  Widget _floatPickButton() {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.only(right: 20),
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        onPressed: () async {
          // check whether is login
          if (FirebaseAuth.instance.currentUser != null) {
            var result = await PickBottomSheet.showPickBottomSheet(
              context: context,
              member: widget.member,
            );

            String? pickId;

            if (result is bool && result) {
              // refresh UI first
              setState(() {
                _newsStoryItem.myPickId = 'loading';
                _newsStoryItem.pickCount++;
                _isPicked = !_isPicked;
              });
              //send request to api. If content is null, only pick
              pickId = await _pickService.createPick(
                memberId: widget.member.memberId,
                targetId: _newsStoryItem.id,
                objective: PickObjective.story,
                state: PickState.public,
                kind: PickKind.read,
              );
            } else if (result is String) {
              // refresh UI first
              setState(() {
                _newsStoryItem.myPickId = 'loading';
                _newsStoryItem.pickCount++;
                _isPicked = !_isPicked;
              });
              //send request to api. If content is null, only pick
              var pickAndComment = await _pickService.createPickAndComment(
                memberId: widget.member.memberId,
                targetId: _newsStoryItem.id,
                objective: PickObjective.story,
                state: PickState.public,
                kind: PickKind.read,
                commentContent: result,
              );
              pickId = pickAndComment?['pickId'];
            }

            if ((result is bool && result) || (result is String)) {
              // If pickId is null, mean failed
              PickToast.showPickToast(context, pickId != null, true);
              if (pickId != null) {
                // update new myPickId to real id
                _newsStoryItem.myPickId = pickId;
                _newsStoryItem.pickCount++;
              } else {
                // recovery UI when is failed
                _newsStoryItem.myPickId = null;
                setState(() {
                  _newsStoryItem.pickCount--;
                  _isPicked = !_isPicked;
                });
              }
            }
          } else {
            // if user is not login
            Fluttertoast.showToast(
              msg: "請先登入",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
            AutoRouter.of(context).push(const LoginRoute());
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
