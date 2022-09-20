import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/dataConstants.dart';

class AdService extends GetxService {
  late final dynamic _adIdMap;
  Future<AdService> init() async {
    final jsonText = await rootBundle
        .loadString(GetPlatform.isIOS ? iosAdsIdsJson : androidAdsIdsJson);
    _adIdMap = jsonDecode(jsonText);
    MobileAds.instance.initialize();
    return this;
  }

  String getAdUnitId(String key) {
    if (Get.find<EnvironmentService>().flavor != BuildFlavor.production) {
      return GetPlatform.isIOS
          ? 'ca-app-pub-3940256099942544/3986624511'
          : 'ca-app-pub-3940256099942544/2247696110';
    }

    return _adIdMap[key] ?? '';
  }
}
