import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/config/bloc.dart';
import 'package:readr/pages/homePage.dart';
import 'package:readr/services/configService.dart';

class InitialApp extends StatefulWidget {
  @override
  _InitialAppState createState() => _InitialAppState();
}

class _InitialAppState extends State<InitialApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConfigBloc(configRepos: ConfigServices()),
      child: HomePage(),
    );
  }
}
