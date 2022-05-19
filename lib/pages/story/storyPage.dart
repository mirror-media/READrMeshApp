import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/controller/storyPageController.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/story/newsStoryWidget.dart';
import 'package:readr/pages/story/newsWebviewWidget.dart';
import 'package:readr/pages/story/readrStoryWidget.dart';
import 'package:readr/services/newsStoryService.dart';
import 'package:readr/services/pickService.dart';
import 'package:readr/services/storyService.dart';
import 'package:share_plus/share_plus.dart';

class StoryPage extends GetView<StoryPageController> {
  final NewsListItem news;
  const StoryPage({
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(StoryPageController(
      newsStoryRepos: NewsStoryService(),
      storyRepos: StoryServices(),
      pickRepos: PickService(),
      newsListItem: news,
    ));
    Widget child;
    if (!news.fullContent) {
      child = NewsWebviewWidget();
    } else if (news.source.id ==
        Get.find<EnvironmentService>().config.readrPublisherId) {
      child = ReadrStoryWidget();
    } else {
      child = NewsStoryWidget();
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
