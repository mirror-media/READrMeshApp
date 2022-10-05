import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/shared/reportAlertDialog.dart';

Future<void> reportCommentMenu(
  BuildContext context,
  Comment comment,
) async {
  String? result;
  if (GetPlatform.isIOS) {
    result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('report'),
            child: Text(
              'reportComment'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Theme.of(context).extension<CustomColors>()?.redText,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: Text(
            'cancel'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Theme.of(context).extension<CustomColors>()?.blue,
            ),
          ),
        ),
      ),
    );
  } else {
    result = await showCupertinoModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      topRadius: const Radius.circular(24),
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Material(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Theme.of(context).backgroundColor,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primaryLv4,
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop('report'),
                icon: Icon(
                  Icons.report_outlined,
                  color: Theme.of(context).extension<CustomColors>()?.red,
                  size: 18,
                ),
                label: Text(
                  'reportComment'.tr,
                  style: TextStyle(
                    color: Theme.of(context).extension<CustomColors>()?.redText,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  if (result == 'report') {
    await showReportAlertDialog(context);
  }
}
