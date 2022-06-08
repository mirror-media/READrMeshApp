import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';

class CollectionAppBar extends GetView<CollectionPageController> {
  final Collection collection;
  const CollectionAppBar(this.collection);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: GetPlatform.isIOS,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: readrBlack,
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        '集錦',
        style: TextStyle(
          fontSize: 18,
          color: readrBlack,
        ),
      ),
      actions: [
        // IconButton(
        //   icon: Icon(
        //     GetPlatform.isAndroid
        //         ? Icons.share_outlined
        //         : Icons.ios_share_outlined,
        //     color: readrBlack87,
        //     size: 26,
        //   ),
        //   tooltip: '分享',
        //   onPressed: () {
        //     Share.share();
        //   },
        // )
        Obx(
          () {
            if (Get.find<UserService>().isMember.isTrue &&
                collection.creator.memberId ==
                    Get.find<UserService>().currentUser.memberId) {
              return const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.more_horiz_outlined,
                  color: readrBlack87,
                  size: 26,
                ),
              );
            }
            return Container();
          },
        )
      ],
    );
  }
}
