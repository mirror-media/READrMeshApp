import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/shared/recommendFollow/recommendFollowBlock.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';

class EmptyWidget extends StatelessWidget {
  final List<FollowableItem> recommendMembers;

  const EmptyWidget({
    Key? key,
    required this.recommendMembers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(87.5, 22, 87.5, 26),
            child: SvgPicture.asset(
              Theme.of(context).brightness == Brightness.light
                  ? noFollowingSvg
                  : noFollowingDarkSvg,
            ),
          ),
          Text(
            'communityEmptyTitle'.tr,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
              text: 'communityEmptyDescription'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
              children: const [
                TextSpan(
                  text: ' 👀',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 32,
          ),
          recommendMembers.isNotEmpty
              ? RecommendFollowBlock(
                  RecommendMemberBlockController()
                    ..recommendMembers.assignAll(recommendMembers),
                  showTitleBar: false,
                )
              : Container(),
        ],
      ),
    );
  }
}
