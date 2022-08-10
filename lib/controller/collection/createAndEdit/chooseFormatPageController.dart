import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createAndEdit/descriptionPageController.dart';
import 'package:readr/controller/collection/createAndEdit/titleAndOgPageController.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/services/collectionService.dart';

class ChooseFormatPageController extends GetxController {
  final CollectionRepos collectionRepos;
  final List<CollectionPick> chooseStoryList;
  final CollectionFormat initFormat;
  ChooseFormatPageController(
    this.collectionRepos,
    this.chooseStoryList,
    this.initFormat,
  );

  final isCreating = false.obs;
  final format = CollectionFormat.folder.obs;

  @override
  void onInit() {
    format.value = initFormat;
    super.onInit();
  }

  void createCollection() async {
    isCreating.value = true;

    try {
      String imageId = await collectionRepos
          .createOgPhoto(
              ogImageUrlOrPath: Get.find<TitleAndOgPageController>()
                  .collectionOgUrlOrPath
                  .value)
          .timeout(
            const Duration(minutes: 1),
          );
      Collection newCollection = await collectionRepos
          .createCollection(
            title: Get.find<TitleAndOgPageController>().collectionTitle.value,
            ogImageId: imageId,
            collectionPicks: chooseStoryList,
            description: Get.find<DescriptionPageController>()
                .collectionDescription
                .value,
          )
          .timeout(
            const Duration(minutes: 1),
          );

      Get.find<PubsubService>().addCollection(
        memberId: Get.find<UserService>().currentUser.memberId,
        collectionId: newCollection.id,
      );

      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList();
      }
      _showResultToast();

      Get.until(
        (route) {
          return route.settings.name == '/AddToCollectionPage';
        },
      );
      Get.back();
    } catch (e) {
      print('Create collection error: $e');
      Fluttertoast.showToast(
        msg: "建立失敗 請稍後再試",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    isCreating.value = false;
  }

  void _showResultToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: const Color.fromRGBO(0, 9, 40, 0.66),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.white,
          ),
          SizedBox(
            width: 6.0,
          ),
          Text(
            '成功加入集錦',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
    showToastWidget(
      toast,
      context: Get.overlayContext,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      position: StyledToastPosition.top,
      startOffset: const Offset(0.0, -3.0),
      reverseEndOffset: const Offset(0.0, -3.0),
      duration: const Duration(seconds: 3),
      //Animation duration   animDuration * 2 <= duration
      animDuration: const Duration(milliseconds: 250),
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
  }
}
