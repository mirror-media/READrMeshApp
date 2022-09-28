import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/storyPageController.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:readr/pages/story/storySkeletonScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsWebviewWidget extends GetView<StoryPageController> {
  final NewsListItem news;
  const NewsWebviewWidget(this.news);

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

        return _webViewWidget(context);
      },
    );
  }

  Widget _webViewWidget(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            StoryAppBar(news),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: context.height * 0.12),
                child: WebView(
                  initialUrl: controller.newsListItem.url,
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  onWebViewCreated: (newWebViewController) {
                    controller.webViewController = newWebViewController;
                    controller.webViewControllerIsLoaded = true;
                  },
                  onPageFinished: (url) {
                    if (controller.newsListItem.source?.id ==
                        Get.find<EnvironmentService>()
                            .config
                            .readrPublisherId) {
                      controller.webViewController.runJavascript(
                          "document.getElementsByTagName('header')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByTagName('footer')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByTagName('footer')[1].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByTagName('readr-footer')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByClassName('the-gdpr')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByClassName('frame__donate')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByClassName('frame__tag-list-wrapper')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByClassName('news-letter')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByClassName('frame__related-list-wrapper')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByClassName('latest-coverages')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByTagName('readr-header')[0].style.display = 'none';");
                      controller.webViewController.runJavascript(
                          "document.getElementsByTagName('readr-donate-link')[0].style.display = 'none';");
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        GetBuilder<StoryPageController>(
          tag: news.id,
          builder: (controller) {
            if (controller.isLoading) {
              return Container();
            }

            return BottomCardWidget(
              controllerTag: controller.newsStoryItem.controllerTag,
              title: controller.newsStoryItem.title,
              publisher: controller.newsStoryItem.source,
              id: controller.newsStoryItem.id,
              objective: PickObjective.story,
              allComments: controller.newsStoryItem.allComments,
              popularComments: controller.newsStoryItem.popularComments,
            );
          },
        ),
        GetBuilder<StoryPageController>(
          tag: news.id,
          builder: (controller) {
            if (controller.isLoading) {
              return StorySkeletonScreen(news);
            }

            return Container();
          },
        ),
      ],
    );
  }
}
