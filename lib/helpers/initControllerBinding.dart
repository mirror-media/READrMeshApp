import 'package:get/get.dart';
import 'package:readr/controller/rootPageController.dart';

class InitControllerBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(RootPageController(), permanent: true);
  }
}
