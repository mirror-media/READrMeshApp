import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';

class CarouselDisplayWidget extends StatelessWidget {
  final EditorChoiceItem editorChoiceItem;
  const CarouselDisplayWidget({
    required this.editorChoiceItem,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.grey[100],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _displayTitle(),
            const SizedBox(height: 8),
            BlocBuilder<PickButtonCubit, PickButtonState>(
              builder: (context, state) => NewsInfo(
                editorChoiceItem.newsListItem!,
                commentCount: NewsListItemPick(editorChoiceItem.newsListItem!)
                    .commentCount,
              ),
            ),
            const SizedBox(height: 18),
            PickBar(NewsListItemPick(editorChoiceItem.newsListItem!)),
          ],
        ),
      ),
      onTap: () async {
        AutoRouter.of(context).push(NewsStoryRoute(
          news: editorChoiceItem.newsListItem!,
        ));
      },
    );
  }

  Widget _displayTitle() {
    return Container(
      color: editorChoiceBackgroundColor,
      child: Text(
        editorChoiceItem.newsListItem!.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
