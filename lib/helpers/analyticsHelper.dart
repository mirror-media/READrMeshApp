import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';

final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

void logAppOpen() {
  _analytics.logAppOpen();
}

void setUserId(String memberId) {
  _analytics.setUserId(id: memberId);
}

void logSignUp() {
  _analytics.logSignUp(
    signUpMethod:
        Get.find<SharedPreferencesService>().prefs.getString('loginType') ??
            'Unknown',
  );
}

void logDeleteAccount() {
  _analytics.logEvent(
    name: 'delete_account',
  );
}

void logClickTab(int tabIndex) {
  String tabLabel;
  switch (tabIndex) {
    case 0:
      tabLabel = '社群';
      break;
    case 1:
      tabLabel = '最新';
      break;
    case 2:
      tabLabel = 'READr';
      break;
    case 3:
      tabLabel = '個人檔案';
      break;
    default:
      tabLabel = '社群';
  }
  _analytics.logEvent(
    name: 'tab_click',
    parameters: {
      'tab_label': tabLabel,
    },
  );
}

void logShare(String contentType, String id, String method) {
  _analytics.logShare(contentType: contentType, itemId: id, method: method);
}
