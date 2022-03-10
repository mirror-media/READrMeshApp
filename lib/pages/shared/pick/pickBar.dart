import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';

class PickBar extends StatelessWidget {
  final PickableItem item;
  final int pickCount;
  const PickBar(this.item, this.pickCount, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPicked = item.pickId != null;
    int pickCountData = pickCount;

    return BlocConsumer<PickButtonCubit, PickButtonState>(
      listener: (context, state) {
        if (state is PickButtonUpdateSuccess) {
          if (state.type == item.type && state.targetId == item.targetId) {
            item.updateId(state.pickId, state.commentId);
            pickCountData = state.pickCount;
          }
        }
      },
      builder: (context, state) {
        if (state is PickButtonUpdating) {
          if (state.type == item.type && state.targetId == item.targetId) {
            isPicked = state.isPicked;
            pickCountData = state.pickCount;
          }
        }

        if (state is PickButtonUpdateFailed) {
          if (state.type == item.type && state.targetId == item.targetId) {
            isPicked = state.originIsPicked;
            item.updateId(state.pickId, state.commentId);
            pickCountData = state.pickCount;
          }
        }

        List<Member> pickedMemberList = [];
        pickedMemberList.addAll(item.pickedMemberList);

        if (isPicked && pickedMemberList.length < 4) {
          pickedMemberList.add(UserHelper.instance.currentUser);
        }

        List<Widget> bottom = [];
        if (pickCountData <= 0) {
          bottom = [
            const Text(
              '尚無人精選',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            Expanded(
              child: Container(),
            ),
            PickButton(
              item,
            ),
          ];
        } else {
          bottom = [
            ProfilePhotoStack(pickedMemberList, 14),
            const SizedBox(width: 8),
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: pickCountData.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(
                    text: ' 人精選',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            PickButton(
              item,
            ),
          ];
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: bottom,
        );
      },
    );
  }
}
