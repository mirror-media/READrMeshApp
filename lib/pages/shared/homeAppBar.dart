import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';

import 'package:readr/pages/invitationCode/checkInvitationCodePage.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0.5,
      title: SvgPicture.asset(
        appBarIconSvg,
      ),
      actions: [
        // IconButton(
        //   onPressed: () {},
        //   icon: const Icon(
        //     Icons.notifications_none_outlined,
        //     color: readrBlack,
        //   ),
        // )
        IconButton(
          onPressed: () {
            Get.to(
              () => const CheckInvitationCodePage(),
              fullscreenDialog: true,
            );
          },
          icon: SvgPicture.asset(
            Get.find<UserService>().hasInvitationCode
                ? newInvitationCodeSvg
                : invitationCodeSvg,
            fit: BoxFit.cover,
          ),
        )
      ],
    );
  }
}
