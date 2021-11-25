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
    AboutRoute.name: (routeData) {
      return MaterialPageX<dynamic>(routeData: routeData, child: AboutPage());
    },
    DeleteMemberRoute.name: (routeData) {
      final args = routeData.argsAs<DeleteMemberRouteArgs>();
      return MaterialPageX<bool>(
          routeData: routeData, child: DeleteMemberPage(member: args.member));
    },
    LoginRoute.name: (routeData) {
      return MaterialPageX<bool>(routeData: routeData, child: LoginPage());
    },
    HomeRouter.name: (routeData) {
      return MaterialPageX<dynamic>(routeData: routeData, child: HomeWidget());
    },
    MemberCenterRouter.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: MemberCenterPage());
    }
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(Initial.name, path: '/', children: [
          RouteConfig(HomeRouter.name,
              path: 'homeWidget', parent: Initial.name),
          RouteConfig(MemberCenterRouter.name,
              path: 'memberCenter', parent: Initial.name)
        ]),
        RouteConfig(StoryRoute.name, path: '/story-page'),
        RouteConfig(ErrorRoute.name, path: '/error-page'),
        RouteConfig(TagRoute.name, path: '/tag-page'),
        RouteConfig(AboutRoute.name, path: '/about-page'),
        RouteConfig(DeleteMemberRoute.name, path: '/delete-member-page'),
        RouteConfig(LoginRoute.name, path: '/login-page')
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

/// generated route for [AboutPage]
class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute() : super(name, path: '/about-page');

  static const String name = 'AboutRoute';
}

/// generated route for [DeleteMemberPage]
class DeleteMemberRoute extends PageRouteInfo<DeleteMemberRouteArgs> {
  DeleteMemberRoute({required Member member})
      : super(name,
            path: '/delete-member-page',
            args: DeleteMemberRouteArgs(member: member));

  static const String name = 'DeleteMemberRoute';
}

class DeleteMemberRouteArgs {
  const DeleteMemberRouteArgs({required this.member});

  final Member member;
}

/// generated route for [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute() : super(name, path: '/login-page');

  static const String name = 'LoginRoute';
}

/// generated route for [HomeWidget]
class HomeRouter extends PageRouteInfo<void> {
  const HomeRouter() : super(name, path: 'homeWidget');

  static const String name = 'HomeRouter';
}

/// generated route for [MemberCenterPage]
class MemberCenterRouter extends PageRouteInfo<void> {
  const MemberCenterRouter() : super(name, path: 'memberCenter');

  static const String name = 'MemberCenterRouter';
}
