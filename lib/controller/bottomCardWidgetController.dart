import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomCardWidgetController extends GetxController {
  BottomCardWidgetController();

  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  final isCollapsed = true.obs;

  @override
  void onInit() {
    draggableScrollableController.addListener(() {
      if (draggableScrollableController.size > 0.25) {
        isCollapsed.value = false;
      } else {
        isCollapsed.value = true;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    draggableScrollableController.removeListener(() {});
    super.onClose();
  }
}
