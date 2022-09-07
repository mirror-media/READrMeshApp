import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/comment/editCommentMenu.dart';
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 9, 40, 0.05),
        border: Border.all(
          color: readrBlack10,
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
          _content(),
        ],
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
          () => Timestamp(
            widget.comment.publishDate,
            textSize: 13,
            isEdited: widget.controller.isEdited.value,
            key: Key(widget.comment.id),
          ),
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
                  style: const TextStyle(
                    color: readrBlack50,
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
                  ? Colors.red
                  : const Color.fromRGBO(0, 9, 40, 0.66),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content() {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) {
          setState(() {
            _isExpanded = true;
          });
        }
      },
      child: _buildComment(),
    );
  }

  Widget _buildComment() {
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
              color:
                  validate.isEmoji(contentChar[0]) ? readrBlack : readrBlack66,
            ),
            children: [
              for (int i = 1; i < contentChar.length; i++)
                TextSpan(
                  text: contentChar[i],
                  style: TextStyle(
                    color: validate.isEmoji(contentChar[i])
                        ? readrBlack
                        : readrBlack66,
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
                style: const TextStyle(
                  color: Color.fromRGBO(0, 9, 40, 0.66),
                ),
                children: [
                  TextSpan(
                    text: 'displayMore'.tr,
                    style: const TextStyle(
                      color: readrBlack50,
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
