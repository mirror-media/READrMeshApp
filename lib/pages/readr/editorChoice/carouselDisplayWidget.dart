import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/pages/shared/news/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/story/storyPage.dart';

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
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: readrBlack,
              child: Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  FadeIn(
                    key: UniqueKey(),
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      color: readrBlack,
                      child: _displayImage(context.width, editorChoiceItem),
                    ),
                  ),
                  if (editorChoiceItem.isProject) _displayTag(),
                ],
              ),
            ),
            _displayTitle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NewsInfo(editorChoiceItem.newsListItem!),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: PickBar(
                editorChoiceItem.newsListItem!.controllerTag,
                showPickTooltip: true,
              ),
            ),
          ],
        ),
      ),
      onTap: () => Get.to(
        () => StoryPage(
          news: editorChoiceItem.newsListItem!,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _displayTitle() {
    return Container(
      color: editorChoiceBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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

  Widget _displayImage(double width, EditorChoiceItem editorChoiceItem) {
    return editorChoiceItem.newsListItem!.heroImageUrl == null
        ? SvgPicture.asset(defaultImageSvg)
        : CachedNetworkImage(
            height: width / 2,
            width: width,
            imageUrl: editorChoiceItem.newsListItem!.heroImageUrl!,
            placeholder: (context, url) => Container(
              height: width / 2,
              width: width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: width / 2,
              width: width,
              color: Colors.grey,
              child: const Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          );
  }

  Widget _displayTag() {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Container(
        decoration: BoxDecoration(
          color: editorChoiceTagColor,
          borderRadius: BorderRadiusDirectional.circular(6),
        ),
        margin: const EdgeInsets.only(
          top: 8,
          right: 12,
        ),
        height: 24,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        alignment: Alignment.center,
        child: Text(
          'topic'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}
