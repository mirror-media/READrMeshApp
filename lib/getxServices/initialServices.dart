import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/firebaseMessagingService.dart';

import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/getxServices/dynamicLinkService.dart';

Future<void> appInitial(BuildFlavor buildFlavor) async {
  print('App starting ...');
  await Firebase.initializeApp();
  if (GetPlatform.isIOS) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  Get.put(EnvironmentService(buildFlavor));
  await Get.putAsync(() => FirebaseMessagingService().init());
  await Get.putAsync(() => SharedPreferencesService().init());
  await Get.putAsync(() => DynamicLinkService().initDynamicLinks());
  await Get.putAsync(() => UserService().init());

  print('All services started...');
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print("Handling a background message: ${message.messageId}");
}
