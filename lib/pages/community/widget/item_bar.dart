import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/community/community_controller.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/moreActionBottomSheet.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';

class ItemBar extends StatelessWidget {
  final CommunityListItem item;
  final CommunityController controller;

  const ItemBar({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (item.itemBarMember.isEmpty) {
      return Container();
    }

    List<Member> firstTwoMember = controller.getFirstTwoMembers(item);

    return Container(
      color: Theme.of(context).backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              children: _buildItemBarContent(context, firstTwoMember),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              final info = await controller.getMoreActionSheetInfo(item);
              await showMoreActionSheet(
                context: context,
                objective: info['objective'],
                id: item.itemId,
                controllerTag: item.controllerTag,
                url: info['url'],
                heroImageUrl: item.newsListItem?.heroImageUrl,
                newsListItem: item.newsListItem,
              );
            },
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: const EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            constraints: const BoxConstraints(maxHeight: 18),
            icon: Icon(
              PlatformIcons(context).ellipsis,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemBarContent(
      BuildContext context, List<Member> members) {
    List<Widget> children = [
      ProfilePhotoStack(
        members,
        14,
        key: ObjectKey(members),
      ),
      const SizedBox(width: 8),
    ];

    if (members.length == 1) {
      children.addAll(_buildSingleMemberContent(context, members[0]));
    } else {
      children.addAll(_buildMultipleMembersContent(context, members));
    }

    return children;
  }

  List<Widget> _buildSingleMemberContent(BuildContext context, Member member) {
    List<Widget> widgets = [
      Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: member));
          },
          child: ExtendedText(
            member.nickname,
            joinZeroWidthSpace: true,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    if (item.itemBarText != null) {
      widgets.add(
        Text(
          item.itemBarText!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
          strutStyle: const StrutStyle(
            forceStrutHeight: true,
            leading: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildMultipleMembersContent(
      BuildContext context, List<Member> members) {
    List<Widget> widgets = [
      Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: members[0]));
          },
          child: ExtendedText(
            members[0].nickname,
            joinZeroWidthSpace: true,
            style: Theme.of(context).textTheme.titleSmall,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Text(
        'and'.tr,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        strutStyle: const StrutStyle(
          forceStrutHeight: true,
          leading: 0.5,
        ),
        maxLines: 1,
      ),
      Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: members[1]));
          },
          child: ExtendedText(
            members[1].nickname,
            joinZeroWidthSpace: true,
            style: Theme.of(context).textTheme.titleSmall,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    if (item.itemBarText != null) {
      widgets.add(
        Text(
          '${'both'.tr}${item.itemBarText!}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
          strutStyle: const StrutStyle(
            forceStrutHeight: true,
            leading: 0.5,
          ),
          maxLines: 1,
        ),
      );
    }

    return widgets;
  }
}
