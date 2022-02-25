import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';

class CollectionTabContent extends StatefulWidget {
  final Member viewMember;
  final bool isMine;
  const CollectionTabContent({
    required this.viewMember,
    required this.isMine,
  });
  @override
  _CollectionTabContentState createState() => _CollectionTabContentState();
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
                  color: Colors.black26,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  '立即嘗試',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
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
              color: Colors.black26,
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
