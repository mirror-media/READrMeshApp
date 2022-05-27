import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class FirebaseAnalyticsService extends GetxService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void logAppOpen() {
    _analytics.logAppOpen();
  }
}
