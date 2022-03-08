import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/blocs/readr/editorChoice/editorChoice_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/openProjectHelper.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/readr/editorChoice/carouselDisplayWidget.dart';
import 'package:shimmer/shimmer.dart';

class BuildEditorChoiceCarousel extends StatefulWidget {
  @override
  _BuildEditorChoiceCarouselState createState() =>
      _BuildEditorChoiceCarouselState();
}

class _BuildEditorChoiceCarouselState extends State<BuildEditorChoiceCarousel> {
  @override
  void initState() {
    _loadEditorChoice();
    super.initState();
  }

  _loadEditorChoice() {
    context.read<EditorChoiceCubit>().fetchEditorChoice();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorChoiceCubit, EditorChoiceState>(
      builder: (BuildContext context, EditorChoiceState state) {
        if (state is EditorChoiceError) {
          print('EditorChoiceError: ${state.error}');
          return Container();
        }

        if (state is EditorChoiceLoaded) {
          List<EditorChoiceItem> editorChoiceList = state.editorChoiceList;

          if (editorChoiceList.isEmpty) {
            return Container();
          }

          List<StoryPick> storyPickList = [];
          for (int i = 0; i < editorChoiceList.length; i++) {
            storyPickList.add(StoryPick(editorChoiceList[i].newsListItem!.id,
                editorChoiceList[i].newsListItem!.myPickId));
          }
          return EditorChoiceCarousel(
            editorChoiceList: editorChoiceList,
            storyPickList: storyPickList,
            aspectRatio: 4 / 3.2,
          );
        }

        // state is Init, loading, or other
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    height: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: Container(
                  height: 187.5,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              Shimmer.fromColors(
                baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Container(
                          height: 32,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditorChoiceCarousel extends StatefulWidget {
  final List<EditorChoiceItem> editorChoiceList;
  final List<StoryPick> storyPickList;
  final double aspectRatio;
  const EditorChoiceCarousel({
    required this.editorChoiceList,
    required this.storyPickList,
    this.aspectRatio = 16 / 9,
  });

  @override
  _EditorChoiceCarouselState createState() => _EditorChoiceCarouselState();
}

class _EditorChoiceCarouselState extends State<EditorChoiceCarousel> {
  final CarouselController _controller = CarouselController();
  int _current = 0;
  final double aspectRatio = 16 / 9;
  final ChromeSafariBrowser browser = ChromeSafariBrowser();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (widget.editorChoiceList.isEmpty) {
      return Container();
    }
    List<Widget> items = [];
    for (int i = 0; i < widget.editorChoiceList.length; i++) {
      items.add(CarouselDisplayWidget(
        editorChoiceItem: widget.editorChoiceList[i],
        width: width,
        storyPick: widget.storyPickList[i],
      ));
    }
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: GestureDetector(
            onTap: () async {},
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  FadeIn(
                    key: UniqueKey(),
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      color: Colors.black,
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
            height: 176,
          ),
        ),
        const Divider(
          color: Colors.black12,
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
                      color: _current == entry.key
                          ? Colors.black87
                          : Colors.black12),
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
            height: 300,
            width: width,
            imageUrl: editorChoiceItem.newsListItem!.heroImageUrl!,
            placeholder: (context, url) => Container(
              height: width / aspectRatio,
              width: width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: width / aspectRatio,
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
