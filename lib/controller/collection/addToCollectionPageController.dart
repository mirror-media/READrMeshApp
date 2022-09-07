import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/addToCollectionItem.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/services/collectionService.dart';

class AddToCollectionPageController extends GetxController {
  final CollectionRepos collectionRepos;
  final NewsListItem news;
  AddToCollectionPageController(this.collectionRepos, this.news);

  List<AddToCollectionItem> alreadyPickCollections = [];
  List<AddToCollectionItem> notPickCollections = [];
  bool isLoading = true;
  dynamic error;

  @override
  void onInit() {
    fetchAllOwnCollections();
    super.onInit();
  }

  void fetchAllOwnCollections() async {
    isLoading = true;
    error = null;
    update();
    try {
      var result = await collectionRepos
          .fetchAndCheckOwnCollections(news.id)
          .timeout(1.minutes);
      alreadyPickCollections.assignAll(result['alreadyPickCollections'] ?? []);
      notPickCollections.assignAll(result['notPickCollections'] ?? []);
    } catch (e) {
      print('Fetch all own collections failed: $e');
      error = determineException(e);
    }
    isLoading = false;
    update();
  }

  void addStoryToCollection(AddToCollectionItem addToCollectionItem) async {
    try {
      switch (addToCollectionItem.format) {
        case CollectionFormat.folder:
          await collectionRepos.addSingleStoryToCollection(
            collectionId: addToCollectionItem.id!,
            storyId: news.id,
            sortOrder: addToCollectionItem.collectionPicks!.length - 1,
          );
          break;
        case CollectionFormat.timeline:
          List<CollectionPick> needUpdateList = [];
          CollectionPick newPick = CollectionPick.fromNewsListItem(news);
          addToCollectionItem.collectionPicks!.add(newPick);
          addToCollectionItem.collectionPicks!.sort((a, b) {
            DateTime aDateTime;
            if (a.customTime != null) {
              aDateTime = a.customTime!;
            } else {
              aDateTime = DateTime(
                a.customYear ?? 1970,
                a.customMonth ?? 1,
                a.customDay ?? 1,
              );
            }

            DateTime bDateTime;
            if (b.customTime != null) {
              bDateTime = b.customTime!;
            } else {
              bDateTime = DateTime(
                b.customYear ?? 1970,
                b.customMonth ?? 1,
                b.customDay ?? 1,
              );
            }

            return bDateTime.compareTo(aDateTime);
          });

          for (int i = 0;
              i < addToCollectionItem.collectionPicks!.length;
              i++) {
            if (addToCollectionItem.collectionPicks![i].id != newPick.id &&
                addToCollectionItem.collectionPicks![i].sortOrder != i) {
              addToCollectionItem.collectionPicks![i].sortOrder = i;
              needUpdateList.add(addToCollectionItem.collectionPicks![i]);
            } else if (addToCollectionItem.collectionPicks![i].id ==
                newPick.id) {
              newPick.sortOrder = i;
            }
          }

          await Future.wait([
            collectionRepos.addSingleStoryToCollection(
              collectionId: addToCollectionItem.id!,
              storyId: news.id,
              sortOrder: newPick.sortOrder,
              customYear: newPick.customYear,
              customMonth: newPick.customMonth,
              customDay: newPick.customDay,
            ),
            if (needUpdateList.isNotEmpty)
              collectionRepos.updateCollectionPicksData(
                  collectionPicks: needUpdateList),
          ]);
          break;
      }

      _showResultToast(true);
    } catch (e) {
      print('Add new story to collection failed: $e');
      _showResultToast(false);
    }
  }

  void _showResultToast(bool isSuccess) {
    String message = isSuccess
        ? 'addToCollectionSuccessToast'.tr
        : 'addToCollectionFailedToast'.tr;
    IconData iconData = isSuccess ? Icons.check_circle : Icons.error;
    Widget icon = Icon(
      iconData,
      size: 16,
      color: Colors.white,
    );
    showMeshToast(
      icon: icon,
      message: message,
    );
  }
}
