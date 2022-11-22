import 'package:fcl_flutter/fcl_flutter.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';

class WalletService extends GetxService {
  final FclFlutter _fclFlutter = FclFlutter();
  Future<WalletService> init() async {
    _fclFlutter.initFCL(
      Get.find<EnvironmentService>().config.bloctoAppId,
      useTestNet:
          Get.find<EnvironmentService>().flavor != BuildFlavor.production,
    );
    return this;
  }

  Future<String?> login() async {
    return await _fclFlutter.accountProofLogin('readrMeshDev');
  }

  Future<void> unauthenticate() async {
    await _fclFlutter.unauthenticate();
  }

  Future<String?> getAddress() async {
    return await _fclFlutter.getAddress();
  }
}
