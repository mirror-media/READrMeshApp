import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/commentCount/commentCount_cubit.dart';
import 'package:readr/blocs/config/bloc.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/services/homeScreenService.dart';
import 'helpers/router/router.dart';

class ReadrApp extends StatelessWidget {
  final _appRouter = AppRouter();
  final _pickButtonCubit = PickButtonCubit();
  final _followButtonCubit = FollowButtonCubit();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _pickButtonCubit,
        ),
        BlocProvider(
          create: (context) => _followButtonCubit,
        ),
        BlocProvider(
          create: (context) => CommentCountCubit(_pickButtonCubit),
        ),
        BlocProvider(
          create: (context) => ConfigBloc(),
        ),
        BlocProvider(
          create: (context) => HomeBloc(
              followButtonCubit: _followButtonCubit,
              homeScreenRepos: HomeScreenService()),
        ),
      ],
      child: MaterialApp.router(
        routeInformationParser: _appRouter.defaultRouteParser(),
        routerDelegate: _appRouter.delegate(),
        title: 'READr Mesh',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
      ),
    );
  }
}
