import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/initControllerBinding.dart';
import 'package:readr/initialApp.dart';
import 'package:readr/services/homeScreenService.dart';

class ReadrApp extends StatelessWidget {
  final _followButtonCubit = FollowButtonCubit();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _followButtonCubit,
        ),
        BlocProvider(
          create: (context) => HomeBloc(
              followButtonCubit: _followButtonCubit,
              homeScreenRepos: HomeScreenService()),
        ),
      ],
      child: GetMaterialApp(
        title: 'READr Mesh',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        initialBinding: InitControllerBinding(),
        home: InitialApp(),
      ),
    );
  }
}
