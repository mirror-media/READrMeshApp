import 'package:flutter/material.dart';
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
import 'package:readr/pages/shared/meshToast.dart';
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
      showMeshToast(
        icon: const Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.white,
        ),
        message: '成功加入集錦',
      );

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
}
