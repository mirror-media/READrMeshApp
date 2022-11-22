import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/wallet/walletPageController.dart';
import 'package:readr/helpers/themes.dart';

class WalletPage extends GetView<WalletPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '錢包',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv1!,
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: Theme.of(context).extension<CustomColors>()!.backgroundSingleLayer,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 50,
          ),
          Obx(
            () {
              String text = '登入錢包以成為Web3.0新聞閱讀的一員';
              if (controller.accountAddress.isNotEmpty) {
                text = '您的錢包地址：${controller.accountAddress.value}';
              }

              return Text(
                text,
                style: Theme.of(context).textTheme.headlineSmall,
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton(
            onPressed: () async {
              if (controller.accountAddress.isNotEmpty) {
                await controller.logout();
              } else {
                await controller.loginWallet();
              }
            },
            child: Obx(
              () {
                String text = '登入 / 註冊';
                if (controller.accountAddress.isNotEmpty) {
                  text = '登出';
                }

                return Text(
                  text,
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Text(
            'Powered by Blocto',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
