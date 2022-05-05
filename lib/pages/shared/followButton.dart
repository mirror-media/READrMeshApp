import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';

import 'package:readr/models/followableItem.dart';
import 'package:readr/pages/loginMember/loginPage.dart';

class FollowButton extends StatelessWidget {
  final FollowableItem item;
  final bool expanded;
  final double textSize;
  const FollowButton(
    this.item, {
    this.expanded = false,
    this.textSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowButtonCubit, FollowButtonState>(
      builder: (context, state) {
        bool _isFollowing = item.isFollowed;

        if (expanded) {
          return SizedBox(
            width: double.maxFinite,
            child: _buildButton(context, _isFollowing),
          );
        }
        return _buildButton(context, _isFollowing);
      },
    );
  }

  Widget _buildButton(BuildContext context, bool isFollowing) {
    return OutlinedButton(
      onPressed: () async {
        if (item.type == 'member' && Get.find<UserService>().isVisitor) {
          Get.to(
            () => const LoginPage(),
            fullscreenDialog: true,
          );
        } else {
          context.read<FollowButtonCubit>().updateLocalFollowing(item);
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: readrBlack87, width: 1),
        backgroundColor: isFollowing ? readrBlack87 : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      ),
      child: Text(
        isFollowing ? '追蹤中' : '追蹤',
        maxLines: 1,
        style: TextStyle(
          fontSize: textSize,
          color: isFollowing ? Colors.white : readrBlack87,
        ),
      ),
    );
  }
}
