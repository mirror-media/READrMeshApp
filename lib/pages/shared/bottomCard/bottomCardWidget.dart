import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/bottomCardWidgetController.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/bottomCard/collapsePickBar.dart';
import 'package:readr/pages/shared/comment/commentInputBox.dart';
import 'package:readr/pages/shared/comment/commentItem.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/services/commentService.dart';

class BottomCardWidget extends StatelessWidget {
  final String controllerTag;
  late final CommentController commentController;
  late final PickableItemController pickableItemController;
  late final BottomCardWidgetController bottomCardWidgetController;
  final String title;
  final PickObjective objective;
  final String id;
  final List<Comment> allComments;
  final List<Comment> popularComments;
  final Publisher? publisher;
  final Member? author;

  BottomCardWidget({
    required this.controllerTag,
    required this.title,
    this.author,
    this.publisher,
    required this.objective,
    required this.id,
    required this.allComments,
    required this.popularComments,
    Key? key,
  }) : super(key: key) {
    if (Get.isRegistered<CommentController>(tag: controllerTag)) {
      commentController = Get.find<CommentController>(tag: controllerTag);
    } else {
      commentController = Get.put<CommentController>(
        CommentController(
          commentRepos: CommentService(),
          objective: objective,
          id: id,
          controllerTag: controllerTag,
          allComments: allComments,
          popularComments: popularComments,
        ),
        tag: controllerTag,
      );
    }

    pickableItemController =
        Get.find<PickableItemController>(tag: controllerTag);

    if (Get.isRegistered<BottomCardWidgetController>(tag: controllerTag)) {
      bottomCardWidgetController =
          Get.find<BottomCardWidgetController>(tag: controllerTag);
    } else {
      bottomCardWidgetController = Get.put(
        BottomCardWidgetController(),
        tag: controllerTag,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      snap: true,
      initialChildSize: 0.13,
      minChildSize: 0.13,
      controller: bottomCardWidgetController.draggableScrollableController,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: readrBlack10,
                      offset: Offset(0, -8),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Obx(() {
                  List<Widget> slivers = [];
                  if (bottomCardWidgetController.isCollapsed.isTrue) {
                    slivers.assign(SliverToBoxAdapter(
                      child: _collapseWidget(context),
                    ));
                  } else {
                    slivers.assignAll([
                      SliverAppBar(
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                        pinned: true,
                        elevation: 0,
                        titleSpacing: 0,
                        backgroundColor: Colors.white,
                        title: Container(
                          height: kToolbarHeight,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.expand_more_outlined,
                            color: readrBlack30,
                            size: 32,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _titleAndPickBar(),
                      ),
                      _popularCommentList(context),
                      SliverAppBar(
                        backgroundColor: Colors.white,
                        title: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Obx(
                            () => Text(
                              '所有留言 (${commentController.allComments.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                color: readrBlack87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        centerTitle: false,
                        pinned: true,
                        automaticallyImplyLeading: false,
                        titleSpacing: 0,
                        elevation: 0.5,
                      ),
                      _allCommentList(context),
                    ]);
                  }
                  return CustomScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    slivers: slivers,
                  );
                }),
              ),
            ),
            Obx(
              () => Visibility(
                visible: bottomCardWidgetController.isCollapsed.isFalse,
                child: Container(
                  color: Colors.white,
                  //padding: const EdgeInsets.only(top: 16),
                  child: const Divider(
                    color: readrBlack10,
                    thickness: 0.5,
                    height: 1,
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: bottomCardWidgetController.isCollapsed.isFalse,
                child: CommentInputBox(
                  commentControllerTag: controllerTag,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _collapseWidget(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 4,
          width: 48,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          margin: const EdgeInsets.only(top: 16),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 1),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: readrBlack20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: GestureDetector(
            onTap: () {
              bottomCardWidgetController.draggableScrollableController
                  .animateTo(1,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.linear);
            },
            child: CollapsePickBar(controllerTag),
          ),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }

  Widget _titleAndPickBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: readrBlack10, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => ExtendedText(
              pickableItemController.collectionTitle.value ?? title,
              maxLines: 2,
              joinZeroWidthSpace: true,
              strutStyle: const StrutStyle(
                forceStrutHeight: true,
                leading: 0.5,
              ),
              style: const TextStyle(
                color: readrBlack87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              if (objective == PickObjective.story && publisher != null) {
                Get.to(() => PublisherPage(publisher!));
              } else if (author != null) {
                Get.to(() => PersonalFilePage(viewMember: author!));
              }
            },
            child: objective == PickObjective.story
                ? ExtendedText(
                    publisher?.title ?? '',
                    maxLines: 1,
                    joinZeroWidthSpace: true,
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                      leading: 0.5,
                    ),
                    style: const TextStyle(
                      color: readrBlack50,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : Obx(
                    () {
                      String authorText = '';
                      if (Get.find<UserService>().isMember.isTrue &&
                          author?.memberId ==
                              Get.find<UserService>().currentUser.memberId) {
                        authorText =
                            'by @${Get.find<UserService>().currentUser.customId}';
                      } else if (author != null) {
                        authorText = 'by @${author!.customId}';
                      }
                      return ExtendedText(
                        authorText,
                        maxLines: 1,
                        joinZeroWidthSpace: true,
                        strutStyle: const StrutStyle(
                          forceStrutHeight: true,
                          leading: 0.5,
                        ),
                        style: const TextStyle(
                          color: readrBlack50,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 18),
          PickBar(controllerTag),
        ],
      ),
    );
  }

  Widget _popularCommentList(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () {
          if (commentController.popularComments.isEmpty) {
            return Container();
          }
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: const Text(
                    '熱門留言',
                    style: TextStyle(
                      fontSize: 18,
                      color: readrBlack87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return CommentItem(
                key: ValueKey(commentController.popularComments[index - 1].id),
                comment: commentController.popularComments[index - 1],
                pickableItemControllerTag: controllerTag,
              );
            },
            separatorBuilder: (context, index) {
              if (index == 0) return Container();
              return const Divider(
                color: readrBlack10,
                thickness: 0.5,
                height: 0.5,
                indent: 20,
                endIndent: 20,
              );
            },
            itemCount: commentController.popularComments.length + 1,
          );
        },
      ),
    );
  }

  Widget _allCommentList(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () {
          if (commentController.allComments.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '還沒有人留言，快來搶頭香！',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: readrBlack66,
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) => CommentItem(
              key: ValueKey(commentController.allComments[index].id),
              comment: commentController.allComments[index],
              pickableItemControllerTag: controllerTag,
            ),
            separatorBuilder: (context, index) => const Divider(
              color: readrBlack10,
              thickness: 0.5,
              height: 0.5,
              indent: 20,
              endIndent: 20,
            ),
            itemCount: commentController.allComments.length,
          );
        },
      ),
    );
  }
}
