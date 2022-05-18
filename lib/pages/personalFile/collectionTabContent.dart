import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/collection/createCollection/chooseStoryPage.dart';

class CollectionTabContent extends StatefulWidget {
  final Member viewMember;
  final bool isMine;
  const CollectionTabContent({
    required this.viewMember,
    required this.isMine,
  });
  @override
  State<CollectionTabContent> createState() => _CollectionTabContentState();
}

class _CollectionTabContentState extends State<CollectionTabContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _emptyWidget();
  }

  Widget _emptyWidget() {
    if (widget.isMine) {
      return Container(
        color: homeScreenBackgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '從精選新聞或書籤中\n將數篇新聞打包成集錦',
                style: TextStyle(
                  color: readrBlack30,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () => Get.to(() => ChooseStoryPage()),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary: readrBlack87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: const Text(
                  '立即嘗試',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: homeScreenBackgroundColor,
        child: const Center(
          child: Text(
            '這個人還沒有建立集錦',
            style: TextStyle(
              color: readrBlack30,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
