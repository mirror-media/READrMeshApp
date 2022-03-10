import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';

class CollapsePickBar extends StatelessWidget {
  final PickableItem item;
  final int pickCount;
  final int commentCount;
  const CollapsePickBar(this.item, this.pickCount, this.commentCount,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPicked = item.pickId != null;
    int pickCountData = pickCount;
    int commentCountData = commentCount;
    bool hasPickComment = item.pickCommentId != null;
    return BlocConsumer<PickButtonCubit, PickButtonState>(
      listener: (context, state) {
        if (state is PickButtonUpdateSuccess) {
          if (state.type == item.type && state.targetId == item.targetId) {
            item.updateId(state.pickId, state.commentId);
            hasPickComment = state.commentId != null;
            pickCountData = state.pickCount;
          }
        }
      },
      builder: (context, state) {
        if (state is PickButtonUpdating) {
          if (state.type == item.type && state.targetId == item.targetId) {
            isPicked = state.isPicked;
            if (isPicked && state.pickComment != null) {
              commentCountData++;
              hasPickComment = true;
            } else if (hasPickComment) {
              commentCountData--;
            }
            pickCountData = state.pickCount;
          }
        }

        if (state is PickButtonUpdateFailed) {
          if (state.type == item.type && state.targetId == item.targetId) {
            isPicked = state.originIsPicked;
            if (isPicked && hasPickComment) {
              commentCountData++;
              hasPickComment = true;
            } else if (hasPickComment) {
              commentCountData--;
            }
            item.updateId(state.pickId, state.commentId);
            hasPickComment = state.commentId != null;
            pickCountData = state.pickCount;
          }
        }

        return Row(
          children: [
            AutoSizeText.rich(
              TextSpan(
                text: commentCountData.toString(),
                style: const TextStyle(
                  color: Colors.black87,
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
                  color: Colors.black87,
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
