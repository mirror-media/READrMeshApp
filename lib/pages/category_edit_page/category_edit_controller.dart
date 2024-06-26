// import 'package:get/get.dart';
// import 'package:readr/core/value/query_command.dart';
// import 'package:readr/getxServices/proxyServerService.dart';
// import 'package:readr/getxServices/userService.dart';
//
// import '../../models/category.dart';
//
// class CategoryEditController extends GetxController {
//   List<Category> categoryList = [];
//   final RxList<Category> rxAllCategoryList = RxList();
//   final RxList<Category> rxUserFollowCategoryList = RxList();
//
//   final ProxyServerService proxyServerService = Get.find();
//   final UserService userService = Get.find();
//
//   List<List<Category>> renderCategoryList = [];
//
//   @override
//   void onInit() async {
//     final result =
//         await proxyServerService.gql(query: QueryCommand.getCategoryList);
//
//     rxAllCategoryList.value = (result['categories'] as List<dynamic>)
//         .map((e) => Category.fromJson(e))
//         .toList();
//
//     final followCategoryResult = await proxyServerService.gql(
//         query: QueryCommand.getSubscriptCategoryByUserId,
//         variables: {"userId": userService.currentUser.memberId});
//     rxUserFollowCategoryList.value = (followCategoryResult['member']['following_category'] as List<dynamic>)
//         .map((e) => Category.fromJson(e))
//         .toList();
//   }
//
//   List<List<Category>> chunkList(List<Category> list, int chunkSize) {
//     List<List<Category>> chunks = [];
//     for (int i = 0; i < list.length; i += chunkSize) {
//       int end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
//       chunks.add(list.sublist(i, end));
//     }
//     return chunks;
//   }
//
// }
