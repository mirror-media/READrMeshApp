import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/comment/editCommentMenu.dart';
import 'package:readr/pages/shared/comment/reportCommentMenu.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:readr/services/commentService.dart';
import 'package:validated/validated.dart' as validate;

class PickCommentItem extends StatefulWidget {
  final Comment comment;
  final bool isExpanded;
  final String pickControllerTag;
  late final CommentItemController controller;

  PickCommentItem({
    required this.comment,
    required this.pickControllerTag,
    this.isExpanded = false,
    Key? key,
  }) : super(key: key) {
    if (Get.isRegistered<CommentItemController>(tag: comment.id)) {
      controller = Get.find<CommentItemController>(tag: comment.id);
    } else {
      controller = Get.put(
        CommentItemController(commentRepos: CommentService(), comment: comment),
        tag: comment.id,
      );
    }
  }

  @override
  State<PickCommentItem> createState() => _PickCommentItemState();
}

class _PickCommentItemState extends State<PickCommentItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        if (Get.find<UserService>().isMember.isTrue &&
            Get.find<UserService>().currentUser.memberId ==
                widget.comment.member.memberId) {
          await showEditCommentMenu(
            context,
            widget.controller.comment,
            widget.pickControllerTag,
            isFromPickTab: true,
          );
        } else {
          await reportCommentMenu(context, widget.comment);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).extension<CustomColors>()!.primary100!,
          border: Border.all(
            color: Theme.of(context).extension<CustomColors>()!.primary200!,
            width: 0.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _time(context),
            const SizedBox(height: 12),
            _content(context),
          ],
        ),
      ),
    );
  }

  Widget _time(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfilePhotoWidget(
          widget.comment.member,
          14,
        ),
        const SizedBox(width: 8),
        Obx(
          () => widget.comment.publishDate != null
              ? Timestamp(
                  widget.comment.publishDate!,
                  textSize: 13,
                  isEdited: widget.controller.isEdited.value,
                  key: Key(widget.comment.id),
                )
              : const SizedBox.shrink(),
        ),
        Obx(
          () {
            if (Get.find<UserService>().isMember.isTrue &&
                Get.find<UserService>().currentUser.memberId ==
                    widget.comment.member.memberId) {
              return Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 0.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary300!,
                ),
              );
            }

            return Container();
          },
        ),
        Obx(
          () {
            if (Get.find<UserService>().isMember.isTrue &&
                Get.find<UserService>().currentUser.memberId ==
                    widget.comment.member.memberId) {
              return GestureDetector(
                onTap: () async {
                  await showEditCommentMenu(
                    context,
                    widget.controller.comment,
                    widget.pickControllerTag,
                    isFromPickTab: true,
                  );
                },
                child: Text(
                  'editComment'.tr,
                  style: TextStyle(
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primary500!,
                    fontSize: 13,
                  ),
                ),
              );
            }

            return Container();
          },
        ),
        const Spacer(),
        Obx(
          () => Text(
            widget.controller.likeCount.toString(),
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.primary600!,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Obx(
          () => IconButton(
            onPressed: () async {
              if (Get.find<UserService>().isMember.isTrue) {
                widget.controller.isLiked.toggle();
                if (widget.controller.isLiked.isTrue) {
                  widget.controller.likeCount.value++;
                } else {
                  widget.controller.likeCount.value--;
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
              widget.controller.isLiked.value
                  ? Icons.favorite_outlined
                  : Icons.favorite_border_outlined,
              color: widget.controller.isLiked.value
                  ? Theme.of(context).extension<CustomColors>()!.red!
                  : Theme.of(context).extension<CustomColors>()!.primary600!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) {
          setState(() {
            _isExpanded = true;
          });
        }
      },
      child: _buildComment(context),
    );
  }

  Widget _buildComment(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Obx(() {
        List<String> contentChar =
            widget.controller.commentContent.value.characters.toList();
        return ExtendedText.rich(
          TextSpan(
            text: contentChar[0],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: validate.isEmoji(contentChar[0])
                  ? Theme.of(context).extension<CustomColors>()!.primary700!
                  : Theme.of(context).extension<CustomColors>()!.primary600!,
            ),
            children: [
              for (int i = 1; i < contentChar.length; i++)
                TextSpan(
                  text: contentChar[i],
                  style: TextStyle(
                    color: validate.isEmoji(contentChar[i])
                        ? Theme.of(context)
                            .extension<CustomColors>()!
                            .primary700!
                        : Theme.of(context)
                            .extension<CustomColors>()!
                            .primary600!,
                  ),
                )
            ],
          ),
          strutStyle: const StrutStyle(
            forceStrutHeight: true,
            leading: 0.1,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.start,
          maxLines: _isExpanded ? null : 3,
          joinZeroWidthSpace: true,
          overflowWidget: TextOverflowWidget(
            position: TextOverflowPosition.end,
            child: RichText(
              strutStyle: const StrutStyle(
                forceStrutHeight: true,
                leading: 0.1,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              text: TextSpan(
                text: '... ',
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary600!,
                ),
                children: [
                  TextSpan(
                    text: 'displayMore'.tr,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary500!,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
