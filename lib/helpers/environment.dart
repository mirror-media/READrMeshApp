import 'package:readr/configs/baseConfig.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/configs/prodConfig.dart';
import 'package:readr/configs/stagingConfig.dart';

enum BuildFlavor { production, staging, development }

class Environment {
  factory Environment() {
    return _singleton;
  }

  Environment._internal();

  static final Environment _singleton = Environment._internal();

  late BaseConfig config;

  initConfig(BuildFlavor buildFlavor) {
    config = _getConfig(buildFlavor);
  }

  BaseConfig _getConfig(BuildFlavor buildFlavor) {
    switch (buildFlavor) {
      case BuildFlavor.production:
        return ProdConfig();
      case BuildFlavor.staging:
        return StagingConfig();
      default:
        return DevConfig();
    }
  }
}
