import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:readr/controller/storyPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/dateTimeFormat.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/paragraph.dart';
import 'package:readr/models/people.dart';
import 'package:readr/models/story.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/shared/nativeAdWidget.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:readr/pages/story/storySkeletonScreen.dart';
import 'package:readr/pages/story/widgets/imageViewerWidget.dart';
import 'package:readr/pages/story/widgets/mNewsVideoPlayer.dart';
import 'package:readr/pages/story/widgets/relatedStoriesWidget.dart';
import 'package:readr/pages/story/widgets/youtubePlayer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ReadrStoryWidget extends GetView<StoryPageController> {
  final double _textSize = 18;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final NewsListItem news;
  ReadrStoryWidget(this.news);

  @override
  String get tag => news.id;

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '' || input == ' ';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoryPageController>(
      tag: news.id,
      builder: (controller) {
        if (controller.isError) {
          return ErrorPage(
            error: controller.error,
            onPressed: () => controller.fetchNewsData(),
            hideAppbar: false,
          );
        }

        if (!controller.isLoading) {
          Story story = controller.readrStory;

          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  StoryAppBar(news),
                  Expanded(
                    child: _storyContent(context, story),
                  ),
                ],
              ),
              BottomCardWidget(
                controllerTag: controller.newsStoryItem.controllerTag,
                title: controller.newsStoryItem.title,
                publisher: controller.newsStoryItem.source,
                id: controller.newsStoryItem.id,
                objective: PickObjective.story,
                allComments: controller.newsStoryItem.allComments,
                popularComments: controller.newsStoryItem.popularComments,
              ),
            ],
          );
        }

        // state is Init, loading, or other
        return StorySkeletonScreen(news);
      },
    );
  }

  Widget _storyContent(BuildContext context, Story story) {
    List contentList = [
      _buildHeroWidget(context, story),
      const SizedBox(height: 24),
      _buildCategory(context, story),
      const SizedBox(height: 4),
      _buildStoryTitle(context, story.name!),
      const SizedBox(height: 12),
      _buildPublishedDate(context, story),
      const SizedBox(height: 4),
      _buildAuthors(context, story),
      const SizedBox(height: 24),
      _buildSummary(context, story),
      _buildContent(context, story),
      const SizedBox(height: 32),
      _buildAnnotationBlock(context, story),
      const SizedBox(height: 48),
      _buildCitation(context, story),
      const SizedBox(height: 32),
      NativeAdWidget(
        adUnitIdKey: 'READr_AT3',
        factoryId: 'outline',
        adHeight: context.width * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).extension<CustomColors>()?.primaryLv6,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(
            color: Theme.of(context).extension<CustomColors>()!.primaryLv6!,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        keepAlive: true,
      ),
      const SizedBox(height: 32),
      RelatedStoriesWidget(controller.newsStoryItem.relatedStories),
      _buildContact(context),
    ];
    return ScrollablePositionedList.builder(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemScrollController: _itemScrollController,
      itemBuilder: (context, index) => contentList[index],
      itemCount: contentList.length,
    );
  }

  Widget _buildHeroWidget(BuildContext context, Story story) {
    double width = context.width;
    double height = width / 2;

    return Column(
      children: [
        if (story.heroVideo != null) _buildVideoWidget(story.heroVideo!),
        if (!_isNullOrEmpty(story.heroImage) && story.heroVideo == null)
          GestureDetector(
            onTap: () {
              Get.to(() => ImageViewerWidget(
                    imageUrlList: story.imageUrlList,
                    openImageUrl: story.heroImage!,
                  ));
            },
            child: CachedNetworkImage(
              width: width,
              height: height,
              imageUrl: story.heroImage!,
              placeholder: (context, url) => Container(
                height: height,
                width: width,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(),
              fit: BoxFit.cover,
            ),
          ),
        if (!_isNullOrEmpty(story.heroCaption))
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
            alignment: Alignment.centerLeft,
            child: Text(
              story.heroCaption!,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
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

  Widget _buildCategory(BuildContext context, Story story) {
    if (story.categoryList!.isEmpty) return Container();

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      height: 25,
      width: context.width - 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        itemBuilder: (BuildContext context, int index) {
          return Text(
            story.categoryList![index].name,
            style: Theme.of(context).textTheme.bodySmall,
          );
        },
        itemCount: story.categoryList!.length,
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 5.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).extension<CustomColors>()!.primaryLv5!,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildPublishedDate(BuildContext context, Story story) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '${'updateTime'.tr}${dateTimeFormat.changeStringToDisplayString(story.publishTime!, 'yyyy-MM-ddTHH:mm:ssZ', 'yyyy/MM/dd HH:mm')}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
      ),
    );
  }

  Widget _buildAuthors(BuildContext context, Story story) {
    List<Widget> authorItems = List.empty(growable: true);
    List<People> peopleList = [];

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

    authorItems.addAll(_addAuthorItems(context, peopleList));

    if (!_isNullOrEmpty(story.otherByline)) {
      if (authorItems.isNotEmpty) {
        authorItems.add(Container(
          width: 2,
          height: 2,
          margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv5!,
          ),
        ));
      }
      authorItems.add(Text(
        story.otherByline!,
        softWrap: true,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
      ));
    }

    if (authorItems.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      width: context.width - 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'journalist'.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  height: 1.39,
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

  List<Widget> _addAuthorItems(BuildContext context, List<People> peopleList) {
    List<Widget> authorNameList = [];

    for (int i = 0; i < peopleList.length; i++) {
      authorNameList.add(Text(
        peopleList[i].name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
      ));
      if (i != peopleList.length - 1) {
        authorNameList.add(Container(
          width: 2,
          height: 2,
          margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv5!,
          ),
        ));
      }
    }
    return authorNameList;
  }

  Widget _buildSummary(BuildContext context, Story story) {
    List<Paragraph> articles = story.summaryApiData!;
    bool noData = false;
    if (articles.isNotEmpty) {
      List<Widget> articleWidgets = List.empty(growable: true);

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
                  child: controller.paragraphFormat.parseTheParagraph(
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
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).extension<CustomColors>()!.primaryLv6!,
              width: 1,
            ),
            bottom: BorderSide(
              color: Theme.of(context).extension<CustomColors>()!.primaryLv6!,
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

  Widget _buildContent(BuildContext context, Story story) {
    List<Paragraph> storyContents = story.contentApiData!;
    const Map<int, String> adUnitIdMap = {
      0: 'READr_AT1',
      4: 'READr_AT2',
    };

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
            if (index == 0 || index == 4) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: controller.paragraphFormat.parseTheParagraph(
                      paragraph,
                      context,
                      _textSize,
                      showAnnotations: true,
                      annotationLength: story.contentAnnotationData!.length,
                      itemScrollController: _itemScrollController,
                    ),
                  ),
                  NativeAdWidget(
                    adUnitIdKey: adUnitIdMap[index]!,
                    factoryId: 'outline',
                    adHeight: context.width * 0.75,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv6!,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      border: Border.all(
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv6!,
                      ),
                    ),
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  ),
                ],
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: controller.paragraphFormat.parseTheParagraph(
                paragraph,
                context,
                _textSize,
                showAnnotations: true,
                annotationLength: story.contentAnnotationData!.length,
                itemScrollController: _itemScrollController,
              ),
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget _buildAnnotationBlock(BuildContext context, Story story) {
    double width = context.width;
    String textColor = Theme.of(context).brightness == Brightness.light
        ? '#DE000928'
        : '#F6F6FB ';
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
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv1!,
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
                            'text-decoration-color': textColor,
                            'color': textColor,
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
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv1!,
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

  Widget _buildCitation(BuildContext context, Story story) {
    List<Paragraph> articles = story.citationApiData!;
    if (articles.isNotEmpty) {
      List<Widget> articleWidgets = List.empty(growable: true);

      if (articles[0].contents!.isNotEmpty &&
          !_isNullOrEmpty(articles[0].contents![0].data)) {
        articleWidgets.add(Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
                width: 8,
              ),
            ),
          ),
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            'referenceData'.tr,
            style: Theme.of(context).textTheme.headlineSmall,
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
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: padding,
                          child: controller.paragraphFormat.parseTheParagraph(
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
                  child: controller.paragraphFormat.parseTheParagraph(
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
          color: Theme.of(context).scaffoldBackgroundColor,
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

  Widget _buildContact(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'readrContactEmail'.tr,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontSize: 13),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () async {
                      final Uri params = Uri(
                        scheme: 'mailto',
                        path: 'readr@readr.tw',
                      );

                      if (await canLaunchUrl(params)) {
                        await launchUrl(params);
                      } else {
                        print('Could not launch ${params.toString()}');
                      }
                    },
                    child: Text(
                      'readr@readr.tw',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primaryLv1,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primaryLv3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'readrCustomerServiceNumber'.tr,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontSize: 13),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () async {
                      String url = 'tel://0266333890';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        print('Could not launch $url');
                      }
                    },
                    child: Text(
                      '（02）6633-3890',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primaryLv1,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primaryLv3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
