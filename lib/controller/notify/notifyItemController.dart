import 'package:get/get.dart';

class NotifyItemController extends GetxController {
  final bool isRead;
  NotifyItemController({this.isRead = true});

  final alreadyRead = true.obs;

  @override
  void onInit() {
    alreadyRead.value = isRead;
    super.onInit();
  }
}
