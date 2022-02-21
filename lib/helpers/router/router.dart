import 'package:auto_route/auto_route.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/people.dart';
import 'package:readr/pages/author/authorPage.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/home/homePage.dart';
import 'package:readr/pages/home/recommendFollowPage.dart';
import 'package:readr/pages/personalFile/editPersonalFile/editPersonalFilePage.dart';
import 'package:readr/pages/personalFile/followerList/followerListPage.dart';
import 'package:readr/pages/personalFile/followingList/followingListPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/readr/readrPage.dart';
import 'package:flutter/material.dart';
import 'package:readr/pages/memberCenter/aboutPage.dart';
import 'package:readr/pages/memberCenter/deleteMember/deleteMemberPage.dart';
import 'package:readr/pages/memberCenter/loginMember/loginPage.dart';
import 'package:readr/pages/memberCenter/loginMember/sendEmailPage.dart';
import 'package:readr/pages/memberCenter/memberCenterPage.dart';
import 'package:readr/pages/story/news/newsStoryPage.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:readr/initialApp.dart';
import 'package:readr/pages/tag/tagPage.dart';
import 'package:readr/models/tag.dart';

part 'router.gr.dart';

// Run after edited:
// flutter packages pub run build_runner build --delete-conflicting-outputs
@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(name: 'Initial', page: InitialApp, initial: true, children: [
      AutoRoute(
        path: "homePage",
        name: "HomeRouter",
        page: HomePage,
      ),
      AutoRoute(
        path: "readrPage",
        name: "ReadrRouter",
        page: ReadrPage,
      ),
      AutoRoute(
        path: "personalFile",
        name: "PersonalFileRouter",
        page: PersonalFilePage,
      ),
    ]),
    AutoRoute(page: StoryPage),
    AutoRoute(page: ErrorPage, fullscreenDialog: true),
    AutoRoute(page: TagPage),
    AutoRoute(page: AboutPage),
    AutoRoute(page: DeleteMemberPage),
    AutoRoute(page: LoginPage),
    AutoRoute(page: SendEmailPage),
    AutoRoute(page: AuthorPage),
    AutoRoute(page: NewsStoryPage, fullscreenDialog: true),
    AutoRoute(page: RecommendFollowPage),
    AutoRoute(page: PersonalFilePage),
    AutoRoute(page: MemberCenterPage),
    AutoRoute(page: FollowerListPage),
    AutoRoute(page: FollowingListPage),
    AutoRoute<bool>(page: EditPersonalFilePage, fullscreenDialog: true),
  ],
)
// extend the generated private router
class AppRouter extends _$AppRouter {}
