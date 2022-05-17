import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';

class PickBar extends StatelessWidget {
  final String contorllerTag;
  final bool isInMyPersonalFile;
  const PickBar(
    this.contorllerTag, {
    this.isInMyPersonalFile = false,
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
          bottom.add(ProfilePhotoStack(pickedMemberList, 14));
          bottom.add(const SizedBox(width: 8));
          bottom.add(RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: pickCountData.toString(),
              style: const TextStyle(
                fontSize: 13,
                color: readrBlack,
                fontWeight: FontWeight.w500,
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
