import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/story/news/bottomCardWidget.dart';
import 'package:readr/pages/story/news/storyAppBar.dart';

class NewsStoryWidget extends StatefulWidget {
  final NewsListItem news;
  const NewsStoryWidget({
    required this.news,
  });

  @override
  _NewsStoryWidgetState createState() => _NewsStoryWidgetState();
}

class _NewsStoryWidgetState extends State<NewsStoryWidget> {
  late NewsStoryItem _newsStoryItem;
  String _inputText = '';
  bool _isPicked = false;
  bool _isSlideDown = false;
  final ScrollController _scrollController = ScrollController();
  double _oldOffset = 0;

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
    _scrollController.addListener(() {
      if (_scrollController.offset > _oldOffset) {
        setState(() {
          _isSlideDown = true;
        });
      } else {
        setState(() {
          _isSlideDown = false;
        });
      }
      _oldOffset = _scrollController.offset;
    });
  }

  _fetchNewsData() async {
    context.read<NewsCubit>().fetchNewsData(
          newsId: widget.news.id,
          isNative: true,
        );
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
          if (_newsStoryItem.myPickId != null) {
            _isPicked = true;
          }

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
                      child: _buildContent(context),
                    ),
                  ],
                ),
                if (!_isSlideDown)
                  BottomCardWidget(
                    news: _newsStoryItem,
                    onTextChanged: (value) => _inputText = value,
                    isPicked: _isPicked,
                  ),
              ],
            ),
          );
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              StoryAppBar(
                newsStoryItem: null,
                inputText: _inputText,
                url: widget.news.url,
              ),
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

  Widget _buildContent(BuildContext context) {
    return ListView(
      children: [
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
      ],
      controller: _scrollController,
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
    if (_newsStoryItem.writer == null || _newsStoryItem.writer!.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '記者：' + _newsStoryItem.writer!,
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
