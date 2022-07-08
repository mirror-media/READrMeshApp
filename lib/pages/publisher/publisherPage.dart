import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/publisherPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/follow/followButton.dart';
import 'package:readr/pages/shared/newsListItemWidget.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';
import 'package:readr/services/publisherService.dart';

class PublisherPage extends GetView<PublisherPageController> {
  final Publisher publisher;
  const PublisherPage(this.publisher);

  @override
  String get tag => publisher.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        centerTitle: Platform.isIOS,
        backgroundColor: Colors.white,
        title: Text(
          publisher.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: GetBuilder<PublisherPageController>(
        init: PublisherPageController(
          publisher: publisher,
          publisherRepos: PublisherService(),
        ),
        tag: publisher.id,
        builder: (controller) {
          if (controller.isError) {
            return ErrorPage(
              error: controller.error,
              onPressed: () => controller.fetchPublisherNews(),
              hideAppbar: true,
            );
          }

          if (!controller.isLoading) {
            return _buildContent(context);
          }

          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: readrBlack10,
                width: 0.5,
              ),
            ),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 64),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PublisherLogoWidget(publisher, size: 72),
              const SizedBox(
                width: 41.5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(
                    () => RichText(
                      text: TextSpan(
                        text: _convertNumberToString(
                          controller.followerCount.value,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: readrBlack87,
                        ),
                        children: const [
                          TextSpan(
                            text: ' 人追蹤',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: readrBlack50,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FollowButton(
                    PublisherFollowableItem(publisher),
                    textSize: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _latestNewsList(context),
        ),
      ],
    );
  }

  String _convertNumberToString(int number) {
    if (number >= 10000) {
      double newNumber = number / 10000;
      return '${newNumber.toStringAsFixed(newNumber.truncateToDouble() == newNumber ? 0 : 1)}萬';
    } else {
      return number.toString();
    }
  }

  Widget _latestNewsList(BuildContext context) {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        itemBuilder: (context, index) {
          if (index == controller.publisherNewsList.length) {
            if (controller.isNoMore.isTrue) {
              return Container();
            }
            if (controller.isLoadingMore.isFalse) {
              controller.fetchMorePublisherNews();
            }
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
          return NewsListItemWidget(
            controller.publisherNewsList[index],
            showPickTooltip: index == 0,
          );
        },
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 20),
            child: Divider(
              color: readrBlack10,
              thickness: 1,
              height: 1,
            ),
          );
        },
        itemCount: controller.publisherNewsList.length + 1,
      ),
    );
  }
}
