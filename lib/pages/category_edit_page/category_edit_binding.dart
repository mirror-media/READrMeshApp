import 'package:get/get.dart';
import 'package:readr/pages/category_edit_page/category_edit_controller.dart';

class CategoryEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CategoryEditController());
  }
}
