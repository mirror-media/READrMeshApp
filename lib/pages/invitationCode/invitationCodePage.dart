import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:readr/controller/invitationCodePageController.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/invitationCode.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/services/invitationCodeService.dart';

class InvitationCodePage extends GetView<InvitationCodePageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'invitationCode'.tr,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              size: 26,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          )
        ],
      ),
      body: GetBuilder<InvitationCodePageController>(
        init: InvitationCodePageController(InvitationCodeService()),
        builder: (controller) {
          if (controller.isError) {
            return ErrorPage(
              error: controller.error,
              onPressed: () => controller.fetchMyInvitationCode(),
              hideAppbar: true,
            );
          }

          if (!controller.isLoading) {
            return _buildContent(context);
          }

          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const ClampingScrollPhysics(),
      children: [
        _buildUsableCodeList(context),
        if (controller.activatedCodeList.isNotEmpty)
          _buildActivatedCodeList(context),
      ],
    );
  }

  Widget _buildUsableCodeList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'availableInviteCodes'.tr,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (controller.usableCodeList.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              'noAvailableInviteCodes'.tr,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _usableCodeItem(context, controller.usableCodeList[index]),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: controller.usableCodeList.length,
          ),
        ),
      ],
    );
  }

  Widget _usableCodeItem(BuildContext context, InvitationCode invitationCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            invitationCode.code,
            style: TextStyle(
              fontSize: 16,
              fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
              color: Theme.of(context).extension<CustomColors>()?.primary700,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: invitationCode.code));
              showMeshToast(
                icon: const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.white,
                ),
                message: 'invitationCodeCopied'.tr,
              );
            },
            icon: FaIcon(
              FontAwesomeIcons.link,
              size: 11,
              color: Theme.of(context).extension<CustomColors>()?.primary700,
            ),
            label: Text(
              'copyTheInvitationCode'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.primary700,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              side: BorderSide(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivatedCodeList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'used'.tr,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _activatedCodeItem(
                context, controller.activatedCodeList[index]),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: controller.activatedCodeList.length,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _activatedCodeItem(
      BuildContext context, InvitationCode invitationCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Text(
            invitationCode.code,
            style: TextStyle(
              fontSize: 16,
              fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
              color: Theme.of(context).extension<CustomColors>()?.primary400,
            ),
          ),
          const SizedBox(width: 20),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Get.to(() =>
                  PersonalFilePage(viewMember: invitationCode.activeMember!));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  invitationCode.activeMember!.nickname,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color:
                        Theme.of(context).extension<CustomColors>()?.primary700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                ProfilePhotoWidget(invitationCode.activeMember!, 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
