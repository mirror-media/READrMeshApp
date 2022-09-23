import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/shared/pick/pickBottomSheetWidget.dart';

Future<dynamic> showPickBottomSheet({
  required BuildContext context,
  required PickableItemController controller,
  String? oldContent,
}) async {
  String? content;
  await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: PickBottomSheetWidget(
          oldContent: oldContent,
          onTextChanged: (inputContent) => content = inputContent,
        ),
      );
    },
  ).then((result) async {
    if (result != true && content != null && content!.trim().isNotEmpty) {
      await showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          title: Text(
            'deleteAlertTitle'.tr,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 17),
          ),
          content: Text(
            'leaveAlertContent'.tr,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          actions: [
            PlatformDialogAction(
              onPressed: () => Navigator.pop(context),
              child: PlatformText(
                'deleteComment'.tr,
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).extension<CustomColors>()!.systemRed,
                ),
              ),
            ),
            PlatformDialogAction(
              onPressed: () async {
                Navigator.pop(context);
                await showPickBottomSheet(
                  context: context,
                  oldContent: content,
                  controller: controller,
                );
              },
              child: PlatformText(
                'continueInput'.tr,
                style: TextStyle(
                  fontSize: 17,
                  color:
                      Theme.of(context).extension<CustomColors>()!.systemBlue,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (result == true) {
      // return content when not empty or only space
      if (content != null && content!.trim().isNotEmpty) {
        controller.addPickAndComment(content!);
      } else {
        controller.addPick();
      }
    }
  });
}
