import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';

class BlocklistPage extends GetView<SettingPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack87,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'blockList'.tr,
          style: const TextStyle(
            fontSize: 18,
            color: readrBlack,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      backgroundColor: meshGray,
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: readrBlack30,
                  ),
                ),
              );
            }

            return ImplicitlyAnimatedList<Member>(
              items: controller.blockMembers,
              areItemsTheSame: (a, b) => a.memberId == b.memberId,
              itemBuilder: (context, animation, item, index) {
                return SizeFadeTransition(
                  sizeFraction: 0.7,
                  curve: Curves.easeInOut,
                  animation: animation,
                  child: Container(
                    key: Key(item.memberId + index.toString()),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12),
                      ),
                      color: Colors.white,
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
                  color: readrBlack87,
                ),
              ),
              ExtendedText(
                member.nickname,
                maxLines: 1,
                joinZeroWidthSpace: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: readrBlack50,
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
            side: const BorderSide(color: readrBlack87, width: 1),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          ),
          child: Text(
            'unBlock'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: readrBlack87,
            ),
          ),
        ),
      ],
    );
  }
}
