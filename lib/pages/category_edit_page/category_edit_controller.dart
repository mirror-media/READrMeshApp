import 'package:get/get.dart';
import 'package:readr/core/value/query_command.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';

import '../../models/category.dart';

class CategoryEditController extends GetxController {
  List<Category> categoryList = [];
  final RxList<Category> rxAllCategoryList = RxList();
  final RxList<Category> rxUserFollowCategoryList = RxList();
  final ProxyServerService proxyServerService = Get.find();
  final UserService userService = Get.find();
  final PubsubService pubsubService = Get.find();

  List<List<Category>> renderCategoryList = [];

  @override
  void onInit() async {
    super.onInit();
    final result =
        await proxyServerService.gql(query: QueryCommand.getCategoryList);

    rxAllCategoryList.value = (result['categories'] as List<dynamic>)
        .map((e) => Category.fromJson(e))
        .toList();

    rxUserFollowCategoryList.value = await getFollowCategoryList();
  }

  void addCategory(Category category) async {
    rxUserFollowCategoryList.add(category);
  }

  void removeCategory(Category category) async {
    rxUserFollowCategoryList
        .removeWhere((element) => element.id == category.id);
  }

  void saveButtonClick() async {
    final followCategoryList = await getFollowCategoryList();

    compareAndUpdateFollowCategoryList(
        rxUserFollowCategoryList, followCategoryList);
    Get.back();
  }

  Future<List<Category>> getFollowCategoryList() async {
    final followCategoryResult = await proxyServerService.gql(
        query: QueryCommand.getSubscriptCategoryByUserId,
        variables: {"userId": userService.currentUser.memberId});
    return (followCategoryResult['member']['following_category']
            as List<dynamic>)
        .map((e) => Category.fromJson(e))
        .toList();
  }

  void compareAndUpdateFollowCategoryList(
      List<Category> listA, List<Category> listB) {
    List<Category> toAdd = [];
    List<Category> toRemove = [];

    // 找出 A 有而 B 沒有的元素
    for (Category item in listA) {
      if (!listB.contains(item)) {
        toAdd.add(item);
      }
    }

    // 找出 B 有而 A 沒有的元素
    for (Category item in listB) {
      if (!listA.contains(item)) {
        toRemove.add(item);
      }
    }

    pubsubService.addCategoryList(
        memberId: userService.currentUser.memberId,
        categoryList: toAdd.map((e) => e.id).toList());

    pubsubService.removeCategoryList(
        memberId: userService.currentUser.memberId,
        categoryList: toRemove.map((e) => e.id).toList());
  }
}
