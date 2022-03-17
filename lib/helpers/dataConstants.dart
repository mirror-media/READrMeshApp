import 'package:flutter/material.dart';

/// url link
const readrMail = 'readr@readr.tw';
const youtubeLink = 'https://www.youtube.com/';
const readrProjectLink = 'https://www.readr.tw/';

/// assets
const String error400Svg = 'assets/image/error404.svg';
const String error500Svg = 'assets/image/error500.svg';
const String noInternetSvg = 'assets/image/noInternet.svg';
const String logoSvg = 'assets/icon/logo.svg';
const String logoPng = 'assets/icon/logo.png';
const String logoSimplifySvg = 'assets/icon/logoSimplify.svg';
const String defaultImageSvg = 'assets/image/defaultImage.svg';
const String tabNoContentPng = 'assets/image/tabNoContent.png';
const String homeIconSvg = 'assets/icon/homeIcon.svg';
const String googleLogoSvg = 'assets/icon/googleLogo.svg';
const String authorDefaultPng = 'assets/image/authorDefaultImage.png';
const String commentIconPng = 'assets/icon/commentIcon.png';
const String logoSimplifyPng = 'assets/icon/logoSimplify.png';
const String noFollowingSvg = 'assets/image/noFollowing.svg';
const String latestNewsEmptySvg = 'assets/image/latestNewsEmpty.svg';
const String visitorAvatarPng = 'assets/icon/visitorAvatar.png';

/// color
const Color themeColor = Color(0xffFFFFFF);
const Color appBarColor = Color(0xffFFFFFF);
const Color tabBarColor = Color(0xffFFFFFF);
const Color hightLightColor = Color(0xffEBF02C);
const Color tabBarSelectedColor = Color.fromRGBO(0, 9, 40, 0.87);
const Color editorChoiceTagColor = Color.fromRGBO(0, 9, 40, 0.66);
const Color editorChoiceBackgroundColor = Color(0xffFFFFFF);
const Color bottomNavigationBarSelectedColor = Colors.black;
const Color bottomNavigationBarUnselectedColor = Colors.black54;
const Color readrBlack87 = Color.fromRGBO(0, 9, 40, 0.87);

const Color storyWidgetColor = Color(0xff04295E);
const Color storySummaryFrameColor = storyWidgetColor;
const Color blockquoteColor = Color.fromRGBO(0, 9, 40, 0.1);
const Color annotationColor = Colors.black87;
const Color homeScreenBackgroundColor = Color.fromRGBO(246, 246, 251, 1);

// enum
enum PickObjective {
  story,
  comment,
  collection,
}

enum PickState {
  public,
  friend,
  private,
}

enum PickKind {
  bookmark,
  collect,
  read,
}

enum CommentTransparency {
  public,
  friend,
  private,
}
