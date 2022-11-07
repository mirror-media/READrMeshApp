import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';

class BlocklistPage extends GetView<SettingPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'blockList'.tr,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: GetBuilder<SettingPageController>(
        initState: (state) {
          controller.fetchBlocklist();
        },
        builder: (controller) {
          if (controller.error != null) {
            return ErrorPage(
              error: controller.error,
              onPressed: () => controller.fetchBlocklist(),
            );
          }

          if (!controller.blocklistPageIsLoading) {
            if (controller.blockMembers.isEmpty) {
              return Center(
                child: Text(
                  'emptyBlockList'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primaryLv4!,
                  ),
                ),
              );
            }

            return Container(
              color: Theme.of(context).backgroundColor,
              child: ImplicitlyAnimatedList<Member>(
                items: controller.blockMembers,
                shrinkWrap: true,
                areItemsTheSame: (a, b) => a.memberId == b.memberId,
                itemBuilder: (context, animation, item, index) {
                  return SizeFadeTransition(
                    sizeFraction: 0.7,
                    curve: Curves.easeInOut,
                    animation: animation,
                    child: Container(
                      key: Key(item.memberId + index.toString()),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0.5,
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .primaryLv6!,
                          ),
                        ),
                        color: Theme.of(context).backgroundColor,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => PersonalFilePage(viewMember: item));
                        },
                        child: _buildListItem(context, item),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Member member) {
    return Row(
      children: [
        ProfilePhotoWidget(member, 22),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.customId,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                ),
              ),
              ExtendedText(
                member.nickname,
                maxLines: 1,
                joinZeroWidthSpace: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary500!,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        OutlinedButton(
          onPressed: () {
            controller.unblockMember(member.memberId);
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
              width: 1,
            ),
            backgroundColor: Theme.of(context).backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          ),
          child: Text(
            'unBlock'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
            ),
          ),
        ),
      ],
    );
  }
}
