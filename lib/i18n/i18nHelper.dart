import 'package:get/get.dart';
import 'package:readr/i18n/chineseCn.dart';
import 'package:readr/i18n/chineseTw.dart';
import 'package:readr/i18n/english.dart';

class I18nHelper extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_TW': chineseTwMap,
        'zh_HK': chineseTwMap,
        'zh_CN': chineseCnMap,
        'zh': chineseTwMap,
        'en': englishMap,
      };
}
