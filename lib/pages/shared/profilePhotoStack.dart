import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';

class ProfilePhotoStack extends StatelessWidget {
  final List<Member> members;
  final double radius;
  const ProfilePhotoStack(this.members, this.radius, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Container();
    }
    double padding = radius + 2;
    List<Widget> headShots = [];
    for (int i = 0; i < members.length && i < 4; i++) {
      if (i == 0) {
        headShots.add(ProfilePhotoWidget(
          members[i],
          radius,
          key: ValueKey(members[i].memberId),
        ));
      } else {
        headShots.add(Padding(
          padding: EdgeInsets.only(left: padding),
          child: ProfilePhotoWidget(
            members[i],
            radius,
            key: ValueKey(members[i].memberId),
          ),
        ));
        padding = padding + radius;
      }
    }
    return Stack(
      alignment: Alignment.centerLeft,
      children: headShots.reversed.toList(),
    );
  }
}
