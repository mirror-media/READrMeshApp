import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';

class CollectionTag extends StatelessWidget {
  final bool smallTag;
  const CollectionTag({this.smallTag = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: readrBlack66,
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
            CupertinoIcons.rectangle_on_rectangle_angled,
            color: Colors.white,
            size: smallTag ? 11 : 12,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            '集錦',
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
