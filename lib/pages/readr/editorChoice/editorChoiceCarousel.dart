import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/pages/readr/editorChoice/carouselDisplayWidget.dart';
import 'package:readr/pages/shared/nativeAdWidget.dart';

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
    items.add(NativeAdWidget(
      key: const Key('listingREADr_slideshow'),
      adUnitIdKey: 'listingREADr_slideshow',
      factoryId: 'slideshow',
      adHeight: width / 2 + 186,
    ));
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
            height: 186 + context.width / 2,
          ),
        ),
        const Divider(
          thickness: 0.5,
          height: 0.5,
        ),
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.asMap().entries.map((entry) {
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
                    color: _current == entry.key
                        ? Theme.of(context)
                            .extension<CustomColors>()!
                            .primary700!
                        : Theme.of(context)
                            .extension<CustomColors>()!
                            .primary200!,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
