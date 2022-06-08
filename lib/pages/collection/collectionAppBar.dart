import 'package:flutter/cupertino.dart';
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
  String get tag => collection.id;

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
        onPressed: () async {
          if (controller.inputText.trim().isNotEmpty) {
            Widget dialogTitle = const Text(
              '確定要刪除留言？',
              style: TextStyle(
                color: readrBlack,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            );
            Widget dialogContent = const Text(
              '系統將不會儲存您剛剛輸入的內容',
              style: TextStyle(
                color: readrBlack,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            );
            List<Widget> dialogActions = [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  '刪除留言',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '繼續輸入',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ];
            if (!GetPlatform.isIOS) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: dialogTitle,
                  content: dialogContent,
                  buttonPadding: const EdgeInsets.only(left: 32, right: 8),
                  actions: dialogActions,
                ),
              );
            } else {
              await showDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: dialogTitle,
                  content: dialogContent,
                  actions: dialogActions,
                ),
              );
            }
          } else {
            Get.back();
          }
        },
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
