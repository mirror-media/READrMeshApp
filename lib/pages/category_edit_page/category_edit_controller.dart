import 'package:get/get.dart';
import 'package:readr/core/value/query_command.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/services/user_cache_service.dart';

import '../../models/category.dart';

class CategoryEditController extends GetxController {
  final ProxyServerService proxyServerService = Get.find();
  final UserService userService = Get.find();
  final PubsubService pubsubService = Get.find();
  final UserCacheService userCacheService = Get.find();
  final RxList<Category> rxUserSelectCacheCategoryList = RxList();

  @override
  void onInit() async {
    super.onInit();
    rxUserSelectCacheCategoryList.value =
        userCacheService.rxUserFollowCategoryList;
  }

  void addCategory(Category category) async {
    rxUserSelectCacheCategoryList.add(category);
  }

  void removeCategory(Category category) async {
    rxUserSelectCacheCategoryList
        .removeWhere((element) => element.id == category.id);
  }

  void saveButtonClick() async {
    await compareAndUpdateFollowCategoryList(
        rxUserSelectCacheCategoryList, userCacheService.rxAllCategoryList);
    Get.back();
  }

  Future<void> compareAndUpdateFollowCategoryList(
      List<Category> listA, List<Category> listB) async {
    List<Category> toAdd = [];
    List<Category> toRemove = [];

    for (Category item in listA) {
      if (listB.contains(item)) {
        toAdd.add(item);
      }
    }
    for (Category item in listB) {
      if (!listA.contains(item)) {
        toRemove.add(item);
      }
    }
    await userCacheService.addCategoryList(
        categoryList: toAdd);
    await userCacheService.removeCategoryList(
        categoryList: toRemove);
    userCacheService.rxUserFollowCategoryList
        .sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
  }
}
