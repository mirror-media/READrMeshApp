import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  final String appVersion;
  final String platform;
  final String device;
  const ContactUsPage({
    required this.appVersion,
    required this.platform,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'contactUs'.tr,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _introBlock(context),
          const Divider(
            thickness: 1,
            height: 1,
          ),
          Container(
            color: Theme.of(context).backgroundColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildItem(
                  context: context,
                  title: 'customerServiceEmail'.tr,
                  content: 'readr@readr.tw',
                  onTap: () async {
                    String currentTime = DateFormat('yyyy/MM/dd HH:mm:ss')
                        .format(DateTime.now());
                    EmailContent email = EmailContent(
                      to: [
                        'readr@readr.tw',
                      ],
                      subject: 'READr Mesh 客服聯絡',
                      body:
                          '\n\n\nDate: $currentTime\nApp Version: $appVersion\nPlatform: $platform\nDevice: $device',
                    );
                    OpenMailAppResult result =
                        await OpenMailApp.composeNewEmailInMailApp(
                            emailContent: email);
                    if (!result.didOpen && !result.canOpen) {
                      showNoMailAppsDialog(context);
                    } else if (!result.didOpen && result.canOpen) {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CupertinoActionSheet(
                          actions: [
                            for (var app in result.options)
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  OpenMailApp.composeNewEmailInSpecificMailApp(
                                    mailApp: app,
                                    emailContent: email,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  app.name == 'Apple Mail'
                                      ? 'appleMail'.tr
                                      : app.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .extension<CustomColors>()!
                                        .blue!,
                                  ),
                                ),
                              ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'cancel'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Theme.of(context)
                                    .extension<CustomColors>()!
                                    .blue!,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const Divider(
                  thickness: 1,
                  height: 1,
                ),
                _buildItem(
                  context: context,
                  title: 'customerServicePhone'.tr,
                  content: '(02) 6633-3890',
                  onTap: () async {
                    String url = 'tel:02-6633-3890';
                    if (!await launchUrl(Uri.parse(url))) {
                      throw 'Could not launch $url';
                    }
                  },
                ),
                const Divider(
                  thickness: 1,
                  height: 1,
                ),
                _buildItem(
                  context: context,
                  title: 'discordCommunity'.tr,
                  content: 'https://discord.gg/ywpth4mZUw',
                  onTap: () async {
                    String url = 'https://discord.gg/ywpth4mZUw';
                    if (!await launchUrl(Uri.parse(url))) {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _introBlock(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          SvgPicture.asset(
            welcomeScreenLogoSvg,
            width: 96,
            height: 40,
            color: Theme.of(context).extension<CustomColors>()?.primary700,
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            'contactUsContent'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).extension<CustomColors>()!.primary600!,
            ),
          )
        ],
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(
          "noMailAppsDialogTitle".tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: <Widget>[
          PlatformDialogAction(
            child: Text(
              "ok".tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.blue!,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required String title,
    required String content,
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Theme.of(context).backgroundColor,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).extension<CustomColors>()!.primary700!,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).extension<CustomColors>()!.primary500!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
