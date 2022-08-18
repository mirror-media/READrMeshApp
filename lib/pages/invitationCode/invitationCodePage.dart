import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:readr/controller/invitationCodePageController.dart';
import 'package:readr/helpers/dataConstants.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: const Text(
          '邀請碼',
          style: TextStyle(
            color: readrBlack,
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              size: 26,
              color: readrBlack87,
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

  Widget _buildUsableCodeList(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '可用的邀請碼',
          style: TextStyle(
            fontSize: 18,
            fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
            color: readrBlack87,
          ),
        ),
        const SizedBox(height: 12),
        if (controller.usableCodeList.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Text(
              '目前沒有可用的邀請碼...',
              style: TextStyle(
                color: readrBlack66,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _usableCodeItem(context, controller.usableCodeList[index]),
            separatorBuilder: (context, index) => const Divider(
              color: readrBlack10,
              height: 1,
            ),
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
              color: readrBlack87,
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
                message: '已複製邀請碼',
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.link,
              size: 11,
              color: readrBlack87,
            ),
            label: const Text(
              '複製邀請碼',
              style: TextStyle(
                color: readrBlack87,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: readrBlack87,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              side: const BorderSide(color: readrBlack87),
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
          '已使用',
          style: TextStyle(
            fontSize: 18,
            fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
            color: readrBlack87,
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _activatedCodeItem(
                context, controller.activatedCodeList[index]),
            separatorBuilder: (context, index) => const Divider(
              color: readrBlack10,
              height: 1,
            ),
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
              color: readrBlack30,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: readrBlack87,
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
