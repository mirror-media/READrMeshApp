import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';

import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/followButton.dart';

class MemberListItemWidget extends StatefulWidget {
  final Member viewMember;
  const MemberListItemWidget({required this.viewMember});

  @override
  State<MemberListItemWidget> createState() => _MemberListItemWidgetState();
}

class _MemberListItemWidgetState extends State<MemberListItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfilePhotoWidget(widget.viewMember, 22),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.viewMember.customId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: readrBlack87,
                ),
              ),
              ExtendedText(
                widget.viewMember.nickname,
                maxLines: 1,
                joinZeroWidthSpace: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: readrBlack50,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        if (!(widget.viewMember.memberId ==
            Get.find<UserService>().currentUser.memberId))
          FollowButton(MemberFollowableItem(widget.viewMember)),
      ],
    );
  }
}
