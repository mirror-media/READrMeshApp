import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/services/collectionPageService.dart';
import 'package:readr/services/collectionService.dart';

class EditCollectionController extends GetxController {
  final CollectionRepos collectionRepos;
  final Collection collection;
  EditCollectionController({
    required this.collectionRepos,
    required this.collection,
  });

  late final RxString title;
  late final RxString heroImageUrl;
  late final TextEditingController titleTextController;

  final isUpdating = false.obs;

  @override
  void onInit() {
    title = collection.title.obs;
    heroImageUrl = collection.ogImageUrl.obs;
    titleTextController = TextEditingController(text: collection.title);
    super.onInit();
  }

  void updateTitleAndOg() async {
    isUpdating.value = true;

    try {
      Collection newCollection = await collectionRepos.updateTitleAndOg(
        collectionId: collection.id,
        heroImageId: collection.ogImageId,
        newTitle: title.value,
        newOgUrl: heroImageUrl.value,
      );

      Get.back();
      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList();
      }
      Get.off(
        () => CollectionPage(
          newCollection,
        ),
        preventDuplicates: false,
        binding: BindingsBuilder(() {
          Get.lazyPut<CollectionPageController>(
            () => CollectionPageController(
              collection: newCollection,
              collectionPageRepos: CollectionPageService(),
            ),
            tag: newCollection.id,
          );
        }),
      );
    } catch (e) {
      print('Update collection title and og error: $e');
      Fluttertoast.showToast(
        msg: "更新失敗 請稍後再試",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      isUpdating.value = false;
    }
  }
}
