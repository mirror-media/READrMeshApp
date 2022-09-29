import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';

class CollectionDeletedPage extends StatelessWidget {
  const CollectionDeletedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: GetPlatform.isIOS,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'collection'.tr,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(collectionDeletedSvg),
            const SizedBox(
              height: 20,
            ),
            Text(
              'collectionDeletedTitle'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).extension<CustomColors>()?.primaryLv1,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'collectionDeletedDescription'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).extension<CustomColors>()?.primaryLv2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
