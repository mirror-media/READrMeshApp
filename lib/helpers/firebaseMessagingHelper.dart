import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/openProjectHelper.dart';
import 'package:readr/helpers/router/router.dart';

class FirebaseMessagingHelper {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseMessagingHelper();

  configFirebaseMessaging(BuildContext context) async {
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

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null && initialMessage.data.containsKey('story_id')) {
      context.router.push(StoryRoute(id: initialMessage.data['story_id']));
    } else if (initialMessage != null &&
        initialMessage.data.containsKey('project_url')) {
      OpenProjectHelper().openByUrl(initialMessage.data['project_url']);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('story_id')) {
        context.router.push(StoryRoute(id: message.data['story_id']));
      } else if (message.data.containsKey('project_url')) {
        OpenProjectHelper().openByUrl(message.data['project_url']);
      }
    });
  }

  subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  dispose() {}
}
