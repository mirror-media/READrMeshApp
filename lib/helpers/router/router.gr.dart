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
          routeData: routeData,
          child: StoryPage(id: args.id, useWebview: args.useWebview));
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
      return MaterialPageX<dynamic>(
          routeData: routeData, child: DeleteMemberPage(member: args.member));
    },
    LoginRoute.name: (routeData) {
      return MaterialPageX<dynamic>(routeData: routeData, child: LoginPage());
    },
    SendEmailRoute.name: (routeData) {
      final args = routeData.argsAs<SendEmailRouteArgs>();
      return MaterialPageX<dynamic>(
          routeData: routeData, child: SendEmailPage(args.email));
    },
    AuthorRoute.name: (routeData) {
      final args = routeData.argsAs<AuthorRouteArgs>();
      return MaterialPageX<dynamic>(
          routeData: routeData, child: AuthorPage(people: args.people));
    },
    ReadrRouter.name: (routeData) {
      return MaterialPageX<dynamic>(routeData: routeData, child: ReadrPage());
    },
    MemberCenterRouter.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: MemberCenterPage());
    }
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(Initial.name, path: '/', children: [
          RouteConfig(ReadrRouter.name,
              path: 'readrPage', parent: Initial.name),
          RouteConfig(MemberCenterRouter.name,
              path: 'memberCenter', parent: Initial.name)
        ]),
        RouteConfig(StoryRoute.name, path: '/story-page'),
        RouteConfig(ErrorRoute.name, path: '/error-page'),
        RouteConfig(TagRoute.name, path: '/tag-page'),
        RouteConfig(AboutRoute.name, path: '/about-page'),
        RouteConfig(DeleteMemberRoute.name, path: '/delete-member-page'),
        RouteConfig(LoginRoute.name, path: '/login-page'),
        RouteConfig(SendEmailRoute.name, path: '/send-email-page'),
        RouteConfig(AuthorRoute.name, path: '/author-page')
      ];
}

/// generated route for
/// [InitialApp]
class Initial extends PageRouteInfo<void> {
  const Initial({List<PageRouteInfo>? children})
      : super(Initial.name, path: '/', initialChildren: children);

  static const String name = 'Initial';
}

/// generated route for
/// [StoryPage]
class StoryRoute extends PageRouteInfo<StoryRouteArgs> {
  StoryRoute({required String id, bool useWebview = false})
      : super(StoryRoute.name,
            path: '/story-page',
            args: StoryRouteArgs(id: id, useWebview: useWebview));

  static const String name = 'StoryRoute';
}

class StoryRouteArgs {
  const StoryRouteArgs({required this.id, this.useWebview = false});

  final String id;

  final bool useWebview;

  @override
  String toString() {
    return 'StoryRouteArgs{id: $id, useWebview: $useWebview}';
  }
}

/// generated route for
/// [ErrorPage]
class ErrorRoute extends PageRouteInfo<ErrorRouteArgs> {
  ErrorRoute(
      {required dynamic error,
      required void Function() onPressed,
      bool needPop = false,
      bool hideAppbar = false})
      : super(ErrorRoute.name,
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

  @override
  String toString() {
    return 'ErrorRouteArgs{error: $error, onPressed: $onPressed, needPop: $needPop, hideAppbar: $hideAppbar}';
  }
}

/// generated route for
/// [TagPage]
class TagRoute extends PageRouteInfo<TagRouteArgs> {
  TagRoute({required Tag tag})
      : super(TagRoute.name, path: '/tag-page', args: TagRouteArgs(tag: tag));

  static const String name = 'TagRoute';
}

class TagRouteArgs {
  const TagRouteArgs({required this.tag});

  final Tag tag;

  @override
  String toString() {
    return 'TagRouteArgs{tag: $tag}';
  }
}

/// generated route for
/// [AboutPage]
class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute() : super(AboutRoute.name, path: '/about-page');

  static const String name = 'AboutRoute';
}

/// generated route for
/// [DeleteMemberPage]
class DeleteMemberRoute extends PageRouteInfo<DeleteMemberRouteArgs> {
  DeleteMemberRoute({required Member member})
      : super(DeleteMemberRoute.name,
            path: '/delete-member-page',
            args: DeleteMemberRouteArgs(member: member));

  static const String name = 'DeleteMemberRoute';
}

class DeleteMemberRouteArgs {
  const DeleteMemberRouteArgs({required this.member});

  final Member member;

  @override
  String toString() {
    return 'DeleteMemberRouteArgs{member: $member}';
  }
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute() : super(LoginRoute.name, path: '/login-page');

  static const String name = 'LoginRoute';
}

/// generated route for
/// [SendEmailPage]
class SendEmailRoute extends PageRouteInfo<SendEmailRouteArgs> {
  SendEmailRoute({required String email})
      : super(SendEmailRoute.name,
            path: '/send-email-page', args: SendEmailRouteArgs(email: email));

  static const String name = 'SendEmailRoute';
}

class SendEmailRouteArgs {
  const SendEmailRouteArgs({required this.email});

  final String email;

  @override
  String toString() {
    return 'SendEmailRouteArgs{email: $email}';
  }
}

/// generated route for
/// [AuthorPage]
class AuthorRoute extends PageRouteInfo<AuthorRouteArgs> {
  AuthorRoute({required People people})
      : super(AuthorRoute.name,
            path: '/author-page', args: AuthorRouteArgs(people: people));

  static const String name = 'AuthorRoute';
}

class AuthorRouteArgs {
  const AuthorRouteArgs({required this.people});

  final People people;

  @override
  String toString() {
    return 'AuthorRouteArgs{people: $people}';
  }
}

/// generated route for
/// [ReadrPage]
class ReadrRouter extends PageRouteInfo<void> {
  const ReadrRouter() : super(ReadrRouter.name, path: 'readrPage');

  static const String name = 'ReadrRouter';
}

/// generated route for
/// [MemberCenterPage]
class MemberCenterRouter extends PageRouteInfo<void> {
  const MemberCenterRouter()
      : super(MemberCenterRouter.name, path: 'memberCenter');

  static const String name = 'MemberCenterRouter';
}
