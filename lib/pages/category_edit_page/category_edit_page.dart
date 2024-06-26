import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/core/value/color.dart';
import 'package:readr/core/value/strings.dart';
import 'package:readr/pages/category_edit_page/category_edit_controller.dart';
import 'package:readr/pages/category_edit_page/widgets/category_edit_item.dart';

class CategoryEditPage extends GetView<CategoryEditController> {
  const CategoryEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '編輯追蹤類別',
          style: TextStyle(
              fontFamily: 'PingFang TC',
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '請選擇您想追蹤的新聞類別',
                      style: TextStyle(
                          color: Color.fromARGB(125, 0, 9, 40),
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Obx(() {
                  final categoryList = controller.rxAllCategoryList.value;
                  final followCategoryList =
                      controller.rxUserFollowCategoryList.value;
                  return Wrap(
                    spacing: 8.0, // 子项之间的水平间距
                    runSpacing: 8.0,
                    children: categoryList
                        .map((e) => CategoryEditItem(
                            title: e.title ?? StringDefault.stringNullDefault,
                            isSelect: true))
                        .toList(),
                  );
                }),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: Get.height / 4,
                //     child: Obx(() {
                //       final renderCategoryList =
                //           controller.rxAllCategoryList.value;
                //       final followCategoryList =
                //           controller.rxUserFollowCategoryList.value;
                //       return ListView.separated(
                //         itemCount: renderCategoryList.length,
                //         separatorBuilder: (BuildContext context, int index) {
                //           return const SizedBox(height: 12);
                //         },
                //         itemBuilder: (BuildContext context, int indexColum) {
                //           return Container(
                //             alignment: Alignment.center,
                //             width: double.infinity,
                //             height: 50,
                //             child: ListView.separated(
                //               shrinkWrap: true,
                //               scrollDirection: Axis.horizontal,
                //               separatorBuilder: (context, indexRow) {
                //                 return const SizedBox(width: 12);
                //               },
                //               itemCount: renderCategoryList[indexColum].length,
                //               itemBuilder: (context, indexRow) {
                //                 return ,
                //             ),
                //           );
                //         },
                //       );
                //     }),
                //   ),
                // )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Divider(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0, // 子项之间的水平间距
                  runSpacing: 8.0, // 子项之间的垂直间距
                  children: List.generate(10, (index) {
                    return Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.blue,
                      child: Text(
                        'Item      $index',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() {
                    final followCategoryList =
                        controller.rxUserFollowCategoryList.value;
                    return Container(
                        height: 48,
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: followCategoryList.isEmpty
                              ? const Color.fromARGB(77, 0, 9, 40)
                              : CustomColor.primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                        ),
                        child: followCategoryList.isEmpty
                            ? Text('至少選一個',
                                style:
                                    TextStyle(color: CustomColor.primaryColor))
                            : const Text(
                                '儲存',
                                style: TextStyle(color: Colors.white),
                              ));
                  }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
