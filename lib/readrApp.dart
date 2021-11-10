import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'helpers/router/router.dart';

class ReadrApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate(),
      title: 'readr',
      theme: ThemeData(
        primaryColor: const Color(0xffEBF02C),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // appBarTheme: const AppBarTheme(
        //   systemOverlayStyle: SystemUiOverlayStyle.light,
        // ),
      ),
    );
  }
}
