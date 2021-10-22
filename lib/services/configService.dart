import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/firebaseMessagingHelper.dart';

abstract class ConfigRepos {
  Future<bool> loadTheConfig(BuildContext context);
}

class ConfigServices implements ConfigRepos {
  @override
  Future<bool> loadTheConfig(BuildContext context) async {
    await Firebase.initializeApp();

    FirebaseMessagingHelper firebaseMessagingHelper = FirebaseMessagingHelper();
    await firebaseMessagingHelper.configFirebaseMessaging(context);
    return true;
  }
}
