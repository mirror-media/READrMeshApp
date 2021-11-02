import 'package:auto_route/auto_route.dart';
import 'package:readr/pages/category/categoryPage.dart';
import 'package:readr/pages/home/homeWidget.dart';
import 'package:flutter/material.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:readr/initialApp.dart';

part 'router.gr.dart';

// Run after edited:
// flutter packages pub run build_runner build
// If has conflict, delete router.gr.dart first
@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(name: 'initial', page: InitialApp, initial: true, children: [
      AutoRoute(
        path: "homeWidget",
        name: "HomeRouter",
        page: HomeWidget,
      ),
      AutoRoute(
        path: "category",
        name: "CategoryRouter",
        page: CategoryPage,
      ),
    ]),
    AutoRoute(page: StoryPage),
  ],
)
// extend the generated private router
class AppRouter extends _$AppRouter {}
