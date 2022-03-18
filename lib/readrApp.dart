import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/commentCount/commentCount_cubit.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'helpers/router/router.dart';

class ReadrApp extends StatelessWidget {
  final _appRouter = AppRouter();
  final _pickButtonCubit = PickButtonCubit();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _pickButtonCubit,
        ),
        BlocProvider(
          create: (context) => FollowButtonCubit(),
        ),
        BlocProvider(
          create: (context) => CommentCountCubit(_pickButtonCubit),
        ),
      ],
      child: MaterialApp.router(
        routeInformationParser: _appRouter.defaultRouteParser(),
        routerDelegate: _appRouter.delegate(),
        title: 'readr',
        theme: ThemeData(
          primaryColor: const Color(0xffEBF02C),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
      ),
    );
  }
}
