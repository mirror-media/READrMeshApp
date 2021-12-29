import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/readr/categories/bloc.dart';
import 'package:readr/blocs/config/bloc.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/services/categoryService.dart';
import 'package:readr/services/configService.dart';

class InitialApp extends StatefulWidget {
  @override
  _InitialAppState createState() => _InitialAppState();
}

class _InitialAppState extends State<InitialApp> {
  @override
  void initState() {
    super.initState();
    DynamicLinkHelper().initDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConfigBloc(configRepos: ConfigServices()),
        ),
        BlocProvider(
          create: (context) =>
              CategoriesBloc(categoryRepos: CategoryServices()),
        ),
      ],
      child: RootPage(),
    );
  }
}
