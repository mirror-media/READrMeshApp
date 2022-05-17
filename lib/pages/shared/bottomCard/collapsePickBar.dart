import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';

class CollapsePickBar extends StatelessWidget {
  final String contorllerTag;
  const CollapsePickBar(this.contorllerTag, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PickableItemController>(tag: contorllerTag);
    return Row(
      children: [
        Obx(
          () => AutoSizeText.rich(
            TextSpan(
              text: controller.commentCount.toString(),
              style: const TextStyle(
                color: readrBlack87,
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(
                  text: ' 則留言',
                  style: TextStyle(
                    color: readrBlack50,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
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
        Obx(
          () => AutoSizeText.rich(
            TextSpan(
              text: controller.pickCount.toString(),
              style: const TextStyle(
                color: readrBlack87,
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(
                  text: ' 人精選',
                  style: TextStyle(
                    color: readrBlack50,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const Spacer(),
        PickButton(
          contorllerTag,
        ),
      ],
    );
  }
}
