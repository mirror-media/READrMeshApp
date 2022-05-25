import 'dart:async';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/comment/editCommentMenu.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:readr/services/commentService.dart';

class CommentItem extends GetView<CommentItemController> {
  final Comment comment;
  final bool isExpanded;
  final FadeInController _fadeController = FadeInController();
  final String pickableItemControllerTag;
  CommentItem({
    required this.comment,
    required this.pickableItemControllerTag,
    this.isExpanded = false,
    Key? key,
  }) : super(key: key);

  @override
  String? get tag => 'Comment${comment.id}';

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommentItemController>(tag: 'Comment${comment.id}')) {
      Get.put(
        CommentItemController(commentRepos: CommentService(), comment: comment),
        tag: 'Comment${comment.id}',
      );
    }

    return Obx(
      () {
        if (controller.isMyNewComment.isTrue) {
          Timer(const Duration(seconds: 5), () async {
            _fadeController.fadeIn();
            await Future.delayed(const Duration(milliseconds: 255));
            controller.isMyNewComment(false);
            controller.isExpanded(false);
          });
          return Container(
            color: const Color.fromRGBO(255, 245, 245, 1),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FadeIn(
                    controller: _fadeController,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
                _commentItemContent(context),
              ],
            ),
          );
        } else {
          return _commentItemContent(context);
        }
      },
    );
  }

  Widget _commentItemContent(BuildContext context) {
    return Obx(
      () {
        Color backgroundColor = Colors.white;
        if (controller.isSending.isTrue) {
          backgroundColor = const Color.fromRGBO(255, 245, 245, 1);
        } else if (controller.isMyNewComment.isTrue) {
          backgroundColor = Colors.transparent;
        }

        bool isFollowingMember =
            Get.find<UserService>().isFollowingMember(comment.member);

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: isFollowingMember
                ? const Border(
                    left: BorderSide(
                    color: readrBlack87,
                    width: 4,
                  ))
                : null,
          ),
          padding: isFollowingMember
              ? const EdgeInsets.fromLTRB(16, 20, 20, 20)
              : const EdgeInsets.all(20),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => PersonalFilePage(
                        viewMember: comment.member,
                      ));
                },
                child: ProfilePhotoWidget(
                  comment.member,
                  22,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _nameAndTime(context),
                    const SizedBox(height: 5),
                    _content(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _nameAndTime(BuildContext context) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                var span = TextSpan(
                  text: comment.member.nickname,
                  style: const TextStyle(
                    color: readrBlack87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
                final innerTextSpan = joinChar(
                  span,
                  Accumulator(),
                  zeroWidthSpace,
                );

                final painter = TextPainter(
                  text: innerTextSpan,
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                );

                painter.layout();
                bool isOverflow = painter.size.width > constraints.maxWidth;
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => PersonalFilePage(
                              viewMember: comment.member,
                            ));
                      },
                      child: Text.rich(
                        innerTextSpan,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (!isOverflow)
                      Container(
                        width: 2,
                        height: 2,
                        margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: readrBlack20,
                        ),
                      ),
                    Obx(() {
                      if (controller.isSending.isTrue) {
                        return const Text(
                          '傳送中',
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 12,
                            color: readrBlack50,
                          ),
                        );
                      }
                      return Timestamp(
                        comment.publishDate,
                        isEdited: controller.isEdited.value,
                      );
                    }),
                    Obx(
                      () {
                        if (Get.find<UserService>().isMember.isFalse) {
                          return Container();
                        }

                        if (comment.member.memberId ==
                                Get.find<UserService>().currentUser.memberId &&
                            controller.isSending.isFalse) {
                          return Container(
                            width: 2,
                            height: 2,
                            margin:
                                const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: readrBlack20,
                            ),
                          );
                        }

                        return Container();
                      },
                    ),
                    Obx(
                      () {
                        if (Get.find<UserService>().isMember.isFalse) {
                          return Container();
                        }

                        if (comment.member.memberId ==
                                Get.find<UserService>().currentUser.memberId &&
                            controller.isSending.isFalse) {
                          return GestureDetector(
                            onTap: () async {
                              await EditCommentMenu.showEditCommentMenu(
                                context,
                                controller.comment,
                                pickableItemControllerTag,
                              );
                            },
                            child: const Text(
                              '編輯留言',
                              softWrap: true,
                              style: TextStyle(
                                color: readrBlack50,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        return Container();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          if (controller.isSending.isFalse) ...[
            const SizedBox(width: 12),
            Obx(
              () => Text(
                _convertNumberToString(controller.likeCount.value),
                style: const TextStyle(
                  color: Color.fromRGBO(0, 9, 40, 0.66),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Obx(
              () => IconButton(
                onPressed: () async {
                  if (Get.find<UserService>().isMember.isTrue) {
                    controller.isLiked.toggle();
                    if (controller.isLiked.isTrue) {
                      controller.likeCount.value++;
                    } else {
                      controller.likeCount.value--;
                    }
                  } else {
                    Get.to(
                      () => const LoginPage(
                        fromComment: true,
                      ),
                      fullscreenDialog: true,
                    );
                  }
                },
                iconSize: 18,
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                icon: Icon(
                  controller.isLiked.value
                      ? Icons.favorite_outlined
                      : Icons.favorite_border_outlined,
                  color: controller.isLiked.value
                      ? Colors.red
                      : const Color.fromRGBO(0, 9, 40, 0.66),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _convertNumberToString(int number) {
    if (number <= 0) {
      return '0';
    }

    if (number < 10000) {
      return number.toString();
    }
    double temp = number / 1000;
    return '${temp.floor().toString()}K';
  }

  Widget _content() {
    return Obx(
      () => GestureDetector(
        onTap: () {
          if (controller.isExpanded.isFalse) {
            controller.isExpanded.value = true;
          }
        },
        child: ExtendedText(
          controller.commentContent.value,
          maxLines: controller.isExpanded.value ? null : 2,
          style: const TextStyle(
            color: Color.fromRGBO(0, 9, 40, 0.66),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          joinZeroWidthSpace: true,
          overflowWidget: TextOverflowWidget(
            position: TextOverflowPosition.end,
            child: RichText(
              text: const TextSpan(
                text: '.... ',
                style: TextStyle(
                  color: Color.fromRGBO(0, 9, 40, 0.66),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: '顯示更多',
                    style: TextStyle(
                      color: readrBlack50,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
