import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:easy_debounce/easy_debounce.dart';

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
        if (item.type == 'member' && UserHelper.instance.isVisitor) {
          AutoRouter.of(context).push(LoginRoute());
        } else {
          context.read<FollowButtonCubit>().updateLocalFollowing(item);
          EasyDebounce.debounce(item.id, const Duration(seconds: 2),
              () => context.read<FollowButtonCubit>().updateFollowing(item));
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1),
        backgroundColor: isFollowing ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      ),
      child: Text(
        isFollowing ? '追蹤中' : '追蹤',
        maxLines: 1,
        style: TextStyle(
          fontSize: textSize,
          color: isFollowing ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
