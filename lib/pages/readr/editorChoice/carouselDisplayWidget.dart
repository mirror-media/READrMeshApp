import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/story/newsStoryPage.dart';

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
            NewsInfo(editorChoiceItem.newsListItem!),
            const SizedBox(height: 18),
            PickBar(NewsListItemPick(editorChoiceItem.newsListItem!)),
          ],
        ),
      ),
      onTap: () => Get.to(
        () => NewsStoryPage(
          news: editorChoiceItem.newsListItem!,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _displayTitle() {
    return Container(
      color: editorChoiceBackgroundColor,
      child: AutoSizeText(
        editorChoiceItem.newsListItem!.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        minFontSize: 20,
        style: const TextStyle(
          color: readrBlack87,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
