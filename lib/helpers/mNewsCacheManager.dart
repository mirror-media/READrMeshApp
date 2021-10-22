import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MNewsCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'mNewsApiCacheData';

  static final MNewsCacheManager _instance = MNewsCacheManager._();
  factory MNewsCacheManager() {
    return _instance;
  }

  MNewsCacheManager._() : super(Config(key, maxNrOfCacheObjects: 100));
}
