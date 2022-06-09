import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentInputBoxController extends GetxController {
  final String? oldContent;
  final String commentControllerTag;
  CommentInputBoxController({
    required this.commentControllerTag,
    this.oldContent,
  });

  final hasInput = false.obs;
  late final TextEditingController textController;

  @override
  void onInit() {
    textController = TextEditingController(text: oldContent);
    textController.addListener(() {
      if (textController.text.trim().isNotEmpty) {
        hasInput.value = true;
      } else {
        hasInput.value = false;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    textController.removeListener(() {});
    super.onClose();
  }
}
