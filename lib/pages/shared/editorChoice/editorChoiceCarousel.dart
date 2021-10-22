import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/editorChoice/bloc.dart';
import 'package:readr/blocs/editorChoice/events.dart';
import 'package:readr/blocs/editorChoice/states.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/pages/shared/editorChoice/carouselDisplayWidget.dart';

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
    context.read<EditorChoiceBloc>().add(FetchEditorChoiceList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorChoiceBloc, EditorChoiceState>(
        builder: (BuildContext context, EditorChoiceState state) {
      if (state.status == EditorChoiceStatus.error) {
        final error = state.error;
        print('EditorChoiceError: ${error.message}');
        return Container();
      }
      if (state.status == EditorChoiceStatus.loaded) {
        List<EditorChoiceItem> editorChoiceList = state.editorChoiceList;

        if (editorChoiceList.isEmpty) {
          return Container();
        }
        return Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            EditorChoiceCarousel(
              editorChoiceList: editorChoiceList,
              aspectRatio: 4 / 3.2,
            ),
          ],
        );
      }

      // state is Init, loading, or other
      return Container();
    });
  }
}

class EditorChoiceCarousel extends StatefulWidget {
  final List<EditorChoiceItem> editorChoiceList;
  final double aspectRatio;
  const EditorChoiceCarousel({
    required this.editorChoiceList,
    this.aspectRatio = 16 / 9,
  });

  @override
  _EditorChoiceCarouselState createState() => _EditorChoiceCarouselState();
}

class _EditorChoiceCarouselState extends State<EditorChoiceCarousel> {
  final CarouselController _carouselController = CarouselController();
  late CarouselOptions _options;

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
    var height = width / widget.aspectRatio;
    if (height > 700) {
      height = 700;
    } else if (height > 500) {
      height = (height ~/ 100) * 100;
    }
    _options = CarouselOptions(
      viewportFraction: 1.0,
      aspectRatio: widget.aspectRatio,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 8),
      enlargeCenterPage: true,
      onPageChanged: (index, reason) {},
      height: height,
    );
    return widget.editorChoiceList.isEmpty
        ? Container()
        : Stack(
            children: [
              CarouselSlider(
                items: _imageSliders(width, widget.editorChoiceList),
                carouselController: _carouselController,
                options: _options,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  child: SizedBox(
                    width: width * 0.1,
                    height: height,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () {
                    _carouselController.previousPage();
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: SizedBox(
                    width: width * 0.1,
                    height: height,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    _carouselController.nextPage();
                  },
                ),
              ),
            ],
          );
  }

  List<Widget> _imageSliders(
      double width, List<EditorChoiceItem> editorChoiceList) {
    return editorChoiceList
        .map(
          (item) => CarouselDisplayWidget(
            editorChoiceItem: item,
            width: width,
          ),
        )
        .toList();
  }
}
