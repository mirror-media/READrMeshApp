import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/services/collectionService.dart';

class DescriptionPageController extends GetxController {
  final collectionDescription = ''.obs;
  final isUpdating = false.obs;
  final String? description;
  final Collection? collection;
  final CollectionRepos collectionRepos;
  DescriptionPageController(
    this.collectionRepos, {
    this.description,
    this.collection,
  });

  @override
  void onInit() {
    collectionDescription.value = description ?? '';
    super.onInit();
  }

  void updateDescription() async {
    isUpdating.value = true;

    try {
      await collectionRepos.updateDescription(
        collectionId: collection!.id,
        description: collectionDescription.value,
      );

      //refetch data to update UI
      await Get.find<CollectionPageController>(tag: collection!.id)
          .fetchCollectionData(useCache: false);

      Get.back();
    } catch (e) {
      print('Update collection description error: $e');
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
