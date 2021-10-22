import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/contentList.dart';
import 'package:readr/models/paragraph.dart';
import 'package:readr/widgets/story/annotationWidget.dart';
import 'package:readr/widgets/story/blockQuoteWidget.dart';
import 'package:readr/widgets/story/embeddedCodeWidget.dart';
import 'package:readr/widgets/story/imageAndDescriptionSlideShowWidget.dart';
import 'package:readr/widgets/story/imageDescriptionWidget.dart';
import 'package:readr/widgets/story/infoBoxWidget.dart';
import 'package:readr/widgets/story/mNewsAudioPlayer.dart';
import 'package:readr/widgets/story/mNewsVideoPlayer.dart';
import 'package:readr/widgets/story/parseTheTextToHtmlWidget.dart';
import 'package:readr/widgets/story/quoteByWidget.dart';
import 'package:readr/widgets/story/youtubeWidget.dart';

class ParagraphFormat {
  Widget parseTheParagraph(
      Paragraph? paragraph, BuildContext context, double textSize) {
    if (paragraph == null) {
      return Container();
    }

    switch (paragraph.type) {
      case 'header-one':
        {
          if (paragraph.contents!.isNotEmpty) {
            return ParseTheTextToHtmlWidget(
              html: '<h1>' + paragraph.contents![0].data + '</h1>',
              fontSize: textSize,
            );
          }
          return Container();
        }
      case 'header-two':
        {
          if (paragraph.contents!.isNotEmpty) {
            return ParseTheTextToHtmlWidget(
              html: '<h2>' + paragraph.contents![0].data + '</h2>',
              fontSize: textSize,
            );
          }
          return Container();
        }
      case 'code-block':
      case 'unstyled':
        {
          if (paragraph.contents!.isNotEmpty) {
            return ParseTheTextToHtmlWidget(
              html: paragraph.contents![0].data,
              fontSize: textSize,
            );
          }
          return Container();
        }
      case 'ordered-list-item':
        {
          return buildOrderListWidget(paragraph.contents!, textSize);
        }
      case 'unordered-list-item':
        {
          return buildUnorderListWidget(paragraph.contents!, textSize);
        }
      case 'image':
        {
          var width = MediaQuery.of(context).size.width - 48;
          if (paragraph.contents!.isNotEmpty) {
            return ImageDescriptionWidget(
              imageUrl: paragraph.contents![0].data,
              description: paragraph.contents![0].description,
              width: width,
              textSize: textSize - 4,
            );
          }

          return Container();
        }
      case 'slideshow':
        {
          return ImageAndDescriptionSlideShowWidget(
              contentList: paragraph.contents!, textSize: textSize);
        }
      case 'annotation':
        {
          if (paragraph.contents!.isNotEmpty) {
            return AnnotationWidget(
              data: paragraph.contents![0].data,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'blockquote':
        {
          if (paragraph.contents!.isNotEmpty) {
            return BlockQuoteWidget(
              content: paragraph.contents![0].data,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'quoteby':
        {
          if (paragraph.contents!.isNotEmpty) {
            return QuoteByWidget(
              quote: paragraph.contents![0].data,
              quoteBy: paragraph.contents![0].description,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'infobox':
        {
          if (paragraph.contents!.isNotEmpty) {
            return InfoBoxWidget(
              title: paragraph.contents![0].description ?? '',
              description: paragraph.contents![0].data,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'video':
        {
          if (paragraph.contents!.isNotEmpty) {
            return MNewsVideoPlayer(
              videourl: paragraph.contents![0].data,
              aspectRatio: 16 / 9,
            );
          }
          return Container();
        }
      case 'audio':
        {
          if (paragraph.contents!.isNotEmpty) {
            String? titleAndDescription;
            if (paragraph.contents![0].description != null) {
              titleAndDescription =
                  paragraph.contents![0].description!.split(';')[0];
            }

            return MNewsAudioPlayer(
              audioUrl: paragraph.contents![0].data,
              title: titleAndDescription,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'youtube':
        {
          if (paragraph.contents!.isNotEmpty) {
            return YoutubeWidget(
              youtubeId: paragraph.contents![0].data,
              description: paragraph.contents![0].description,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'embeddedcode':
        {
          if (paragraph.contents!.isNotEmpty) {
            return EmbeddedCodeWidget(
              embeddedCoede: paragraph.contents![0].data,
              aspectRatio: paragraph.contents![0].aspectRatio,
            );
          }
          return Container();
        }
      default:
        {
          return Container();
        }
    }
  }

  List<String?> _convertStrangeDataList(ContentList contentList) {
    List<String?> resultList = List.empty(growable: true);
    if (contentList.length == 1 && contentList[0].data[0] == '[') {
      // api data is strange [[...]]
      String dataString =
          contentList[0].data.substring(1, contentList[0].data.length - 1);
      resultList = dataString.split(', ');
    } else {
      for (var content in contentList) {
        resultList.add(content.data);
      }
    }
    return resultList;
  }

  Widget buildOrderListWidget(ContentList contentList, double textSize) {
    List<String?> dataList = _convertStrangeDataList(contentList);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (index + 1).toString() + '.',
              style: TextStyle(
                fontSize: textSize,
                height: 1.8,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: ParseTheTextToHtmlWidget(
                    html: dataList[index], fontSize: textSize)),
          ],
        );
      },
    );
  }

  Widget buildUnorderListWidget(ContentList contentList, double textSize) {
    List<String?> dataList = _convertStrangeDataList(contentList);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: storyWidgetColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: ParseTheTextToHtmlWidget(
              html: dataList[index],
              fontSize: textSize,
            )),
          ],
        );
      },
    );
  }
}
