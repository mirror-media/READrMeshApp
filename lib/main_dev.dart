import 'package:flutter/material.dart';
import 'package:readr/getxServices/initialServices.dart';
import 'package:readr/readrApp.dart';

import 'getxServices/environmentService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appInitial(BuildFlavor.development);
  runApp(ReadrApp());
}
