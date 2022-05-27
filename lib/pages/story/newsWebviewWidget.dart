import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:readr/controller/storyPageController.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:readr/pages/story/storySkeletonScreen.dart';

class NewsWebviewWidget extends GetView<StoryPageController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoryPageController>(
      builder: (controller) {
        if (controller.isError) {
          return ErrorPage(
            error: controller.error,
            onPressed: () => controller.fetchNewsData(),
            hideAppbar: false,
          );
        }

        if (!controller.isLoading) {
          return _webViewWidget(context);
        }

        return StorySkeletonScreen();
      },
    );
  }

  Widget _webViewWidget(BuildContext context) {
    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          mediaPlaybackRequiresUserGesture: false,
          disableContextMenu: true,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
          allowsLinkPreview: false,
          disableLongPressContextMenuOnLinks: true,
        ));
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            StoryAppBar(),
            Expanded(
              child: InAppWebView(
                initialOptions: options,
                initialUrlRequest:
                    URLRequest(url: Uri.parse(controller.newsListItem.url)),
                onLoadStart: (inAppWerViewController, uri) async {
                  await Future.delayed(const Duration(seconds: 2));
                  if (Get.isRegistered<StoryPageController>()) {
                    controller.webviewLoading.value = false;
                  }
                },
                onLoadStop: (inAppWerViewController, uri) {
                  if (controller.newsListItem.source.id ==
                      Get.find<EnvironmentService>().config.readrPublisherId) {
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('header')[0].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('footer')[0].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('footer')[1].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('readr-footer')[0].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('the-gdpr')[0].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('frame__donate')[0].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('frame__tag-list-wrapper')[0].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('news-letter')[0].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('frame__related-list-wrapper')[0].style.display = 'none';");
                    inAppWerViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('latest-coverages')[0].style.display = 'none';");
                  }

                  controller.webviewLoading.value = false;
                },
              ),
            ),
            SizedBox(height: Get.height * 0.12),
          ],
        ),
        BottomCardWidget(
          controllerTag: controller.newsStoryItem.controllerTag,
          onTextChanged: (value) => controller.inputText = value,
          title: controller.newsStoryItem.title,
          author: controller.newsStoryItem.source.title,
          id: controller.newsStoryItem.id,
          objective: PickObjective.story,
          allComments: controller.newsStoryItem.allComments,
          popularComments: controller.newsStoryItem.popularComments,
        ),
        Obx(
          () {
            if (controller.webviewLoading.isTrue) {
              return StorySkeletonScreen();
            }

            return Container();
          },
        ),
      ],
    );
  }
}
