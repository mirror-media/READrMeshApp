import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/bottomCardWidgetController.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
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

class BottomCardWidget extends GetWidget<BottomCardWidgetController> {
  final String controllerTag;
  late final CommentController commentController;
  late final PickableItemController pickableItemController;
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
  }) : super(key: Key(controllerTag.hashCode.toString())) {
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

    Get.create(
      () => BottomCardWidgetController(),
      tag: key.toString(),
      permanent: false,
    );
  }

  @override
  String get tag => key.toString();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      snap: true,
      initialChildSize: 0.13,
      minChildSize: 0.13,
      controller: controller.draggableScrollableController,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Theme.of(context).backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv6!,
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv6!,
                      offset: const Offset(0, -8),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Obx(() {
                  List<Widget> slivers = [];
                  if (controller.isCollapsed.isTrue) {
                    slivers.assign(SliverToBoxAdapter(
                      child: _collapseWidget(context),
                    ));
                  } else {
                    slivers.assignAll([
                      SliverAppBar(
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                        pinned: true,
                        titleSpacing: 0,
                        title: Container(
                          height: kToolbarHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: Theme.of(context).backgroundColor,
                          ),
                          child: Icon(
                            Icons.expand_more_outlined,
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .primaryLv4!,
                            size: 32,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _titleAndPickBar(context),
                      ),
                      _popularCommentList(context),
                      SliverAppBar(
                        title: Container(
                          color: Theme.of(context).backgroundColor,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Obx(
                            () => Text(
                              '${'allComments'.tr} (${commentController.allComments.length})',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        centerTitle: false,
                        pinned: true,
                        automaticallyImplyLeading: false,
                        titleSpacing: 0,
                        elevation: 0.5,
                        primary: false,
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
                visible: controller.isCollapsed.isFalse,
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: const Divider(),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: controller.isCollapsed.isFalse,
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
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Theme.of(context).backgroundColor,
          ),
          margin: const EdgeInsets.only(top: 16),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 1),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).extension<CustomColors>()!.primaryLv5!,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: GestureDetector(
            onTap: () {
              controller.draggableScrollableController.animateTo(1,
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

  Widget _titleAndPickBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: meshBlack10, width: 0.5),
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
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 16),
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
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12),
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
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 12),
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
                  color: Theme.of(context).backgroundColor,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    'popularComments'.tr,
                    style: Theme.of(context).textTheme.headlineSmall,
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'noComment'.tr,
                style: Theme.of(context).textTheme.displaySmall,
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
