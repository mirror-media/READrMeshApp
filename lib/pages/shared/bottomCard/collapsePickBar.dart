import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/helpers/themes.dart';
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
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 13),
              children: [
                TextSpan(
                  text: 'commentCount'.tr,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 13),
                ),
                if (controller.commentCount > 1 &&
                    Get.locale?.languageCode == 'en')
                  TextSpan(
                    text: 's',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 13),
                  ),
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).extension<CustomColors>()!.primary300!,
          ),
        ),
        Obx(
          () => AutoSizeText.rich(
            TextSpan(
              text: controller.pickCount.toString(),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 13),
              children: [
                TextSpan(
                  text: 'pickCount'.tr,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 13),
                ),
                if (controller.pickCount > 1 &&
                    Get.locale?.languageCode == 'en')
                  TextSpan(
                    text: 's',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 13),
                  ),
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
