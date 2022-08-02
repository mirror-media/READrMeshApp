import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readr/controller/storyPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:readr/pages/story/storySkeletonScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewsStoryWidget extends GetView<StoryPageController> {
  final NewsListItem news;
  const NewsStoryWidget(this.news);

  @override
  String get tag => news.id;

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
          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  StoryAppBar(news),
                  Expanded(
                    child: _buildContent(context),
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

        return StorySkeletonScreen(news);
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
        _buildContact(),
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildHeroWidget() {
    double width = Get.width;
    double height = width / 2;

    if (controller.newsListItem.heroImageUrl == null) {
      return Container();
    }

    return CachedNetworkImage(
      width: width,
      height: height,
      imageUrl: controller.newsListItem.heroImageUrl!,
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
    if (controller.newsListItem.source == null) {
      return Container();
    }
    return GestureDetector(
      onTap: () => Get.to(() => PublisherPage(controller.newsListItem.source!)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          controller.newsListItem.source!.title,
          style: const TextStyle(
            color: readrBlack50,
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
        controller.newsStoryItem.title,
        style: const TextStyle(
          color: readrBlack87,
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
        '更新時間：${DateFormat('yyyy/MM/dd HH:mm').format(controller.newsListItem.publishedDate)}',
        style: const TextStyle(
          color: readrBlack50,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildAuthor() {
    if (controller.newsStoryItem.writer == null ||
        controller.newsStoryItem.writer!.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '記者：${controller.newsStoryItem.writer!}',
        style: const TextStyle(
          color: readrBlack50,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    return HtmlWidget(
      controller.newsStoryItem.content!,
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
        color: readrBlack87,
      ),
    );
  }

  Widget _buildContact() {
    if (controller.newsListItem.source?.title != '鏡週刊') {
      return Container();
    }
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '鏡週刊連絡信箱：',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: readrBlack87,
            ),
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: () async {
                    final Uri params = Uri(
                      scheme: 'mailto',
                      path: 'MM-onlineservice@mirrormedia.mg',
                    );

                    if (await canLaunchUrl(params)) {
                      await launchUrl(params);
                    } else {
                      print('Could not launch ${params.toString()}');
                    }
                  },
                  child: const Text(
                    'MM-onlineservice@mirrormedia.mg',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: readrBlack87,
                      decoration: TextDecoration.underline,
                      decorationColor: readrBlack50,
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
            text: '鏡週刊客服電話：',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: readrBlack87,
            ),
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: () async {
                    String url = 'tel://0266333966';
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url);
                    } else {
                      print('Could not launch $url');
                    }
                  },
                  child: const Text(
                    '（02）6633-3966',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: readrBlack87,
                      decoration: TextDecoration.underline,
                      decorationColor: readrBlack50,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
