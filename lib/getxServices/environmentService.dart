import 'package:get/get.dart';
import 'package:readr/configs/baseConfig.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/configs/prodConfig.dart';
import 'package:readr/configs/stagingConfig.dart';

enum BuildFlavor { production, staging, development }

class EnvironmentService extends GetxService {
  final BuildFlavor flavor;
  EnvironmentService(this.flavor);

  BaseConfig get config {
    switch (flavor) {
      case BuildFlavor.production:
        return ProdConfig();

      case BuildFlavor.staging:
        return StagingConfig();

      default:
        return DevConfig();
    }
  }
}
