import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';

class PickBar extends StatelessWidget {
  final PickableItem item;
  const PickBar(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickButtonCubit, PickButtonState>(
      builder: (context, state) {
        bool isPicked = item.isPicked;
        int pickCountData = item.pickCount;

        List<Member> pickedMemberList = [];
        pickedMemberList.addAll(item.pickedMemberList);

        if (isPicked && pickedMemberList.length < 4) {
          pickedMemberList.add(UserHelper.instance.currentUser);
        }

        List<Widget> bottom = [];
        if (pickCountData <= 0) {
          bottom.add(const Text(
            '尚無人精選',
            style: TextStyle(fontSize: 13, color: readrBlack50),
          ));
        } else {
          bottom.add(ProfilePhotoStack(pickedMemberList, 14));
          bottom.add(const SizedBox(width: 8));
          bottom.add(RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: pickCountData.toString(),
              style: const TextStyle(
                fontSize: 13,
                color: readrBlack,
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(
                  text: ' 人精選',
                  style: TextStyle(
                    fontSize: 13,
                    color: readrBlack50,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ));
        }
        bottom.addAll([
          const Spacer(),
          PickButton(
            item,
          ),
        ]);

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: bottom,
        );
      },
    );
  }
}
