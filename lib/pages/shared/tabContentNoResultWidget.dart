import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readr/helpers/dataConstants.dart';

class TabContentNoResultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(height: height / 10),
        Center(child: SvgPicture.asset(tabContentNoResultSvg)),
      ],
    );
  }
}
