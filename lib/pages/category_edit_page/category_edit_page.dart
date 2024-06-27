import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/core/theme/color.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Row(
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
            const SizedBox(
              height: 20,
            ),
            Obx(() {
              final categoryList = controller.rxAllCategoryList.value;
              final followCategoryList =
                  controller.rxUserFollowCategoryList.value;
              return Wrap(
                spacing: 12, // 子项之间的水平间距
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: categoryList.map((category) {
                  final isSelected = followCategoryList.contains(category);
                  return InkWell(
                    onTap: () {
                      isSelected
                          ? controller.removeCategory(category)
                          : controller.addCategory(category);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CustomColor.primaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.title ?? StringDefault.stringNullDefault,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : CustomColor.primaryColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Obx(() {
                  final canSelect =controller.rxUserFollowCategoryList.isEmpty;
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: canSelect
                            ? const Color(0xFFE0E0E0)
                            : CustomColor.primaryColor,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: canSelect
                          ? null
                          : () {
                              controller.saveButtonClick();
                            },
                      child: Text(
                        canSelect? '至少選 1 個' : '儲存',
                        style: TextStyle(
                            color: canSelect
                                ? Colors.grey
                                : Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }
}
