import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/themes.dart';

Future<void> showReportAlertDialog(BuildContext context) async {
  await showPlatformDialog(
    context: context,
    builder: (context) => PlatformAlertDialog(
      title: Text(
        'reportAlertTitle'.tr,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        'reportAlertBody'.tr,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16),
      ),
      actions: [
        PlatformDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'allRight'.tr,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()?.blue,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}
