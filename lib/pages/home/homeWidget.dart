import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/blocs/editorChoice/bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/shared/editorChoice/editorChoiceCarousel.dart';
import 'package:readr/services/editorChoiceService.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: SvgPicture.asset(
              logoSimplifySvg,
            ),
            collapsedHeight: 600,
            flexibleSpace: BlocProvider(
              create: (context) => EditorChoiceBloc(
                editorChoiceRepos: EditorChoiceServices(),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: BuildEditorChoiceCarousel(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
