import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';

class PickButton extends StatelessWidget {
  final PickableItem item;
  final bool expanded;
  final double textSize;
  const PickButton(
    this.item, {
    this.expanded = false,
    this.textSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    return BlocConsumer<PickButtonCubit, PickButtonState>(
      listener: (context, state) {
        if (state is PickButtonUpdateSuccess) {
          PickToast.showPickToast(context, true, item.isPicked);
        }

        if (state is PickButtonUpdateFailed) {
          PickToast.showPickToast(context, false, state.originIsPicked);
        }
      },
      builder: (context, state) {
        bool isPicked = item.isPicked;

        if (expanded) {
          return SizedBox(
            width: double.maxFinite,
            child: _buildButton(context, isPicked, isLoading),
          );
        }
        return _buildButton(context, isPicked, isLoading);
      },
    );
  }

  Widget _buildButton(BuildContext context, bool isPicked, bool isLoading) {
    return OutlinedButton(
      onPressed: isLoading
          ? null
          : () async {
              // check whether is login
              if (UserHelper.instance.isMember) {
                if (!isPicked) {
                  var result = await PickBottomSheet.showPickBottomSheet(
                    context: context,
                  );

                  if (result is String) {
                    context.read<PickButtonCubit>().updateButton(item, result);
                  } else if (result is bool && result) {
                    context.read<PickButtonCubit>().updateButton(item, null);
                  }
                } else {
                  context.read<PickButtonCubit>().updateButton(item, null);
                }
              } else {
                AutoRouter.of(context).push(LoginRoute());
              }
            },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: readrBlack87, width: 1),
        backgroundColor: isPicked ? readrBlack87 : Colors.white,
        padding: const EdgeInsets.fromLTRB(11, 3, 12, 4),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(
                isPicked ? Icons.done_outlined : Icons.add_outlined,
                size: textSize + 4,
                color: isPicked ? Colors.white : readrBlack87,
              ),
            ),
            TextSpan(
              text: isPicked ? '已精選' : '精選',
              style: TextStyle(
                fontSize: textSize,
                height: 1.9,
                color: isPicked ? Colors.white : readrBlack87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
