import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/shared/collection/collectionTimestamp.dart';

class CollectionInfo extends GetView<PickableItemController> {
  final Collection collection;
  const CollectionInfo(this.collection, {Key? key}) : super(key: key);

  @override
  String get tag => collection.controllerTag;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        List<Widget> children = [];
        if (controller.commentCount.value > 0) {
          children.add(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.bubble_left,
                size: 11,
                color: Theme.of(context).primaryColorLight,
              ),
              const SizedBox(width: 3),
              Text(
                controller.commentCount.value.toString(),
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  leading: 0.5,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      height: 1.4,
                    ),
              ),
            ],
          ));
          children.add(Container(
            width: 2,
            height: 2,
            margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).dividerColor,
            ),
          ));
        }

        children.add(Obx(
          () => CollectionTimestamp(
            Get.find<PickableItemController>(tag: collection.controllerTag)
                .collectionUpdatetime
                .value,
            key: UniqueKey(),
          ),
        ));

        return SizedBox(
          height: 17,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        );
      },
    );
  }
}
