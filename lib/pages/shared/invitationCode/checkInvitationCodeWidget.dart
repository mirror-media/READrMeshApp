import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/invitationCode.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';

class CheckInvitationCodeWidget extends StatelessWidget {
  CheckInvitationCodeWidget({Key? key}) : super(key: key);

  final List<InvitationCode> _usableCodeList = [];
  final List<InvitationCode> _activatedCodeList = [];
  @override
  Widget build(BuildContext context) {
    // mock data
    _usableCodeList.add(InvitationCode(code: 'FRISAT'));
    _usableCodeList.add(InvitationCode(code: 'SATSUN'));
    _usableCodeList.add(InvitationCode(code: 'SUNFRI'));
    _activatedCodeList.add(InvitationCode(
      code: 'SUNFRI',
      activeMember: UserHelper.instance.currentUser,
    ));
    _activatedCodeList.add(InvitationCode(
      code: 'FRISAT',
      activeMember: UserHelper.instance.currentUser,
    ));

    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const ClampingScrollPhysics(),
      children: [
        if (_usableCodeList.isNotEmpty) _buildUsableCodeList(context),
        if (_activatedCodeList.isNotEmpty) _buildActivatedCodeList(context),
      ],
    );
  }

  Widget _buildUsableCodeList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '可用的邀請碼',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: readrBlack87,
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _usableCodeItem(context, _usableCodeList[index]),
            separatorBuilder: (context, index) => const Divider(
              color: readrBlack10,
              height: 1,
            ),
            itemCount: _usableCodeList.length,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: readrBlack87,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
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
        const Text(
          '已使用',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: readrBlack87,
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                _activatedCodeItem(context, _activatedCodeList[index]),
            separatorBuilder: (context, index) => const Divider(
              color: readrBlack10,
              height: 1,
            ),
            itemCount: _activatedCodeList.length,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: readrBlack30,
            ),
          ),
          const SizedBox(width: 20),
          const Spacer(),
          GestureDetector(
            onTap: () {},
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
