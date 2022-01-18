import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/headShotWidget.dart';

class HeadShotStack extends StatelessWidget {
  final List<Member> members;
  final double radius;
  const HeadShotStack(this.members, this.radius);

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Container();
    }
    double padding = radius + 2;
    List<Widget> headShots = [];
    for (int i = 0; i < members.length && i < 4; i++) {
      if (i == 0) {
        headShots.add(HeadShotWidget(members[i], radius));
      } else {
        headShots.add(Padding(
          padding: EdgeInsets.only(left: padding),
          child: HeadShotWidget(members[i], radius),
        ));
        padding = padding + radius;
      }
    }
    return Stack(
      children: headShots.reversed.toList(),
      alignment: Alignment.centerLeft,
    );
  }
}
