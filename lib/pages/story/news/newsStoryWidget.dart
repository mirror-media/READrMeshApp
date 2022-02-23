import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/paragraphFormat.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/models/paragraph.dart';
import 'package:readr/models/paragrpahList.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/pages/story/news/bottomCardWidget.dart';
import 'package:readr/pages/story/widgets/parseTheTextToHtmlWidget.dart';
import 'package:readr/services/pickService.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

class NewsStoryWidget extends StatefulWidget {
  final NewsListItem news;
  final Member member;
  const NewsStoryWidget({
    required this.news,
    required this.member,
  });

  @override
  _NewsStoryWidgetState createState() => _NewsStoryWidgetState();
}

class _NewsStoryWidgetState extends State<NewsStoryWidget> {
  bool _isLoading = true;
  late NewsStoryItem _newsStoryItem;
  late Member _member;
  String _inputText = '';
  final PickService _pickService = PickService();
  bool _isPicked = false;
  bool _isSlideDown = false;
  bool _isBookmarked = false;
  bool _isSending = false;
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
    _member = widget.member;
  }

  _fetchNewsData() async {
    context.read<NewsCubit>().fetchNewsData(
          newsId: widget.news.id,
          member: widget.member,
          isNative: true,
        );
  }

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '' || input == ' ';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
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
          _isLoading = false;

          return SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    _appBar(context),
                    Expanded(
                      child: _buildContent(context),
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
              ],
            ),
          );
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              _appBar(context),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            ],
          ),
        );
      },
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
        if (!_isLoading) ...[
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
                      PickToast.showBookmarkToast(
                          context, pickId != null, true);
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
        ],
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

  Widget _buildContent(BuildContext context) {
    List<Widget> contentWidgets = [
      _buildHeroWidget(),
      const SizedBox(height: 24),
      _buildPublisher(),
      const SizedBox(height: 4),
      _buildTitle(),
      const SizedBox(height: 12),
      _buildPublishDate(),
      const SizedBox(height: 4),
      _buildAuthor(),
      const SizedBox(height: 24),
      _buildStoryContent(),
      const SizedBox(height: 32),
      _buildAnnotationBlock(),
      const SizedBox(height: 160),
    ];
    return ScrollablePositionedList.builder(
      itemCount: contentWidgets.length,
      itemBuilder: (context, index) {
        return contentWidgets[index];
      },
      itemScrollController: _itemScrollController,
    );
  }

  Widget _buildHeroWidget() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 16 * 9;

    if (widget.news.heroImageUrl == null) {
      return Container();
    }

    return CachedNetworkImage(
      width: width,
      imageUrl: widget.news.heroImageUrl!,
      placeholder: (context, url) => Container(
        height: height,
        width: width,
        color: Colors.grey,
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width,
        color: Colors.grey,
        child: const Icon(Icons.error),
      ),
      fit: BoxFit.cover,
    );
  }

  Widget _buildPublisher() {
    if (widget.news.source == null) {
      return Container();
    }
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          widget.news.source!.title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _newsStoryItem.title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPublishDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '更新時間：' +
            DateFormat('yyyy/MM/dd HH:mm').format(widget.news.publishedDate),
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildAuthor() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '記者：',
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    return HtmlWidget(
      _newsStoryItem.contentApiData!,
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {
            'text-decoration-color': 'black',
            'color': 'black',
            'text-decoration-thickness': '100%',
          };
        } else if (element.localName == 'h1') {
          return {
            'line-height': '140%',
            'font-weight': '600',
            'font-size': '20px',
            'padding': '32px 20px 16px 20px',
          };
        } else if (element.localName == 'h2') {
          return {
            'line-height': '140%',
            'font-weight': '600',
            'font-size': '20px',
            'padding': '32px 20px 16px 20px',
          };
        } else if (element.localName == 'div') {
          return {
            'padding': '12px 0px 12px 0px',
          };
        }
        return {
          'padding': '0px 20px 0px 20px',
        };
      },
      textStyle: const TextStyle(
        fontSize: 18,
        height: 2,
        color: Colors.black87,
      ),
    );
    // ParagraphList storyContents = _newsStoryItem.contentApiData!;
    // ParagraphFormat paragraphFormat = ParagraphFormat();
    // return Padding(
    //   padding: const EdgeInsets.all(0),
    //   child: ListView.builder(
    //     shrinkWrap: true,
    //     physics: const NeverScrollableScrollPhysics(),
    //     itemCount: storyContents.length,
    //     itemBuilder: (context, index) {
    //       Paragraph paragraph = storyContents[index];
    //       if (paragraph.contents != null &&
    //           paragraph.contents!.isNotEmpty &&
    //           !_isNullOrEmpty(paragraph.contents![0].data)) {
    //         return Padding(
    //           padding: const EdgeInsets.only(bottom: 16.0),
    //           child: paragraphFormat.parseTheParagraph(
    //             paragraph,
    //             context,
    //             18,
    //             showAnnotations: true,
    //             itemScrollController: _itemScrollController,
    //             annotationLength: _newsStoryItem.contentAnnotationData!.length,
    //           ),
    //         );
    //       }

    //       return Container();
    //     },
    //   ),
    // );
  }

  Widget _buildAnnotationBlock() {
    double width = MediaQuery.of(context).size.width;
    if (_newsStoryItem.contentAnnotationData != null) {
      List<String> annotationDataList = _newsStoryItem.contentAnnotationData!;

      if (annotationDataList.isEmpty) {
        return Container();
      }
      return ListView.separated(
          itemCount: annotationDataList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (index + 1).toString(),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  SizedBox(
                    width: width - 44 - 20,
                    child: HtmlWidget(
                      annotationDataList[index],
                      customStylesBuilder: (element) {
                        if (element.localName == 'a') {
                          return {
                            'text-decoration-color': '#ebf02c',
                            'color': 'black',
                            'text-decoration-thickness': '100%',
                          };
                        } else if (element.localName == 'h1') {
                          return {
                            'line-height': '130%',
                            'font-weight': '600',
                            'font-size': '22px',
                          };
                        } else if (element.localName == 'h2') {
                          return {
                            'line-height': '150%',
                            'font-weight': '500',
                            'font-size': '18px',
                          };
                        }
                        return null;
                      },
                      textStyle: const TextStyle(
                        fontSize: 14,
                        height: 1,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    }
    return Container();
  }
}
