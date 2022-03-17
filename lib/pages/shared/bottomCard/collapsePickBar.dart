import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';

class CollapsePickBar extends StatelessWidget {
  final PickableItem item;
  const CollapsePickBar(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickButtonCubit, PickButtonState>(
      builder: (context, state) {
        int pickCountData = item.pickCount;
        int commentCountData = item.commentCount;

        return Row(
          children: [
            AutoSizeText.rich(
              TextSpan(
                text: commentCountData.toString(),
                style: const TextStyle(
                  color: readrBlack87,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(
                    text: ' 則留言',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              style: const TextStyle(fontSize: 13),
            ),
            Container(
              width: 2,
              height: 2,
              margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black26,
              ),
            ),
            AutoSizeText.rich(
              TextSpan(
                text: pickCountData.toString(),
                style: const TextStyle(
                  color: readrBlack87,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(
                    text: ' 人精選',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const Spacer(),
            PickButton(
              item,
            ),
          ],
        );
      },
    );
  }
}
