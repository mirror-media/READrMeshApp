import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:readr/controller/collection/addToCollectionPageController.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/collection/createAndEdit/descriptionPageController.dart';
import 'package:readr/controller/collection/createAndEdit/titleAndOgPageController.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/folderCollectionPick.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/services/collectionService.dart';

class SortStoryPageController extends GetxController {
  final CollectionRepos collectionRepos;
  final isUpdating = false.obs;
  final List<FolderCollectionPick> originalList;
  final collectionStoryList = <FolderCollectionPick>[].obs;
  final Collection? collection;
  bool _isFirstTimeEdit = true;
  final bool isEdit;
  final hasChange = false.obs;
  final JustTheController tooltipController = JustTheController();
  SortStoryPageController(
    this.collectionRepos,
    this.originalList,
    this.isEdit, {
    this.collection,
  });

  @override
  void onInit() {
    _isFirstTimeEdit = Get.find<SharedPreferencesService>()
            .prefs
            .getBool('firstTimeEditFolder') ??
        true;
    ever(collectionStoryList, (callback) => _checkHasChange());
    collectionStoryList.assignAll(originalList);
    super.onInit();
  }

  @override
  void onReady() {
    if (_isFirstTimeEdit && isEdit) {
      _showDeleteHint();
    }
    super.onReady();
  }

  void _checkHasChange() {
    if (collectionStoryList.length != originalList.length) {
      hasChange.value = true;
    } else {
      for (int i = 0; i < collectionStoryList.length; i++) {
        if (collectionStoryList[i].news.id != originalList[i].news.id) {
          hasChange.value = true;
          break;
        } else {
          hasChange.value = false;
        }
      }
    }
  }

  void createCollection() async {
    isUpdating.value = true;

    try {
      // create Photo in CMS first to link when create collection
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
            collectionPicks: collectionStoryList,
            description: Get.find<DescriptionPageController>()
                .collectionDescription
                .value,
          )
          .timeout(
            const Duration(minutes: 1),
          );

      // send pub/sub to create notifies
      Get.find<PubsubService>().addCollection(
        memberId: Get.find<UserService>().currentUser.memberId,
        collectionId: newCollection.id,
      );

      // if current member's collection tab controller is exist, refetch to update collection list
      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList(useCache: false);
      }

      ///check where user come from
      ///if from addToCollectionPage, go back to previous page of addToCollectionPage
      ///else pop all create collection related pages and push to collection page
      if (Get.isRegistered<AddToCollectionPageController>()) {
        Get.until(
          (route) {
            return route.settings.name == '/AddToCollectionPage';
          },
        );
        Get.back();
        showMeshToast(
          icon: const Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.white,
          ),
          message: 'addToCollectionSuccessToast'.tr,
        );
      } else {
        Get.offUntil<GetPageRoute>(
          GetPageRoute(
            routeName: '/CollectionPage',
            page: () => CollectionPage(
              newCollection,
              isNewCollection: true,
            ),
          ),
          (route) {
            return route.settings.name == '/PersonalFilePage' || route.isFirst;
          },
        );
      }
    } catch (e) {
      print('Create collection error: $e');
      isUpdating.value = false;
      Fluttertoast.showToast(
        msg: "createCollectionFailedToast".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    isUpdating.value = false;
  }

  //edit collection's collectionPicks
  void updateCollectionPicks() async {
    isUpdating.value = true;

    try {
      await collectionRepos.updateCollectionPicks(
        collectionId: collection!.id,
        originList: originalList,
        newList: collectionStoryList,
        format: CollectionFormat.folder,
      );
      await Get.find<CollectionPageController>(tag: collection!.id)
          .fetchCollectionData(useCache: false);
      Get.back();
    } catch (e) {
      print('Update collection picks error: $e');
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

  //show when first time edit
  void _showDeleteHint() async {
    await showGeneralDialog(
      context: Get.overlayContext!,
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.black.withOpacity(0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                collectionDeleteHintSvg,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                'collectionDeleteItemHint'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.find<SharedPreferencesService>()
                      .prefs
                      .setBool('firstTimeEditFolder', false);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'iGotIt'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    color: meshBlack87,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
    tooltipController.showTooltip();
  }
}
