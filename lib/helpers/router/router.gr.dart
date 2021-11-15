// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

part of 'router.dart';

class _$AppRouter extends RootStackRouter {
  _$AppRouter([GlobalKey<NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, PageFactory> pagesMap = {
    Initial.name: (routeData) {
      return MaterialPageX<dynamic>(routeData: routeData, child: InitialApp());
    },
    StoryRoute.name: (routeData) {
      final args = routeData.argsAs<StoryRouteArgs>();
      return MaterialPageX<dynamic>(
          routeData: routeData, child: StoryPage(id: args.id));
    },
    ErrorRoute.name: (routeData) {
      final args = routeData.argsAs<ErrorRouteArgs>();
      return MaterialPageX<dynamic>(
          routeData: routeData,
          child: ErrorPage(
              error: args.error,
              onPressed: args.onPressed,
              needPop: args.needPop,
              hideAppbar: args.hideAppbar),
          fullscreenDialog: true);
    },
    TagRoute.name: (routeData) {
      final args = routeData.argsAs<TagRouteArgs>();
      return MaterialPageX<dynamic>(
          routeData: routeData, child: TagPage(tag: args.tag));
    },
    HomeRouter.name: (routeData) {
      return MaterialPageX<dynamic>(routeData: routeData, child: HomeWidget());
    },
    CategoryRouter.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: CategoryPage());
    }
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(Initial.name, path: '/', children: [
          RouteConfig(HomeRouter.name,
              path: 'homeWidget', parent: Initial.name),
          RouteConfig(CategoryRouter.name,
              path: 'category', parent: Initial.name)
        ]),
        RouteConfig(StoryRoute.name, path: '/story-page'),
        RouteConfig(ErrorRoute.name, path: '/error-page'),
        RouteConfig(TagRoute.name, path: '/tag-page')
      ];
}

/// generated route for [InitialApp]
class Initial extends PageRouteInfo<void> {
  const Initial({List<PageRouteInfo>? children})
      : super(name, path: '/', initialChildren: children);

  static const String name = 'Initial';
}

/// generated route for [StoryPage]
class StoryRoute extends PageRouteInfo<StoryRouteArgs> {
  StoryRoute({required String id})
      : super(name, path: '/story-page', args: StoryRouteArgs(id: id));

  static const String name = 'StoryRoute';
}

class StoryRouteArgs {
  const StoryRouteArgs({required this.id});

  final String id;
}

/// generated route for [ErrorPage]
class ErrorRoute extends PageRouteInfo<ErrorRouteArgs> {
  ErrorRoute(
      {required dynamic error,
      required void Function() onPressed,
      bool needPop = false,
      bool hideAppbar = false})
      : super(name,
            path: '/error-page',
            args: ErrorRouteArgs(
                error: error,
                onPressed: onPressed,
                needPop: needPop,
                hideAppbar: hideAppbar));

  static const String name = 'ErrorRoute';
}

class ErrorRouteArgs {
  const ErrorRouteArgs(
      {required this.error,
      required this.onPressed,
      this.needPop = false,
      this.hideAppbar = false});

  final dynamic error;

  final void Function() onPressed;

  final bool needPop;

  final bool hideAppbar;
}

/// generated route for [TagPage]
class TagRoute extends PageRouteInfo<TagRouteArgs> {
  TagRoute({required Tag tag})
      : super(name, path: '/tag-page', args: TagRouteArgs(tag: tag));

  static const String name = 'TagRoute';
}

class TagRouteArgs {
  const TagRouteArgs({required this.tag});

  final Tag tag;
}

/// generated route for [HomeWidget]
class HomeRouter extends PageRouteInfo<void> {
  const HomeRouter() : super(name, path: 'homeWidget');

  static const String name = 'HomeRouter';
}

/// generated route for [CategoryPage]
class CategoryRouter extends PageRouteInfo<void> {
  const CategoryRouter() : super(name, path: 'category');

  static const String name = 'CategoryRouter';
}
