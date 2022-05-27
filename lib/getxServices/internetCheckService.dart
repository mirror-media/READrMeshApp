import 'dart:io';

import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:readr/getxServices/environmentService.dart';

class InternetCheckService extends GetxService {
  late final InternetConnectionChecker meshCheckInstance;

  Future<InternetCheckService> init() async {
    final Duration timeout;
    if (Get.find<EnvironmentService>().flavor == BuildFlavor.development) {
      timeout = const Duration(minutes: 2);
    } else {
      timeout = const Duration(seconds: 1);
    }
    List<AddressCheckOptions> addresses = [];

    await InternetAddress.lookup(
            Get.find<EnvironmentService>().config.meshConnectCheckAddress)
        .then(
      (value) {
        for (var internetAddress in value) {
          addresses.add(AddressCheckOptions(internetAddress, port: 443));
        }
      },
    ).timeout(const Duration(minutes: 3));
    meshCheckInstance = InternetConnectionChecker.createInstance(
      checkTimeout: timeout, // Custom check timeout
      addresses: addresses,
    );
    return this;
  }
}
