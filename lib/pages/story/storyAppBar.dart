import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/services/pickService.dart';
import 'package:share_plus/share_plus.dart';

class StoryAppBar extends StatefulWidget {
  final NewsStoryItem? newsStoryItem;
  final String inputText;
  final String url;
  const StoryAppBar({
    required this.newsStoryItem,
    required this.inputText,
    required this.url,
  });

  @override
  _StoryAppBarState createState() => _StoryAppBarState();
}

class _StoryAppBarState extends State<StoryAppBar> {
  bool _isBookmarked = false;
  bool _isLoading = true;
  late bool _originIsBookmarked;
  final PickService _pickService = PickService();

  @override
  void initState() {
    super.initState();
    if (widget.newsStoryItem == null) {
      _isLoading = true;
    } else if (widget.newsStoryItem!.bookmarkId != null) {
      _isBookmarked = true;
      _isLoading = false;
    } else {
      _isLoading = false;
    }
    _originIsBookmarked = _isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Text(
        widget.url,
        style: const TextStyle(
          color: readrBlack87,
          fontSize: 13,
        ),
      ),
      actions: <Widget>[
        if (!_isLoading) ...[
          IconButton(
            icon: Icon(
              _isBookmarked
                  ? Icons.bookmark_outlined
                  : Icons.bookmark_border_outlined,
              color: readrBlack87,
              size: 26,
            ),
            tooltip: _isBookmarked ? '移出書籤' : '加入書籤',
            onPressed: () async {
              if (UserHelper.instance.isMember) {
                setState(() {
                  _isBookmarked = !_isBookmarked;
                });
                EasyDebounce.debounce(
                    'UpdateBookmark',
                    const Duration(seconds: 1),
                    () async => await updateBookmark());
              } else {
                AutoRouter.of(context).push(LoginRoute());
              }
            },
          ),
          IconButton(
            icon: Icon(
              Platform.isAndroid
                  ? Icons.share_outlined
                  : Icons.ios_share_outlined,
              color: readrBlack87,
              size: 26,
            ),
            tooltip: '分享',
            onPressed: () {
              Share.share(widget.url);
            },
          ),
        ],
        IconButton(
          icon: const Icon(
            Icons.close_outlined,
            color: readrBlack87,
            size: 26,
          ),
          tooltip: '回前頁',
          onPressed: () async {
            if (widget.inputText.trim().isNotEmpty) {
              Widget dialogTitle = const Text(
                '確定要刪除留言？',
                style: TextStyle(
                  color: readrBlack,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              );
              Widget dialogContent = const Text(
                '系統將不會儲存您剛剛輸入的內容',
                style: TextStyle(
                  color: readrBlack,
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
                await showDialog(
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

  Future<void> updateBookmark() async {
    if (_isBookmarked != _originIsBookmarked) {
      if (!_isBookmarked) {
        bool isDelete =
            await _pickService.deletePick(widget.newsStoryItem!.bookmarkId!);
        PickToast.showBookmarkToast(context, isDelete, false);
        if (!isDelete) {
          setState(() {
            _isBookmarked = _originIsBookmarked;
          });
        } else {
          widget.newsStoryItem!.bookmarkId = null;
          _originIsBookmarked = _isBookmarked;
        }
      } else {
        String? pickId = await _pickService.createPick(
          targetId: widget.newsStoryItem!.id,
          objective: PickObjective.story,
          state: PickState.private,
          kind: PickKind.bookmark,
        );
        PickToast.showBookmarkToast(context, pickId != null, true);
        if (pickId != null) {
          widget.newsStoryItem!.bookmarkId = pickId;
          _originIsBookmarked = _isBookmarked;
        } else {
          setState(() {
            _isBookmarked = _originIsBookmarked;
          });
        }
      }
    }
  }
}
