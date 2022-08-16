import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';

class DeletedMemberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      backgroundColor: meshGray,
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
            const Text(
              '目前無法查看此內容',
              style: TextStyle(
                color: readrBlack87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            const Text(
              '此個人檔案可能已被刪除',
              style: TextStyle(
                color: readrBlack66,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
