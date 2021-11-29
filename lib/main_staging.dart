import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:readr/readrApp.dart';

import 'helpers/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment().initConfig(BuildFlavor.staging);
  await Firebase.initializeApp();
  runApp(ReadrApp());
}
