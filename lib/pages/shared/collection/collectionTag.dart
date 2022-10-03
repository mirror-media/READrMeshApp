import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';

class CollectionTag extends StatelessWidget {
  final bool smallTag;
  const CollectionTag({this.smallTag = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: meshBlack66,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: smallTag ? 4 : 6, vertical: smallTag ? 2.5 : 3.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PlatformIcons(context).folderOpen,
            color: Colors.white,
            size: smallTag ? 11 : 12,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            'collection'.tr,
            style: TextStyle(
              fontSize: smallTag ? 11 : 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
