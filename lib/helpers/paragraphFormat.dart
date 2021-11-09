import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embedded_webview/flutter_embedded_webview.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/contentList.dart';
import 'package:readr/models/paragraph.dart';
import 'package:readr/pages/story/widgets/annotationWidget.dart';
import 'package:readr/pages/story/widgets/blockQuoteWidget.dart';
import 'package:readr/pages/story/widgets/imageAndDescriptionSlideShowWidget.dart';
import 'package:readr/pages/story/widgets/imageDescriptionWidget.dart';
import 'package:readr/pages/story/widgets/infoBoxWidget.dart';
import 'package:readr/pages/story/widgets/mNewsAudioPlayer.dart';
import 'package:readr/pages/story/widgets/mNewsVideoPlayer.dart';
import 'package:readr/pages/story/widgets/parseTheTextToHtmlWidget.dart';
import 'package:readr/pages/story/widgets/quoteByWidget.dart';
import 'package:readr/pages/story/widgets/youtubeWidget.dart';

class ParagraphFormat {
  bool _isCitation = false;
  Widget parseTheParagraph(
    Paragraph? paragraph,
    BuildContext context,
    double textSize, {
    bool isCitation = false,
  }) {
    if (paragraph == null) {
      return Container();
    }
    _isCitation = isCitation;

    switch (paragraph.type) {
      case 'header-one':
        {
          if (paragraph.contents!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ParseTheTextToHtmlWidget(
                html: '<h1>' + paragraph.contents![0].data + '</h1>',
                fontSize: textSize,
              ),
            );
          }
          return Container();
        }
      case 'header-two':
        {
          if (paragraph.contents!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ParseTheTextToHtmlWidget(
                html: '<h2>' + paragraph.contents![0].data + '</h2>',
                fontSize: textSize,
              ),
            );
          }
          return Container();
        }
      case 'code-block':
      case 'unstyled':
        {
          if (paragraph.contents!.isNotEmpty) {
            if (_isCitation) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  children: [
                    ParseTheTextToHtmlWidget(
                      html: paragraph.contents![0].data,
                      fontSize: textSize,
                    )
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ParseTheTextToHtmlWidget(
                html: paragraph.contents![0].data,
                fontSize: textSize,
              ),
            );
          }
          return Container();
        }
      case 'ordered-list-item':
        {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: buildOrderListWidget(paragraph.contents!, textSize),
          );
        }
      case 'unordered-list-item':
        {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: buildUnorderListWidget(paragraph.contents!, textSize),
          );
        }
      case 'image':
        {
          var width = MediaQuery.of(context).size.width;
          if (paragraph.contents!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: ImageDescriptionWidget(
                imageUrl: paragraph.contents![0].data,
                description: paragraph.contents![0].description,
                width: width,
                textSize: 13,
              ),
            );
          }

          return Container();
        }
      case 'slideshow':
        {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ImageAndDescriptionSlideShowWidget(
                contentList: paragraph.contents!, textSize: textSize),
          );
        }
      case 'annotation':
        {
          if (paragraph.contents!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnnotationWidget(
                data: paragraph.contents![0].data,
                textSize: textSize,
              ),
            );
          }
          return Container();
        }
      case 'blockquote':
        {
          if (paragraph.contents!.isNotEmpty) {
            if (_isCitation) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ParseTheTextToHtmlWidget(
                  html: paragraph.contents![0].data,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlockQuoteWidget(
                content: paragraph.contents![0].data,
                textSize: textSize,
              ),
            );
          }
          return Container();
        }
      case 'quoteby':
        {
          if (paragraph.contents!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: QuoteByWidget(
                quote: paragraph.contents![0].data,
                quoteBy: paragraph.contents![0].description,
                textSize: textSize,
              ),
            );
          }
          return Container();
        }
      case 'infobox':
        {
          if (paragraph.contents!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InfoBoxWidget(
                title: paragraph.contents![0].description ?? '',
                description: paragraph.contents![0].data,
                textSize: textSize,
              ),
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MNewsAudioPlayer(
                audioUrl: paragraph.contents![0].data,
                title: titleAndDescription,
                textSize: textSize,
              ),
            );
          }
          return Container();
        }
      case 'youtube':
        {
          if (paragraph.contents!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: YoutubeWidget(
                youtubeId: paragraph.contents![0].data,
                description: paragraph.contents![0].description,
                textSize: textSize,
              ),
            );
          }
          return Container();
        }
      case 'embeddedcode':
        {
          if (paragraph.contents!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: EmbeddedCodeWidget(
                embeddedCode: paragraph.contents![0].data,
                aspectRatio: paragraph.contents![0].aspectRatio,
              ),
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
        if (_isCitation) {
          if (dataList.length > 1 && index != dataList.length - 1) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParseTheTextToHtmlWidget(
                  html: dataList[index],
                  fontSize: textSize,
                ),
                const Divider(
                  color: Color.fromRGBO(0, 9, 40, 0.1),
                  thickness: 1,
                ),
              ],
            );
          }
          return ParseTheTextToHtmlWidget(
            html: dataList[index],
            fontSize: textSize,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, textSize - 3, 0, 8),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: storyWidgetColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
