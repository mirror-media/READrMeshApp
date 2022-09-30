import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';

class DeletedMemberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack87,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              deletedMemberSvg,
              width: 80,
              height: 78,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'deletedMemberTitle'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'deletedMemberDescription'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv2!,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
