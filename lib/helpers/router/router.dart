import 'package:auto_route/auto_route.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/people.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/author/authorPage.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/home/homePage.dart';
import 'package:readr/pages/home/recommendFollow/recommendFollowPage.dart';
import 'package:readr/pages/loginMember/chooseMember/chooseMemberPage.dart';
import 'package:readr/pages/loginMember/choosePublisher/choosePublisherPage.dart';
import 'package:readr/pages/loginMember/email/inputEmailPage.dart';
import 'package:readr/pages/loginMember/inputNamePage.dart';
import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/loginMember/email/sentEmailPage.dart';
import 'package:readr/pages/personalFile/editPersonalFile/editPersonalFilePage.dart';
import 'package:readr/pages/personalFile/followerList/followerListPage.dart';
import 'package:readr/pages/personalFile/followingList/followingListPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/readr/readrPage.dart';
import 'package:flutter/material.dart';
import 'package:readr/pages/setting/aboutPage.dart';
import 'package:readr/pages/setting/deleteMemberPage.dart';
import 'package:readr/pages/setting/settingPage.dart';
import 'package:readr/pages/story/news/newsStoryPage.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:readr/initialApp.dart';
import 'package:readr/pages/tag/tagPage.dart';
import 'package:readr/models/tag.dart';
import 'package:readr/pages/welcomePage.dart';

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
    AutoRoute(page: AuthorPage),
    AutoRoute(page: NewsStoryPage, fullscreenDialog: true),
    AutoRoute(page: RecommendFollowPage),
    AutoRoute(page: PersonalFilePage),
    AutoRoute(page: FollowerListPage),
    AutoRoute(page: FollowingListPage),
    AutoRoute<bool>(page: EditPersonalFilePage, fullscreenDialog: true),
    AutoRoute(page: PublisherPage),
    AutoRoute(page: LoginPage, fullscreenDialog: true),
    AutoRoute(page: SentEmailPage),
    AutoRoute(page: InputEmailPage),
    AutoRoute(page: InputNamePage),
    AutoRoute(page: ChoosePublisherPage),
    AutoRoute(page: ChooseMemberPage),
    AutoRoute(page: WelcomePage),
    AutoRoute(page: SettingPage),
  ],
)
// extend the generated private router
class AppRouter extends _$AppRouter {}
