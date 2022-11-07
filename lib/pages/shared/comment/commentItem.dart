import 'dart:async';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/comment/editCommentMenu.dart';
import 'package:readr/pages/shared/comment/reportCommentMenu.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:readr/services/commentService.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  String? get tag => comment.id;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommentItemController>(tag: comment.id)) {
      Get.put(
        CommentItemController(commentRepos: CommentService(), comment: comment),
        tag: comment.id,
      );
    }
    bool isVisible = false;

    return GestureDetector(
      onLongPress: () async {
        if (comment.member.memberId ==
                Get.find<UserService>().currentUser.memberId &&
            controller.isSending.isFalse) {
          await showEditCommentMenu(
            context,
            controller.comment,
            pickableItemControllerTag,
          );
        } else {
          await reportCommentMenu(context, comment);
        }
      },
      child: Obx(
        () {
          if (controller.isMyNewComment.isTrue) {
            Timer(const Duration(seconds: 5), () async {
              if (isVisible) {
                _fadeController.fadeIn();
              }

              await Future.delayed(const Duration(milliseconds: 255));
              if (Get.isRegistered<CommentItemController>(tag: comment.id)) {
                controller.isMyNewComment(false);
                controller.isExpanded(false);
              }
            });
            return VisibilityDetector(
                key: Key(comment.id),
                onVisibilityChanged: (visibilityInfo) {
                  var visiblePercentage = visibilityInfo.visibleFraction * 100;
                  if (visiblePercentage > 80) {
                    isVisible = true;
                  }
                },
                child: Container(
                  color: Theme.of(context)
                      .extension<CustomColors>()
                      ?.highlightBlue,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: FadeIn(
                          controller: _fadeController,
                          child: Container(
                            color: Theme.of(context).backgroundColor,
                          ),
                        ),
                      ),
                      _commentItemContent(context),
                    ],
                  ),
                ));
          } else {
            return _commentItemContent(context);
          }
        },
      ),
    );
  }

  Widget _commentItemContent(BuildContext context) {
    return Obx(
      () {
        Color backgroundColor = Theme.of(context).backgroundColor;
        if (controller.isSending.isTrue) {
          backgroundColor =
              Theme.of(context).extension<CustomColors>()!.highlightBlue!;
        } else if (controller.isMyNewComment.isTrue) {
          backgroundColor = Colors.transparent;
        }

        bool isFollowingMember =
            Get.find<UserService>().isFollowingMember(comment.member);

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: isFollowingMember
                ? Border(
                    left: BorderSide(
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primary700!,
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
                    _content(context),
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
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 14),
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .extension<CustomColors>()!
                              .primaryLv5!,
                        ),
                      ),
                    Obx(() {
                      if (controller.isSending.isTrue) {
                        return Text(
                          'sendingComment'.tr,
                          softWrap: true,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 12),
                        );
                      }
                      return Timestamp(
                        comment.publishDate,
                        isEdited: controller.isEdited.value,
                        key: Key(comment.id),
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .extension<CustomColors>()!
                                  .primaryLv5!,
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
                              await showEditCommentMenu(
                                context,
                                controller.comment,
                                pickableItemControllerTag,
                              );
                            },
                            child: Text(
                              'editComment'.tr,
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 12),
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
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontSize: 12),
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
                      ? Theme.of(context).extension<CustomColors>()!.red!
                      : Theme.of(context)
                          .extension<CustomColors>()!
                          .primary600!,
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

  Widget _content(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          if (controller.isExpanded.isFalse) {
            controller.isExpanded.value = true;
          }
        },
        child: SizedBox(
          width: double.maxFinite,
          child: ExtendedText(
            controller.commentContent.value,
            maxLines: controller.isExpanded.value ? null : 2,
            style: Theme.of(context).textTheme.displaySmall,
            joinZeroWidthSpace: true,
            overflowWidget: TextOverflowWidget(
              position: TextOverflowPosition.end,
              child: RichText(
                text: TextSpan(
                  text: '.... ',
                  style: Theme.of(context).textTheme.displaySmall,
                  children: [
                    TextSpan(
                      text: 'displayMore'.tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
