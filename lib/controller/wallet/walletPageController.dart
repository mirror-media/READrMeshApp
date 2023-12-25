import 'package:get/get.dart';
import 'package:readr/getxServices/walletService.dart';

class WalletPageController extends GetxController {
  final accountAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getAddress();
  }

  Future<void> _getAddress() async {
    accountAddress.value = await Get.find<WalletService>().getAddress() ?? '';
  }

  Future<void> loginWallet() async {
    try {
      String? account = await Get.find<WalletService>().login();
      if (account != null) {
        accountAddress.value = account;
      }
    } catch (e) {
      print('Login error: $e');
    }
  }

  Future<void> logout() async {
    await Get.find<WalletService>().unauthenticate();
    accountAddress.value = '';
  }
}
