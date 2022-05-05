import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseMessagingService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<FirebaseMessagingService> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // RemoteMessage? initialMessage =
    //     await _firebaseMessaging.getInitialMessage();

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    return this;
  }

  subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  dispose() {}
}
