import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:readr/blocs/story/events.dart';
import 'package:readr/blocs/story/bloc.dart';
import 'package:readr/blocs/story/states.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dateTimeFormat.dart';
import 'package:readr/helpers/openProjectHelper.dart';
import 'package:readr/helpers/paragraphFormat.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/paragraph.dart';
import 'package:readr/models/paragrpahList.dart';
import 'package:readr/models/peopleList.dart';
import 'package:readr/models/story.dart';
import 'package:readr/models/storyListItem.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:readr/models/tagList.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:readr/pages/story/storySkeletonScreen.dart';
import 'package:readr/pages/story/widgets/mNewsVideoPlayer.dart';
import 'package:readr/pages/story/widgets/youtubePlayer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class StoryWidget extends StatefulWidget {
  final String id;
  const StoryWidget({
    required this.id,
  });

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  late String _currentId;
  late double _textSize;
  late Story _story;
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    _currentId = widget.id;
    _loadStory(_currentId);
    super.initState();
  }

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '' || input == ' ';
  }

  _loadStory(String id) async {
    context.read<StoryBloc>().add(FetchPublishedStoryById(id));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return BlocBuilder<StoryBloc, StoryState>(
        builder: (BuildContext context, StoryState state) {
      if (state is StoryError) {
        final error = state.error;
        print('NewsCategoriesError: ${error.message}');
        return ErrorPage(
          error: error,
          onPressed: () => _loadStory(_currentId),
          hideAppbar: true,
        );
      }
      if (state is StoryLoaded) {
        Story? story = state.story;
        if (story == null) {
          return Container();
        }
        _story = story;
        _textSize = state.textSize;
        return _storyContent(width, story);
      } else if (state is TextSizeChanged) {
        _textSize = state.textSize;
        return _storyContent(width, _story);
      }

      // state is Init, loading, or other
      return StorySkeletonScreen();
    });
  }

  Widget _storyContent(double width, Story story) {
    List<Widget> contentWidgets = [
      _buildHeroWidget(width, story),
      const SizedBox(height: 24),
      _buildCategory(story),
      const SizedBox(height: 8),
      _buildStoryTitle(story.name!),
      const SizedBox(height: 12),
      _buildPublishedDateAndReadingTime(story),
      const SizedBox(height: 12),
      _buildAuthors(story),
      const SizedBox(height: 24),
      _buildSummary(story),
      _buildContent(story),
      const SizedBox(height: 32),
      _buildAnnotationBlock(story),
      const SizedBox(height: 48),
      _buildCitation(story),
      const SizedBox(height: 48),
      if (story.tags != null && story.tags!.isNotEmpty) ...[
        _buildTags(story.tags),
        const SizedBox(height: 48),
      ],
      if (story.relatedStories!.isNotEmpty) ...[
        _buildRelatedWidget(width, story.relatedStories!),
        const SizedBox(height: 48),
      ],
      _buildRecommendWidget(width, story.recommendedStories!),
      const SizedBox(height: 48),
    ];
    return ScrollablePositionedList.builder(
      itemCount: contentWidgets.length,
      itemBuilder: (context, index) {
        return contentWidgets[index];
      },
      itemScrollController: itemScrollController,
    );
  }

  Widget _buildHeroWidget(double width, Story story) {
    double height = width / 16 * 9;

    return Column(
      children: [
        if (story.heroVideo != null) _buildVideoWidget(story.heroVideo!),
        if (story.heroImage != null && story.heroVideo == null)
          CachedNetworkImage(
            width: width,
            imageUrl: story.heroImage!,
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
          ),
        if (!_isNullOrEmpty(story.heroCaption))
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
            alignment: Alignment.centerLeft,
            child: Text(
              story.heroCaption!,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
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
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Text(
              story.categoryList![index].name,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: hightLightColor,
                  width: 2,
                ),
              ),
            ),
          );
        },
        itemCount: story.categoryList!.length,
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 2.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPublishedDateAndReadingTime(Story story) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            dateTimeFormat.changeStringToDisplayString(
                story.publishTime!, 'yyyy-MM-ddTHH:mm:ssZ', 'MM/dd'),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          if (story.readingTime != null && story.readingTime! > 1.0)
            Text(
              '・閱讀時間 ${story.readingTime!.round().toString()} 分鐘',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthors(Story story) {
    Color labelColor = Colors.black54;
    List<Widget> authorItems = List.empty(growable: true);

    var horizontalLine = Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
      child: Container(
        color: const Color.fromRGBO(0, 9, 40, 0.66),
        width: 20,
        height: 1,
      ),
    );

    if (story.writers!.isNotEmpty) {
      authorItems.add(Row(
        children: [
          Text(
            "記者",
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
          horizontalLine,
          _addAuthorItems(story.writers!),
        ],
      ));
    }

    if (story.photographers!.isNotEmpty) {
      authorItems.add(Row(
        children: [
          Text(
            "攝影",
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
          horizontalLine,
          _addAuthorItems(story.photographers!),
        ],
      ));
    }

    if (story.cameraOperators!.isNotEmpty) {
      authorItems.add(Row(
        children: [
          Text(
            "影音",
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
          horizontalLine,
          _addAuthorItems(story.cameraOperators!)
        ],
      ));
    }

    if (story.designers!.isNotEmpty) {
      authorItems.add(Row(
        children: [
          Text(
            "設計",
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
          horizontalLine,
          _addAuthorItems(story.designers!),
        ],
      ));
    }

    if (story.engineers!.isNotEmpty) {
      authorItems.add(Row(
        children: [
          Text(
            "工程",
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
          horizontalLine,
          _addAuthorItems(story.engineers!),
        ],
      ));
    }

    if (story.dataAnalysts!.isNotEmpty) {
      authorItems.add(Row(
        children: [
          Text(
            "資料分析",
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
          horizontalLine,
          _addAuthorItems(story.dataAnalysts!),
        ],
      ));
    }

    if (!_isNullOrEmpty(story.otherByline)) {
      authorItems.add(Row(
        children: [
          Text(
            "共同製作",
            style: TextStyle(fontSize: 13, color: labelColor),
          ),
          horizontalLine,
          Expanded(
            child: Text(
              story.otherByline!,
              softWrap: true,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      width: MediaQuery.of(context).size.width - 40,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => authorItems[index],
        itemCount: authorItems.length,
      ),
    );
  }

  Widget _addAuthorItems(PeopleList peopleList) {
    List<Widget> authorNameList = [];

    for (int i = 0; i < peopleList.length; i++) {
      authorNameList.add(GestureDetector(
        onTap: () =>
            AutoRouter.of(context).push(AuthorRoute(people: peopleList[i])),
        child: Text(
          peopleList[i].name,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ));
      if (i != peopleList.length - 1) {
        authorNameList.add(Container(
          width: 2,
          height: 2,
          margin: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black26,
          ),
        ));
      }
    }
    return Row(
      children: authorNameList,
    );
  }

  Widget _buildSummary(Story story) {
    ParagraphList articles = story.summaryApiData!;
    bool noData = false;
    if (articles.isNotEmpty) {
      List<Widget> articleWidgets = List.empty(growable: true);
      articleWidgets.add(const Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: Text(
          '報導重點摘要',
          style: TextStyle(color: storyWidgetColor, fontSize: 13),
        ),
      ));
      articleWidgets.add(
        const SizedBox(height: 4),
      );

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
                    15,
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
        padding: const EdgeInsets.fromLTRB(4.0, 20.0, 4.0, 20.0),
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 24.0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: storySummaryFrameColor,
              width: 12,
            ),
            left: BorderSide(
              color: storySummaryFrameColor,
              width: 1,
            ),
            right: BorderSide(
              color: storySummaryFrameColor,
              width: 1,
            ),
            bottom: BorderSide(
              color: storySummaryFrameColor,
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
    int addRecommendIndex = 5;
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
            if (index == addRecommendIndex) {
              addRecommendIndex = addRecommendIndex + 5;
              return Column(
                children: [
                  _buildInlineRecommended(
                      story.relatedStories, addRecommendIndex),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: paragraphFormat.parseTheParagraph(
                      paragraph,
                      context,
                      _textSize,
                      showAnnotations: true,
                      itemScrollController: itemScrollController,
                      annotationLength: story.contentAnnotationData!.length,
                    ),
                  )
                ],
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: paragraphFormat.parseTheParagraph(
                paragraph,
                context,
                _textSize,
                showAnnotations: true,
                itemScrollController: itemScrollController,
                annotationLength: story.contentAnnotationData!.length,
              ),
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget _buildInlineRecommended(
      StoryListItemList? relatedStories, int addIndex) {
    int index = 0;
    if (addIndex != 5) {
      index = addIndex ~/ 5;
    }
    if (relatedStories!.isNotEmpty && index < relatedStories.length) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 24.0, 16.0),
        margin: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 32.0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: storySummaryFrameColor,
              width: 1,
            ),
            left: BorderSide(
              color: storySummaryFrameColor,
              width: 8,
            ),
            right: BorderSide(
              color: storySummaryFrameColor,
              width: 1,
            ),
            bottom: BorderSide(
              color: storySummaryFrameColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '推薦閱讀',
              style: TextStyle(color: storyWidgetColor, fontSize: 13),
            ),
            const SizedBox(
              height: 4,
            ),
            InkWell(
              child: Text(
                relatedStories[index].name,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                  decorationColor: hightLightColor,
                  decorationThickness: 2,
                ),
              ),
              onTap: () async {
                if (!relatedStories[index].isProject) {
                  _currentId = relatedStories[index].id;
                  StoryPage.of(context)!.id = _currentId;
                  _loadStory(_currentId);
                } else {
                  await OpenProjectHelper()
                      .phaseByStoryListItem(relatedStories[index]);
                }
              },
            )
          ],
        ),
      );
    } else {
      return Container();
    }
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
                      color: Colors.black87,
                      fontSize: _textSize - 3,
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
                      textStyle: TextStyle(
                        fontSize: _textSize - 3,
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

  Widget _buildCitation(Story story) {
    ParagraphList articles = story.citationApiData!;
    if (articles.isNotEmpty) {
      List<Widget> articleWidgets = List.empty(growable: true);
      articleWidgets.add(const Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: Text(
          '引用資料',
          style: TextStyle(color: storyWidgetColor, fontSize: 13),
        ),
      ));
      articleWidgets.add(
        const SizedBox(height: 4),
      );

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
              Paragraph previousParagraph;
              if (index != 0) {
                previousParagraph = articles[index - 1];
              } else {
                previousParagraph = articles[0];
              }
              if (paragraph.contents != null &&
                  paragraph.contents!.isNotEmpty &&
                  !_isNullOrEmpty(paragraph.contents![0].data)) {
                EdgeInsetsGeometry padding = const EdgeInsets.only(bottom: 0.0);
                if (paragraph.type == 'unordered-list-item') {
                  if (previousParagraph.type == 'blockquote' ||
                      previousParagraph.type == 'unordered-list-item') {
                    padding = const EdgeInsets.only(bottom: 0.0);
                    return Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 2),
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
                  padding = const EdgeInsets.only(top: 24.0);
                } else if (paragraph.type == 'blockquote') {
                  padding = const EdgeInsets.only(top: 0.0);
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
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(4.0, 20.0, 4.0, 20.0),
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 24.0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: storySummaryFrameColor,
              width: 12,
            ),
            left: BorderSide(
              color: storySummaryFrameColor,
              width: 1,
            ),
            right: BorderSide(
              color: storySummaryFrameColor,
              width: 1,
            ),
            bottom: BorderSide(
              color: storySummaryFrameColor,
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

  Widget _buildTags(TagList? tags) {
    if (tags == null) {
      return Container();
    } else {
      List<Widget> tagWidgets = List.empty(growable: true);
      for (int i = 0; i < tags.length; i++) {
        tagWidgets.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffF6F6FB),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  tags[i].name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color.fromRGBO(0, 9, 40, 0.66)),
                  strutStyle: const StrutStyle(
                      forceStrutHeight: true, fontSize: 18, height: 1),
                ),
              ),
              onTap: () {
                AutoRouter.of(context).push(TagRoute(tag: tags[i]));
              },
            ),
          ),
        );
        if (i != tags.length - 1) {
          tagWidgets.add(const SizedBox(
            width: 4,
          ));
        }
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Wrap(
          children: tagWidgets,
        ),
      );
    }
  }

  Widget _buildRelatedWidget(double width, StoryListItemList relatedStories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 24.0),
          itemCount: relatedStories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '相關報導',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.black12,
                    ),
                  ]);
            }
            return _buildRelatedItem(width, relatedStories[index - 1]);
          }),
    );
  }

  Widget _buildRelatedItem(double width, StoryListItem story) {
    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          story.photoUrl == null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: SvgPicture.asset(defaultImageSvg, fit: BoxFit.cover),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: CachedNetworkImage(
                    width: 90,
                    height: 90,
                    imageUrl: story.photoUrl!,
                    placeholder: (context, url) => Container(
                      color: Colors.grey,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.error),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        height: 1.5,
                      ),
                      text: story.name,
                    ),
                  ),
                ),
                _displayTimeAndReadingTime(story),
              ],
            ),
          ),
        ],
      ),
      onTap: () async {
        if (!story.isProject) {
          _currentId = story.id;
          StoryPage.of(context)!.id = _currentId;
          _loadStory(_currentId);
        } else {
          await OpenProjectHelper().phaseByStoryListItem(story);
        }
      },
    );
  }

  Widget _buildRecommendWidget(double width, StoryListItemList relatedStories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 24.0),
          itemCount: relatedStories.length + 1,
          //padding: const EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '為你推薦',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.black12,
                    ),
                  ]);
            }
            return _buildRecommendItem(width, relatedStories[index - 1]);
          }),
    );
  }

  Widget _buildRecommendItem(double width, StoryListItem story) {
    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          story.photoUrl == null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: SvgPicture.asset(defaultImageSvg, fit: BoxFit.cover),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: CachedNetworkImage(
                    width: 90,
                    height: 90,
                    imageUrl: story.photoUrl!,
                    placeholder: (context, url) => Container(
                      color: Colors.grey,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.error),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        height: 1.5,
                      ),
                      text: story.name,
                    ),
                  ),
                ),
                _displayTimeAndReadingTime(story),
              ],
            ),
          ),
        ],
      ),
      onTap: () async {
        if (!story.isProject) {
          _currentId = story.id;
          StoryPage.of(context)!.id = _currentId;
          _loadStory(_currentId);
        } else {
          await OpenProjectHelper().phaseByStoryListItem(story);
        }
      },
    );
  }

  Widget _displayTimeAndReadingTime(StoryListItem story) {
    TextStyle style = const TextStyle(
      fontSize: 12,
      color: Colors.black54,
    );
    return Container(
      padding: const EdgeInsets.only(top: 4),
      color: editorChoiceBackgroundColor,
      child: Row(
        children: [
          Text(DateFormat('MM/dd').format(story.publishTime), style: style),
          if (story.readingTime != null && story.readingTime! > 1.0)
            Text(
              '・閱讀時間 ${story.readingTime!.toString()} 分鐘',
              style: style,
            ),
        ],
      ),
    );
  }
}
