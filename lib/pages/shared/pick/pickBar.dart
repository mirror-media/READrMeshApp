import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';

class PickBar extends StatelessWidget {
  final String contorllerTag;
  final bool isInMyPersonalFile;
  final bool showPickTooltip;
  const PickBar(
    this.contorllerTag, {
    this.isInMyPersonalFile = false,
    this.showPickTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PickableItemController>(tag: contorllerTag);
    return Obx(
      () {
        bool isPicked = controller.isPicked.value;
        int pickCountData = controller.pickCount.value;

        List<Member> pickedMemberList = [];
        pickedMemberList.addAll(controller.pickedMembers);

        pickedMemberList.removeWhere((element) =>
            element.memberId == Get.find<UserService>().currentUser.memberId);

        if (isPicked && pickedMemberList.length < 4) {
          pickedMemberList.add(Get.find<UserService>().currentUser);
        }

        List<Widget> bottom = [];
        if (pickCountData <= 0) {
          bottom.add(const Text(
            '尚無人精選',
            style: TextStyle(fontSize: 13, color: readrBlack50),
          ));
        } else {
          bottom.add(ProfilePhotoStack(
            pickedMemberList,
            14,
            key: ObjectKey(pickedMemberList),
          ));
          bottom.add(const SizedBox(width: 8));
          bottom.add(RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: pickCountData.toString(),
              style: TextStyle(
                fontSize: 13,
                color: readrBlack,
                fontWeight:
                    GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
              ),
              children: const [
                TextSpan(
                  text: ' 人精選',
                  style: TextStyle(
                    fontSize: 13,
                    color: readrBlack50,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ));
        }
        bottom.addAll([
          const Spacer(),
          PickButton(
            contorllerTag,
            isInMyPersonalFile: isInMyPersonalFile,
            showPickTooltip: showPickTooltip,
          ),
        ]);

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: bottom,
        );
      },
    );
  }
}
