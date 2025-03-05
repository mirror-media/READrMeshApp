import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/shared/timestamp.dart';

class CommentsWidget extends StatelessWidget {
  final Comment comment;

  const CommentsWidget({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
      color: Theme.of(context).backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => PersonalFilePage(viewMember: comment.member));
            },
            child: ProfilePhotoWidget(
              comment.member,
              22,
              textSize: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => PersonalFilePage(
                                viewMember: comment.member,
                              ));
                        },
                        child: ExtendedText(
                          comment.member.nickname,
                          maxLines: 1,
                          joinZeroWidthSpace: true,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 14),
                          strutStyle: const StrutStyle(
                            forceStrutHeight: true,
                            leading: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 2,
                      margin: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    comment.publishDate != null
                        ? Timestamp(
                            comment.publishDate!,
                            key: ObjectKey(comment),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8.5, bottom: 20),
                  width: double.maxFinite,
                  child: ExtendedText(
                    comment.content,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.displaySmall,
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                      leading: 0.5,
                    ),
                    joinZeroWidthSpace: true,
                    overflowWidget: TextOverflowWidget(
                      position: TextOverflowPosition.end,
                      child: RichText(
                        strutStyle: const StrutStyle(
                          forceStrutHeight: true,
                          leading: 0.5,
                        ),
                        text: TextSpan(
                          text: '... ',
                          style: Theme.of(context).textTheme.displaySmall,
                          children: [
                            TextSpan(
                              text: 'showFullComment'.tr,
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ],
                        ),
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
