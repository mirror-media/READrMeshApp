import 'package:flutter/material.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/initialServices.dart';
import 'package:readr/readrApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appInitial(BuildFlavor.staging);
  runApp(ReadrApp());
}
