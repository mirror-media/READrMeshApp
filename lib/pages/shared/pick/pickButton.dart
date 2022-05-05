import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';

import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';

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
    return BlocBuilder<PickButtonCubit, PickButtonState>(
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
              if (Get.find<UserService>().isMember) {
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
                  bool? result = await showDialog<bool>(
                    context: context,
                    builder: (context) => PlatformAlertDialog(
                      title: const Text(
                        '確認移除精選？',
                      ),
                      content: const Text(
                        '移除精選文章，將會一併移除您的留言',
                      ),
                      actions: [
                        PlatformDialogAction(
                          child: const Text(
                            '移除',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () => Navigator.pop<bool>(context, true),
                        ),
                        PlatformDialogAction(
                          child: const Text(
                            '取消',
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () => Navigator.pop<bool>(context, false),
                        )
                      ],
                      material: (context, target) => MaterialAlertDialogData(
                        titleTextStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        contentTextStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(109, 120, 133, 1),
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  );
                  if (result != null && result) {
                    context.read<PickButtonCubit>().updateButton(item, null);
                  }
                }
              } else {
                Get.to(
                  () => const LoginPage(),
                  fullscreenDialog: true,
                );
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
