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
import 'package:readr/models/timelineCollectionPick.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/services/collectionService.dart';

class TimeDimensionPageController extends GetxController {
  final CollectionRepos collectionRepos;
  final List<TimelineCollectionPick> timelineStory;
  final Collection? collection;
  final JustTheController tooltipController = JustTheController();
  bool _isFirstTimeEdit = true;
  TimeDimensionPageController(
    this.collectionRepos,
    this.timelineStory, {
    this.collection,
  });

  final isUpdating = false.obs;
  final hasChange = false.obs;
  final timelineStoryList = <TimelineCollectionPick>[].obs;

  //for CustomTimePage
  final year = 1970.obs;
  final month = RxnInt();
  final day = RxnInt();
  final time = Rxn<DateTime>();

  @override
  void onInit() {
    _isFirstTimeEdit = Get.find<SharedPreferencesService>()
            .prefs
            .getBool('firstTimeEditTimeline') ??
        true;
    timelineStoryList.assignAll(timelineStory);
    ever<int>(year, (callback) {
      if (month.value != null && day.value != null) {
        if (day.value! > DateTime(callback, month.value! + 1, 0).day) {
          day.value = null;
          time.value = null;
        }
      }
    });
    ever<int?>(
      month,
      (callback) {
        if (callback != null && day.value != null) {
          if (day.value! > DateTime(year.value, callback + 1, 0).day) {
            day.value = null;
            time.value = null;
          }
        }
      },
    );
    ever<int?>(
      day,
      (callback) {
        if (callback == null) {
          time.value = null;
        }
      },
    );
    ever<List<TimelineCollectionPick>>(
      timelineStoryList,
      (callback) {
        if (callback != timelineStory) {
          hasChange.value = true;
        } else {
          hasChange.value = false;
        }
      },
    );
    super.onInit();
  }

  @override
  void onReady() {
    if (_isFirstTimeEdit) {
      _showDeleteHint();
    }
    super.onReady();
  }

  void sortListByTime() {
    timelineStoryList.sort((a, b) {
      // compare year
      int result = b.customYear!.compareTo(a.customYear!);
      if (result != 0) {
        return result;
      }

      //compare month
      if (a.customMonth == null && b.customMonth == null) {
        return b.news.publishedDate.compareTo(a.news.publishedDate);
      } else if (a.customMonth == null) {
        return 1;
      } else if (b.customMonth == null) {
        return -1;
      } else {
        result = b.customMonth!.compareTo(a.customMonth!);
        if (result != 0) {
          return result;
        }
      }

      // compare day
      if (a.customDay == null && b.customDay == null) {
        return b.news.publishedDate.compareTo(a.news.publishedDate);
      } else if (a.customDay == null) {
        return 1;
      } else if (b.customDay == null) {
        return -1;
      } else {
        result = b.customDay!.compareTo(a.customDay!);
        if (result != 0) {
          return result;
        }
      }

      // compare time
      if (a.customTime == null && b.customTime == null) {
        return b.news.publishedDate.compareTo(a.news.publishedDate);
      } else if (a.customTime == null) {
        return 1;
      } else if (b.customTime == null) {
        return -1;
      } else {
        result = b.customTime!.compareTo(a.customTime!);
        if (result != 0) {
          return result;
        } else {
          return b.news.publishedDate.compareTo(a.news.publishedDate);
        }
      }
    });
  }

  void createCollection() async {
    isUpdating.value = true;

    try {
      String imageId = await collectionRepos
          .createOgPhoto(
              ogImageUrlOrPath: Get.find<TitleAndOgPageController>()
                  .collectionOgUrlOrPath
                  .value)
          .timeout(
            const Duration(minutes: 1),
          );
      for (int i = 0; i < timelineStoryList.length; i++) {
        timelineStoryList[i].sortOrder = i;
      }
      Collection newCollection = await collectionRepos
          .createCollection(
            title: Get.find<TitleAndOgPageController>().collectionTitle.value,
            ogImageId: imageId,
            collectionPicks: timelineStoryList,
            description: Get.find<DescriptionPageController>()
                .collectionDescription
                .value,
            format: CollectionFormat.timeline,
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
          message: '成功加入集錦',
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
        msg: "建立失敗 請稍後再試",
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

  void updateCollectionPicks(bool isAddToEmpty) async {
    isUpdating.value = true;

    try {
      await collectionRepos.updateCollectionPicks(
        collectionId: collection!.id,
        originList: isAddToEmpty ? [] : timelineStory,
        newList: timelineStoryList,
        format: CollectionFormat.timeline,
      );
      await Get.find<CollectionPageController>(tag: collection!.id)
          .fetchCollectionData(useCache: false);
      Get.back();
    } catch (e) {
      print('Update collection picks error: $e');
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
                '向左滑可以刪除文章',
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
                  primary: Colors.white,
                ),
                child: const Text(
                  '我知道了',
                  style: TextStyle(
                    fontSize: 16,
                    color: readrBlack87,
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
