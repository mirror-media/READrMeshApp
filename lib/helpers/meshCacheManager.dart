import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MeshCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'mNewsApiCacheData';

  static final MeshCacheManager _instance = MeshCacheManager._();
  factory MeshCacheManager() {
    return _instance;
  }

  MeshCacheManager._() : super(Config(key, maxNrOfCacheObjects: 100));
}
