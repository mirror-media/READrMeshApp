import 'package:upgrader/upgrader.dart';

class UpdateMessages extends UpgraderMessages {
  @override
  String? message(UpgraderMessage messageKey) {
    if (languageCode == 'zh') {
      switch (messageKey) {
        case UpgraderMessage.body:
          return 'READr Mesh有新的版本可供更新！\n最新版本：{{currentAppStoreVersion}}\n您安裝的版本：{{currentInstalledVersion}}';
        case UpgraderMessage.buttonTitleIgnore:
          return '忽略';
        case UpgraderMessage.buttonTitleLater:
          return '稍後';
        case UpgraderMessage.buttonTitleUpdate:
          return '現在更新';
        case UpgraderMessage.prompt:
          return '您要現在更新嗎？';
        case UpgraderMessage.title:
          return '更新App？';
        case UpgraderMessage.releaseNotes:
          return '更新內容';
      }
    }
    // Messages that are not provided above can still use the default values.
    return super.message(messageKey);
  }
}
