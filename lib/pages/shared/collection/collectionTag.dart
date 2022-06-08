import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/helpers/dataConstants.dart';

class CollectionTag extends StatelessWidget {
  const CollectionTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: readrBlack66,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            collectionTagSvg,
            color: Colors.white,
          ),
          const SizedBox(
            width: 5,
          ),
          const Text(
            '集錦',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}