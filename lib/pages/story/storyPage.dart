import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/storyPageController.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/story/newsStoryWidget.dart';
import 'package:readr/pages/story/newsWebviewWidget.dart';
import 'package:readr/pages/story/readrStoryWidget.dart';
import 'package:readr/services/newsStoryService.dart';
import 'package:readr/services/pickService.dart';
import 'package:readr/services/storyService.dart';

class StoryPage extends GetView<StoryPageController> {
  final NewsListItem news;
  const StoryPage({
    required this.news,
  });

  @override
  String get tag => news.id;

  @override
  Widget build(BuildContext context) {
    Get.put(
      StoryPageController(
        newsStoryRepos: NewsStoryService(),
        storyRepos: StoryServices(),
        pickRepos: PickService(),
        newsListItem: news,
      ),
      tag: news.id,
    );
    Widget child;
    if (!news.fullContent) {
      child = NewsWebviewWidget(news.id);
    } else if (news.source.id ==
        Get.find<EnvironmentService>().config.readrPublisherId) {
      child = ReadrStoryWidget(news.id);
    } else {
      child = NewsStoryWidget(news.id);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: child,
    );
  }
}
