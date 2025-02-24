import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:readr/models/community_model.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/models/communityListItem.dart';

abstract class CommunityRepos {
  Future<List<CommunityListItem>> fetchFollowingPicked({
    List<String>? alreadyFetchStoryIds,
    List<String>? alreadyFetchCollectionIds,
  });
  Future<List<CommunityListItem>> fetchFollowingComment({
    List<String>? alreadyFetchStoryIds,
    List<String>? alreadyFetchCollectionIds,
  });
  Future<List<CommunityListItem>> fetchCollections({
    List<String>? alreadyFetchCollectionIds,
  });
}

class CommunityService extends GetxService implements CommunityRepos {
  final String communityUrl =
      Get.find<EnvironmentService>().config.communityPageApi;
  final _cache = <String, CacheData>{};
  static const _cacheTimeout = Duration(minutes: 5);

  Future<CommunityModel?> fetchSocialPage({
    required String memberId,
    required int index,
    int take = 10,
  }) async {
    final cacheKey = 'social_page_${memberId}_${index}';
    if (_cache.containsKey(cacheKey)) {
      final cacheData = _cache[cacheKey]!;
      if (DateTime.now().difference(cacheData.timestamp) < _cacheTimeout) {
        return cacheData.data as CommunityModel;
      }
    }

    try {
      final response = await http.post(
        Uri.parse(communityUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'member_id': memberId,
          'index': index,
          'take': take,
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = CommunityModel.fromJson(jsonDecode(decodedResponse));

        _cache[cacheKey] = CacheData(
          data: data,
          timestamp: DateTime.now(),
        );

        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching social page: $e');
      return null;
    }
  }

  @override
  Future<List<CommunityListItem>> fetchFollowingPicked({
    List<String>? alreadyFetchStoryIds,
    List<String>? alreadyFetchCollectionIds,
  }) {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<List<CommunityListItem>> fetchFollowingComment({
    List<String>? alreadyFetchStoryIds,
    List<String>? alreadyFetchCollectionIds,
  }) {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<List<CommunityListItem>> fetchCollections({
    List<String>? alreadyFetchCollectionIds,
  }) {
    // Implementation needed
    throw UnimplementedError();
  }
}

class CacheData {
  final dynamic data;
  final DateTime timestamp;

  CacheData({
    required this.data,
    required this.timestamp,
  });
}
