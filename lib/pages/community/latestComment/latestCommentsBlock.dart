import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/latestCommentBlockController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/community/latestComment/latestCommentItem.dart';

class LatestCommentsBlock extends GetView<LatestCommentBlockController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.latestCommentsNewsList.isEmpty) {
          return Container();
        }

        return Container(
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Text(
                  '最新留言',
                  style: TextStyle(
                    fontSize: 18,
                    color: readrBlack87,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }

              return LatestCommentItem(
                controller.latestCommentsNewsList[index - 1],
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 20,
            ),
            itemCount: controller.latestCommentsNewsList.length + 1,
          ),
        );
      },
    );
  }
}
