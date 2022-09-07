import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/services/collectionService.dart';

class TitleAndOgPageController extends GetxController {
  final collectionTitle = ''.obs;
  final collectionOgUrlOrPath = ''.obs;
  late final TextEditingController titleTextController;
  final String? title;
  final Collection? collection;
  final String imageUrl;
  final isUpdating = false.obs;
  final CollectionRepos collectionRepos;
  TitleAndOgPageController(this.title, this.imageUrl, this.collectionRepos,
      {this.collection});

  @override
  void onInit() {
    collectionTitle.value = title ?? '';
    titleTextController = TextEditingController(text: title);
    collectionOgUrlOrPath.value = imageUrl;
    super.onInit();
  }

  void updateTitleAndOg() async {
    isUpdating.value = true;

    try {
      await collectionRepos
          .updateOgPhoto(
              photoId: collection!.ogImageId,
              ogImageUrlOrPath: collectionOgUrlOrPath.value)
          .timeout(const Duration(minutes: 1));
      await collectionRepos
          .updateTitle(
            collectionId: collection!.id,
            newTitle: collectionTitle.value,
          )
          .timeout(const Duration(minutes: 1));

      Get.back();
    } catch (e) {
      print('Update collection title and og error: $e');
      Fluttertoast.showToast(
        msg: "updateFailedToast".tr,
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
