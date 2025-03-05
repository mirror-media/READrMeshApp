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
    Key? key,
    required this.item,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item.itemBarMember.isEmpty) {
      return Container();
    }

    List<Member> firstTwoMember = controller.getFirstTwoMembers(item);

    List<Widget> children = [
      ProfilePhotoStack(
        firstTwoMember,
        14,
        key: ObjectKey(firstTwoMember),
      ),
      const SizedBox(width: 8),
    ];

    if (firstTwoMember.length == 1) {
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: firstTwoMember[0]));
          },
          child: ExtendedText(
            firstTwoMember[0].nickname,
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
      ));
      children.add(item.itemBarText != null
          ? Text(
              item.itemBarText!,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
              strutStyle: const StrutStyle(
                forceStrutHeight: true,
                leading: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Container());
    } else {
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: firstTwoMember[0]));
          },
          child: ExtendedText(
            firstTwoMember[0].nickname,
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
      ));
      children.add(Text(
        'and'.tr,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        strutStyle: const StrutStyle(
          forceStrutHeight: true,
          leading: 0.5,
        ),
        maxLines: 1,
      ));
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            Get.to(() => PersonalFilePage(viewMember: firstTwoMember[1]));
          },
          child: ExtendedText(
            firstTwoMember[1].nickname,
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
      ));
      children.add(item.itemBarText != null
          ? Text(
              '${'both'.tr}${item.itemBarText!}',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
              strutStyle: const StrutStyle(
                forceStrutHeight: true,
                leading: 0.5,
              ),
              maxLines: 1,
            )
          : Container());
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              children: children,
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
}
