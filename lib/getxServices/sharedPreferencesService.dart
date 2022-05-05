import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService extends GetxService {
  late final SharedPreferences prefs;

  Future<SharedPreferencesService> init() async {
    prefs = await SharedPreferences.getInstance();
    return this;
  }
}
