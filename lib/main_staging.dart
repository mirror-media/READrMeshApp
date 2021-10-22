import 'package:flutter/material.dart';
import 'package:readr/readrApp.dart';

import 'helpers/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment().initConfig(BuildFlavor.staging);

  runApp(ReadrApp());
}
