import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:readr/blocs/story/events.dart';
import 'package:readr/blocs/story/bloc.dart';
import 'package:readr/blocs/story/states.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dateTimeFormat.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/helpers/paragraphFormat.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/paragraph.dart';
import 'package:readr/models/paragrpahList.dart';
import 'package:readr/models/peopleList.dart';
import 'package:readr/models/story.dart';
import 'package:readr/models/storyListItem.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:readr/models/tagList.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:readr/pages/story/widgets/mNewsVideoPlayer.dart';
import 'package:readr/pages/story/widgets/youtubePlayer.dart';
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

  @override
  void initState() {
    _currentId = widget.id;
    _loadStory(_currentId);
    super.initState();
  }

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '';
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
        if (error is NoInternetException) {
          return error.renderWidget(onPressed: () => _loadStory(_currentId));
        }

        return error.renderWidget();
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
      return _loadingWidget();
    });
  }

  Widget _loadingWidget() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _storyContent(double width, Story story) {
    return ListView(
      children: [
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
        _buildSummary(story.summaryApiData!),
        _buildContent(story.contentApiData!),
        const SizedBox(height: 48),
        if (story.tags != null && story.tags!.isNotEmpty) ...[
          _buildTags(story.tags),
          const SizedBox(height: 48),
        ],
        if (story.relatedStories!.isNotEmpty) ...[
          _buildRelatedWidget(width, story.relatedStories!),
          const SizedBox(height: 16),
        ],
      ],
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
        color: const Color(0xff000928),
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
            "數據分析",
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
          Text(story.otherByline!)
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
      authorNameList.add(Text(
        peopleList[i].name,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
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

  // only display unstyled paragraph type in brief
  Widget _buildSummary(ParagraphList articles) {
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child:
                      paragraphFormat.parseTheParagraph(paragraph, context, 15),
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

  Widget _buildContent(ParagraphList storyContents) {
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
                  paragraph, context, _textSize),
            );
          }

          return Container();
        },
      ),
    );
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
              onTap: () {},
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
              const SizedBox(height: 16.0),
          itemCount: relatedStories.length,
          //padding: const EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '相關報導',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.black12,
                    ),
                    const SizedBox(height: 24),
                    _buildRelatedItem(width, relatedStories[index]),
                  ]);
            }
            return _buildRelatedItem(width, relatedStories[index]);
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
                  height: 69,
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
          await _openProjectBrowser(story);
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

  _openProjectBrowser(StoryListItem story) async {
    final ChromeSafariBrowser browser = ChromeSafariBrowser();
    String projectUrl;
    switch (story.style) {
      case 'embedded':
        projectUrl = readrProjectLink + 'post/${story.id}';
        break;
      case 'report':
        projectUrl = readrProjectLink + '/project/${story.slug}';
        break;
      case 'project3':
        projectUrl = readrProjectLink + '/project/3/${story.slug}';
        break;
      default:
        projectUrl = readrProjectLink;
    }
    await browser.open(
      url: Uri.parse(projectUrl),
      options: ChromeSafariBrowserClassOptions(
        android: AndroidChromeCustomTabsOptions(),
        ios: IOSSafariOptions(barCollapsingEnabled: true),
      ),
    );
  }
}
