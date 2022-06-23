import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/internetCheckService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:share_plus/share_plus.dart';

class MoreActionBottomSheet {
  static Future<void> showMoreActionSheet({
    required BuildContext context,
    required PickObjective objective,
    required String id,
    required String controllerTag,
    String? url,
  }) async {
    await showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      topRadius: const Radius.circular(24),
      builder: (context) => Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  height: 4,
                  width: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: readrBlack20,
                    ),
                  ),
                ),
              ),
              if (objective == PickObjective.story)
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (Get.find<UserService>().isMember.isFalse) {
                      Get.to(
                        () => const LoginPage(),
                        fullscreenDialog: true,
                      );
                    } else if (await Get.find<InternetCheckService>()
                        .meshCheckInstance
                        .hasConnection) {
                      Get.find<PickableItemController>(tag: controllerTag)
                          .isBookmarked
                          .toggle();
                      Get.find<PickableItemController>(tag: controllerTag)
                          .updateBookmark();
                    } else {
                      Fluttertoast.showToast(
                        msg: "伺服器連接失敗 請稍後再試",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  icon: Icon(
                    Get.find<PickableItemController>(tag: controllerTag)
                            .isBookmarked
                            .value
                        ? PlatformIcons(context).bookmarkSolid
                        : PlatformIcons(context).bookmarkOutline,
                    color: readrBlack87,
                    size: 18,
                  ),
                  label: Text(
                    Get.find<PickableItemController>(tag: controllerTag)
                            .isBookmarked
                            .value
                        ? '移除書籤'
                        : '加入書籤',
                    style: const TextStyle(
                      color: readrBlack87,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              if (url != null)
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    Clipboard.setData(ClipboardData(text: url));
                    _showCopiedToast(context);
                  },
                  icon: Icon(
                    GetPlatform.isAndroid ? Icons.link : CupertinoIcons.link,
                    size: 19,
                    color: readrBlack87,
                  ),
                  label: const Text(
                    '複製連結',
                    style: TextStyle(
                      color: readrBlack87,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              if (url != null)
                TextButton.icon(
                  onPressed: () async {
                    Share.shareWithResult(url).then((value) {
                      if (value.status == ShareResultStatus.success) {
                        logShare(objective.toString().split('.').last, id,
                            value.raw);
                      }
                    });
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    PlatformIcons(context).share,
                    color: readrBlack87,
                    size: 18,
                  ),
                  label: const Text(
                    '分享',
                    style: TextStyle(
                      color: readrBlack87,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    alignment: Alignment.centerLeft,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showCopiedToast(BuildContext context) {
    showToastWidget(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: const Color.fromRGBO(0, 9, 40, 0.66),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.check_circle,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(
              width: 6.0,
            ),
            Text(
              '已複製連結',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      context: context,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      position: StyledToastPosition.top,
      startOffset: const Offset(0.0, -3.0),
      reverseEndOffset: const Offset(0.0, -3.0),
      duration: const Duration(seconds: 3),
      //Animation duration   animDuration * 2 <= duration
      animDuration: const Duration(milliseconds: 250),
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
  }
}
