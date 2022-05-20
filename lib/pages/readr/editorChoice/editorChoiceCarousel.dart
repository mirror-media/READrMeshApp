import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/pages/readr/editorChoice/carouselDisplayWidget.dart';
import 'package:readr/pages/story/storyPage.dart';

class EditorChoiceCarousel extends StatefulWidget {
  final List<EditorChoiceItem> editorChoiceList;
  final double width;
  const EditorChoiceCarousel({
    required this.editorChoiceList,
    required this.width,
  });

  @override
  State<EditorChoiceCarousel> createState() => _EditorChoiceCarouselState();
}

class _EditorChoiceCarouselState extends State<EditorChoiceCarousel> {
  final CarouselController _controller = CarouselController();
  int _current = 0;
  final double aspectRatio = 16 / 9;
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  late double width;
  final List<Widget> items = [];

  @override
  void initState() {
    super.initState();
    width = widget.width;
    for (int i = 0; i < widget.editorChoiceList.length; i++) {
      items.add(CarouselDisplayWidget(
        editorChoiceItem: widget.editorChoiceList[i],
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editorChoiceList.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.to(
            () => StoryPage(
              news: widget.editorChoiceList[_current].newsListItem!,
            ),
            fullscreenDialog: true,
          ),
          child: Container(
            color: readrBlack,
            child: Stack(
              children: [
                FadeIn(
                  key: UniqueKey(),
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    color: readrBlack,
                    child: _displayImage(
                        width, widget.editorChoiceList.elementAt(_current)),
                  ),
                ),
                if (widget.editorChoiceList.elementAt(_current).isProject)
                  Container(
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(
                      top: 16,
                      right: 12,
                    ),
                    child: _displayTag(),
                  ),
              ],
            ),
          ),
        ),
        CarouselSlider(
          items: items,
          carouselController: _controller,
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
            height: 186,
          ),
        ),
        const Divider(
          color: readrBlack10,
          thickness: 0.5,
          height: 0.5,
        ),
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.editorChoiceList.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.only(
                    left: 4.0,
                    right: 4.0,
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _current == entry.key ? readrBlack87 : readrBlack10),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
    return Container(
      decoration: BoxDecoration(
        color: editorChoiceTagColor,
        borderRadius: BorderRadiusDirectional.circular(6),
      ),
      height: 24,
      width: 40,
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: Text(
          '專題',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
