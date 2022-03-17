import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dateTimeFormat.dart';
import 'package:readr/helpers/paragraphFormat.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/models/paragraph.dart';
import 'package:readr/models/paragrpahList.dart';
import 'package:readr/models/peopleList.dart';
import 'package:readr/models/story.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:readr/pages/story/storySkeletonScreen.dart';
import 'package:readr/pages/story/widgets/mNewsVideoPlayer.dart';
import 'package:readr/pages/story/widgets/youtubePlayer.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ReadrStoryWidget extends StatefulWidget {
  final NewsListItem news;
  const ReadrStoryWidget({
    required this.news,
  });

  @override
  _ReadrStoryWidgetState createState() => _ReadrStoryWidgetState();
}

class _ReadrStoryWidgetState extends State<ReadrStoryWidget> {
  final double _textSize = 18;
  late NewsStoryItem _newsStoryItem;
  String _inputText = '';
  bool _isPicked = false;
  bool _isSlideDown = false;
  double _oldOffset = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _fetchStory();
    super.initState();
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

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
  }

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '' || input == ' ';
  }

  _fetchStory() async {
    context.read<NewsCubit>().fetchNewsAndReadrData(
          newsId: widget.news.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return BlocBuilder<NewsCubit, NewsState>(
        builder: (BuildContext context, NewsState state) {
      if (state is NewsError) {
        final error = state.error;
        print('READr Story Error: ${error.message}');
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
                onPressed: () => _fetchStory(),
                hideAppbar: true,
              ),
            ),
          ],
        );
      }
      if (state is ReadrStoryLoaded) {
        Story story = state.story;

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
                    child: _storyContent(width, story),
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

      // state is Init, loading, or other
      return StorySkeletonScreen();
    });
  }

  Widget _storyContent(double width, Story story) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      children: [
        _buildHeroWidget(width, story),
        const SizedBox(height: 24),
        _buildCategory(story),
        const SizedBox(height: 4),
        _buildStoryTitle(story.name!),
        const SizedBox(height: 12),
        _buildPublishedDate(story),
        const SizedBox(height: 4),
        _buildAuthors(story),
        const SizedBox(height: 24),
        _buildSummary(story),
        _buildContent(story),
        const SizedBox(height: 32),
        _buildAnnotationBlock(story),
        const SizedBox(height: 48),
        _buildCitation(story),
        const SizedBox(height: 160),
      ],
      controller: _scrollController,
    );
  }

  Widget _buildHeroWidget(double width, Story story) {
    double height = width / 2;

    return Column(
      children: [
        if (story.heroVideo != null) _buildVideoWidget(story.heroVideo!),
        if (!_isNullOrEmpty(story.heroImage) && story.heroVideo == null)
          CachedNetworkImage(
            width: width,
            imageUrl: story.heroImage!,
            placeholder: (context, url) => Container(
              height: height,
              width: width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(),
            fit: BoxFit.cover,
          ),
        if (!_isNullOrEmpty(story.heroCaption))
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
            alignment: Alignment.centerLeft,
            child: Text(
              story.heroCaption!,
              style: const TextStyle(fontSize: 13, color: readrBlack50),
            ),
          ),
      ],
    );
  }

  _buildVideoWidget(String videoUrl) {
    String youtubeString = 'youtube';
    if (videoUrl.contains(youtubeString)) {
      String? ytId = VideoId.parseVideoId(videoUrl) ?? '';
      return YoutubePlayer(ytId);
    }

    return MNewsVideoPlayer(
      videourl: videoUrl,
      aspectRatio: 16 / 9,
    );
  }

  Widget _buildCategory(Story story) {
    if (story.categoryList!.isEmpty) return Container();

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      height: 25,
      width: MediaQuery.of(context).size.width - 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        itemBuilder: (BuildContext context, int index) {
          return Text(
            story.categoryList![index].name,
            style: const TextStyle(
              fontSize: 14,
              color: readrBlack50,
              fontWeight: FontWeight.w400,
            ),
          );
        },
        itemCount: story.categoryList!.length,
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 5.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: readrBlack20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'PingFang TC',
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPublishedDate(Story story) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '更新時間：' +
            dateTimeFormat.changeStringToDisplayString(
                story.publishTime!, 'yyyy-MM-ddTHH:mm:ssZ', 'yyyy/MM/dd HH:mm'),
        style: const TextStyle(
          color: readrBlack50,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildAuthors(Story story) {
    List<Widget> authorItems = List.empty(growable: true);
    PeopleList peopleList = PeopleList();

    if (story.writers!.isNotEmpty) {
      peopleList.addAll(story.writers!);
    }

    if (story.photographers!.isNotEmpty) {
      peopleList.addAll(story.photographers!);
    }

    if (story.cameraOperators!.isNotEmpty) {
      peopleList.addAll(story.cameraOperators!);
    }

    if (story.designers!.isNotEmpty) {
      peopleList.addAll(story.designers!);
    }

    if (story.engineers!.isNotEmpty) {
      peopleList.addAll(story.engineers!);
    }

    if (story.dataAnalysts!.isNotEmpty) {
      peopleList.addAll(story.dataAnalysts!);
    }

    authorItems.addAll(_addAuthorItems(peopleList));

    if (!_isNullOrEmpty(story.otherByline)) {
      if (authorItems.isNotEmpty) {
        authorItems.add(Container(
          width: 2,
          height: 2,
          margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: readrBlack20,
          ),
        ));
      }
      authorItems.add(Text(
        story.otherByline!,
        softWrap: true,
        style: const TextStyle(
          fontSize: 13,
          color: readrBlack50,
          fontWeight: FontWeight.w400,
        ),
      ));
    }

    if (authorItems.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      width: MediaQuery.of(context).size.width - 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '記者：',
            style: TextStyle(
              fontSize: 13,
              color: readrBlack50,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: authorItems,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _addAuthorItems(PeopleList peopleList) {
    List<Widget> authorNameList = [];

    for (int i = 0; i < peopleList.length; i++) {
      authorNameList.add(Text(
        peopleList[i].name,
        style: const TextStyle(
          fontSize: 13,
          color: readrBlack50,
          fontWeight: FontWeight.w400,
        ),
      ));
      if (i != peopleList.length - 1) {
        authorNameList.add(Container(
          width: 2,
          height: 2,
          margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: readrBlack20,
          ),
        ));
      }
    }
    return authorNameList;
  }

  Widget _buildSummary(Story story) {
    ParagraphList articles = story.summaryApiData!;
    bool noData = false;
    if (articles.isNotEmpty) {
      List<Widget> articleWidgets = List.empty(growable: true);

      ParagraphFormat paragraphFormat = ParagraphFormat();

      if (articles[0].contents!.isNotEmpty &&
          !_isNullOrEmpty(articles[0].contents![0].data)) {
        articleWidgets.add(
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              Paragraph paragraph = articles[index];
              if (paragraph.contents != null &&
                  paragraph.contents!.isNotEmpty &&
                  !_isNullOrEmpty(paragraph.contents![0].data)) {
                if (paragraph.contents![0].data == '這篇報導想要告訴你的事：') {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: paragraphFormat.parseTheParagraph(
                    paragraph,
                    context,
                    16,
                  ),
                );
              } else {
                noData = true;
              }

              return Container();
            },
          ),
        );
      } else {
        return Container();
      }

      if (noData) {
        return Container();
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 20.0),
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 32.0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: readrBlack10,
              width: 1,
            ),
            bottom: BorderSide(
              color: readrBlack10,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: articleWidgets,
        ),
      );
    }

    return Container();
  }

  Widget _buildContent(Story story) {
    ParagraphList storyContents = story.contentApiData!;
    ParagraphFormat paragraphFormat = ParagraphFormat();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: storyContents.length,
        itemBuilder: (context, index) {
          Paragraph paragraph = storyContents[index];
          if (paragraph.contents != null &&
              paragraph.contents!.isNotEmpty &&
              !_isNullOrEmpty(paragraph.contents![0].data)) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: paragraphFormat.parseTheParagraph(
                paragraph,
                context,
                _textSize,
                showAnnotations: true,
                annotationLength: story.contentAnnotationData!.length,
              ),
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget _buildAnnotationBlock(Story story) {
    double width = MediaQuery.of(context).size.width;
    if (story.contentAnnotationData != null) {
      List<String> annotationDataList = story.contentAnnotationData!;

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
                    style: TextStyle(
                      color: readrBlack87,
                      fontSize: _textSize - 4,
                      height: 1.5,
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
                            'text-decoration-color': 'black',
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
                      textStyle: TextStyle(
                        fontSize: _textSize - 4,
                        height: 1.5,
                        color: readrBlack87,
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

  Widget _buildCitation(Story story) {
    ParagraphList articles = story.citationApiData!;
    if (articles.isNotEmpty) {
      List<Widget> articleWidgets = List.empty(growable: true);

      ParagraphFormat paragraphFormat = ParagraphFormat();

      if (articles[0].contents!.isNotEmpty &&
          !_isNullOrEmpty(articles[0].contents![0].data)) {
        articleWidgets.add(Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(
                color: readrBlack87,
                width: 8,
              ),
            ),
          ),
          padding: const EdgeInsets.only(left: 24.0),
          child: const Text(
            '引用數據',
            style: TextStyle(
              color: readrBlack87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ));
        articleWidgets.add(
          const SizedBox(height: 4),
        );
        articleWidgets.add(
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              Paragraph paragraph = articles[index];
              Paragraph previousParagraph;
              if (index != 0) {
                previousParagraph = articles[index - 1];
              } else {
                previousParagraph = articles[0];
              }
              if (paragraph.contents != null &&
                  paragraph.contents!.isNotEmpty &&
                  !_isNullOrEmpty(paragraph.contents![0].data)) {
                EdgeInsetsGeometry padding =
                    const EdgeInsets.symmetric(horizontal: 12);
                if (paragraph.type == 'unordered-list-item') {
                  if (previousParagraph.type == 'blockquote' ||
                      previousParagraph.type == 'unordered-list-item') {
                    padding =
                        const EdgeInsets.only(bottom: 0.0, left: 12, right: 12);
                    return Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 32, vertical: 2),
                          child: Divider(
                            color: Color.fromRGBO(0, 9, 40, 0.1),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: padding,
                          child: paragraphFormat.parseTheParagraph(
                            paragraph,
                            context,
                            15,
                            isCitation: true,
                          ),
                        ),
                      ],
                    );
                  }
                  padding =
                      const EdgeInsets.only(top: 24.0, left: 12, right: 12);
                } else if (paragraph.type == 'blockquote') {
                  padding =
                      const EdgeInsets.only(top: 0.0, left: 12, right: 12);
                }
                return Padding(
                  padding: padding,
                  child: paragraphFormat.parseTheParagraph(
                    paragraph,
                    context,
                    15,
                    isCitation: true,
                  ),
                );
              }

              return Container();
            },
          ),
        );

        return Container(
          color: const Color.fromRGBO(0, 9, 40, 0.05),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: articleWidgets,
          ),
        );
      }
    }

    return Container();
  }
}
