import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';

import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/follow/followButton.dart';

class MemberListItemWidget extends StatelessWidget {
  final Member viewMember;
  const MemberListItemWidget({required this.viewMember});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfilePhotoWidget(viewMember, 22),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewMember.customId,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                ),
              ),
              ExtendedText(
                viewMember.nickname,
                maxLines: 1,
                joinZeroWidthSpace: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primaryLv3!,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        if (viewMember.memberId != Get.find<UserService>().currentUser.memberId)
          FollowButton(MemberFollowableItem(viewMember)),
      ],
    );
  }
}
