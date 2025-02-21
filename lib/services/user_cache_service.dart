import 'package:get/get.dart';
import 'package:readr/core/value/query_command.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';

import '../getxServices/pubsubService.dart';
import '../models/category.dart';

class UserCacheService extends GetxService {
  final PubsubService pubsubService = Get.find();
  final RxList<Category> rxUserFollowCategoryList = RxList();
  final RxList<Category> rxAllCategoryList = RxList();
  final UserService userService = Get.find();
  final ProxyServerService proxyServerService = Get.find();

  @override
  void onInit() async {
    super.onInit();
    fetchFollowCategoryList();
    final result =
        await proxyServerService.gql(query: QueryCommand.getCategoryList);
    rxAllCategoryList.value = (result['categories'] as List<dynamic>)
        .map((e) => Category.fromJson(e))
        .toList();

    rxUserFollowCategoryList.value = await getFollowCategoryList();
  }

  Future<void> fetchFollowCategoryList() async {
    rxUserFollowCategoryList.value = await getFollowCategoryList();
    print(rxUserFollowCategoryList.length);

    for (var item in rxUserFollowCategoryList) {
      print('fetchFollowCategoryList${item.title}');
    }
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

  Future<void> addCategoryList({required List<Category> categoryList}) async {
    final newCategories = categoryList
        .where((newCategory) => !rxUserFollowCategoryList
            .any((existingCategory) => existingCategory.id == newCategory.id))
        .toList();

    if (newCategories.isNotEmpty) {
      rxUserFollowCategoryList.addAll(newCategories);

      await pubsubService.addCategoryList(
        memberId: userService.currentUser.memberId,
        categoryList: newCategories.map((e) => e.id).toList(),
      );
    }

    await pubsubService.addCategoryList(
        memberId: userService.currentUser.memberId,
        categoryList: categoryList.map((e) => e.id).toList());
  }

  Future<void> removeCategoryList(
      {required List<Category> categoryList}) async {
    final List<String> categoryIdsToRemove =
        categoryList.map((e) => e.id).toList();

    rxUserFollowCategoryList
        .removeWhere((category) => categoryIdsToRemove.contains(category.id));
    rxUserFollowCategoryList
        .sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    await pubsubService.removeCategoryList(
        memberId: userService.currentUser.memberId,
        categoryList: categoryList.map((e) => e.id).toList());
  }
}
