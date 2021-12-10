import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/openProjectHelper.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/editorChoiceItem.dart';

class CarouselDisplayWidget extends StatelessWidget {
  final EditorChoiceItem editorChoiceItem;
  final double width;
  const CarouselDisplayWidget({
    required this.editorChoiceItem,
    required this.width,
  });

  final double aspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.grey[100],
      child: Column(
        children: [
          const SizedBox(
            height: 16.0,
          ),
          Container(
            height: 141,
            padding: const EdgeInsets.only(left: 8),
            decoration: const BoxDecoration(
              color: Color(0xffEBF02C),
            ),
            child: Container(
              height: 141,
              color: Colors.white,
              child: Column(
                children: [
                  _displayTitle(editorChoiceItem),
                  _displaySummary(editorChoiceItem),
                  _displayTimeAndReadingTime(editorChoiceItem),
                ],
              ),
            ),
          ),
        ],
      ),
      onTap: () async {
        if (editorChoiceItem.isProject) {
          OpenProjectHelper().phaseByEditorChoiceItem(editorChoiceItem);
        } else {
          if (editorChoiceItem.id != null) {
            AutoRouter.of(context).push(StoryRoute(id: editorChoiceItem.id!));
          } else if (editorChoiceItem.link != null) {
            OpenProjectHelper().openByUrl(editorChoiceItem.link!);
          }
        }
      },
    );
  }

  Widget _displayTitle(EditorChoiceItem editorChoiceItem) {
    return Container(
      color: editorChoiceBackgroundColor,
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 16.0, 0.0),
      alignment: Alignment.center,
      child: RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
          text: editorChoiceItem.name,
        ),
      ),
    );
  }

  Widget _displaySummary(EditorChoiceItem editorChoiceItem) {
    return editorChoiceItem.summary == null
        ? Container(
            color: editorChoiceBackgroundColor,
          )
        : Container(
            color: editorChoiceBackgroundColor,
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 0.0),
            alignment: Alignment.center,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15.0,
                ),
                text: editorChoiceItem.summary!,
              ),
            ),
          );
  }

  Widget _displayTimeAndReadingTime(EditorChoiceItem editorChoiceItem) {
    TextStyle style = const TextStyle(
      fontSize: 12,
      color: Colors.black54,
    );
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 12),
      color: editorChoiceBackgroundColor,
      child: Row(
        children: [
          Text(editorChoiceItem.publishTimeString, style: style),
          Text(
            '・閱讀時間 ${editorChoiceItem.readingTime.toString()} 分鐘',
            style: style,
          ),
        ],
      ),
    );
  }
}
