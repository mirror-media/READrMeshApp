import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis/pubsub/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/dataConstants.dart';

class PubsubService extends GetxService {
  late final PubsubApi _pubSubClient;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  final String url =
      'https://mesh-proxy-server-dev-4g6paft7cq-de.a.run.app/pubsub';
  final ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  Future<PubsubService> init() async {
    var jsonText = await rootBundle.loadString(serviceAccountCredentialsJson);
    final credentials =
        ServiceAccountCredentials.fromJson(json.decode(jsonText));
    await clientViaServiceAccount(credentials, [PubsubApi.pubsubScope])
        .then((httpClient) => _pubSubClient = PubsubApi(httpClient));
    return this;
  }

  Future<bool> addPick({
    required String memberId,
    required String targetId,
    required PickObjective objective,
    PickState state = PickState.public,
  }) async {
    return await _publishRequest({
      "action": "add_pick",
      "memberId": memberId,
      "objective": objective.toString().split('.').last,
      "targetId": targetId,
      "state": state.toString().split('.').last,
    });
  }

  Future<bool> pickAndComment({
    required String memberId,
    required String targetId,
    required PickObjective objective,
    required String commentContent,
    PickState state = PickState.public,
  }) async {
    return await _publishRequest({
      "action": "add_pick_and_comment",
      "memberId": memberId,
      "objective": objective.toString().split('.').last,
      "targetId": targetId,
      "state": state.toString().split('.').last,
      "content": _escapeString(commentContent),
    });
  }

  Future<bool> unPick({
    required String memberId,
    required String targetId,
    required PickObjective objective,
  }) async {
    return await _publishRequest({
      "action": "remove_pick",
      "memberId": memberId,
      "objective": objective.toString().split('.').last,
      "targetId": targetId,
    });
  }

  Future<bool> addFollow({
    required String memberId,
    required String targetId,
    required FollowObjective objective,
  }) async {
    return await _publishRequest({
      "action": "add_follow",
      "memberId": memberId,
      "objective": objective.toString().split('.').last,
      "targetId": targetId,
    });
  }

  Future<bool> removeFollow({
    required String memberId,
    required String targetId,
    required FollowObjective objective,
  }) async {
    return await _publishRequest({
      "action": "remove_follow",
      "memberId": memberId,
      "objective": objective.toString().split('.').last,
      "targetId": targetId,
    });
  }

  Future<bool> addComment({
    required String memberId,
    required String targetId,
    required PickObjective objective,
    required String commentContent,
    PickState state = PickState.public,
  }) async {
    return await _publishRequest({
      "action": "add_comment",
      "memberId": memberId,
      "objective": objective.toString().split('.').last,
      "targetId": targetId,
      "state": state.toString().split('.').last,
      "content": _escapeString(commentContent),
    });
  }

  Future<bool> editComment({
    required String commentId,
    required String newContent,
    required String memberId,
  }) async {
    return await _publishRequest({
      "action": "edit_comment",
      "commentId": commentId,
      "memberId": memberId,
      "content": _escapeString(newContent),
    });
  }

  Future<bool> removeComment({
    required String memberId,
    required String commentId,
  }) async {
    return await _publishRequest({
      "action": "remove_comment",
      "commentId": commentId,
      "memberId": memberId,
    });
  }

  Future<bool> addBookmark({
    required String memberId,
    required String storyId,
  }) async {
    return await _publishRequest({
      "action": "add_bookmark",
      "memberId": memberId,
      "storyId": storyId,
    });
  }

  Future<bool> removeBookmark({
    required String memberId,
    required String storyId,
  }) async {
    return await _publishRequest({
      "action": "remove_bookmark",
      "memberId": memberId,
      "storyId": storyId,
    });
  }

  Future<bool> addLike({
    required String memberId,
    required String commentId,
  }) async {
    return await _publishRequest({
      "action": "add_like",
      "memberId": memberId,
      "commentId": commentId,
    });
  }

  Future<bool> removeLike({
    required String memberId,
    required String commentId,
  }) async {
    return await _publishRequest({
      "action": "remove_like",
      "memberId": memberId,
      "commentId": commentId,
    });
  }

  Future<bool> addCategoryList({
    required String memberId,
    required List<String> categoryList,
  }) async {
    return await _publishRequest({
      "action": "add_category",
      "memberId": memberId,
      "categoryIds": categoryList,
    });
  }

  Future<bool> removeCategoryList({
    required String memberId,
    required List<String> categoryList,
  }) async {
    return await _publishRequest({
      "action": "remove_category",
      "memberId": memberId,
      "categoryIds": categoryList,
    });
  }

  Future<bool> addCollection({
    required String memberId,
    required String collectionId,
  }) async {
    return await _publishRequest({
      "action": "add_collection",
      "memberId": memberId,
      "commentId": collectionId,
    });
  }

  Future<bool> removeCollection({
    required String memberId,
    required String collectionId,
  }) async {
    return await _publishRequest({
      "action": "remove_collection",
      "memberId": memberId,
      "commentId": collectionId,
    });
  }

  void logReadStory({
    required String memberId,
    required String storyId,
  }) {
    _publishRequest({
      "action": "read_story",
      "memberId": memberId,
      "storyId": storyId,
    });
  }

  void logReadCollection({
    required String memberId,
    required String collectionId,
  }) {
    _publishRequest({
      "action": "read_collection",
      "memberId": memberId,
      "collectionId": collectionId,
    });
  }

  Future<bool> _publishRequest(Map<String, dynamic> requestJson) async {
    String uuid;
    String os;
    String osVersion;
    String deviceModel;

    if (GetPlatform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      uuid = androidInfo.id ?? '';
      os = 'Android';
      osVersion =
          '${androidInfo.version.release ?? ''} (SDK ${androidInfo.version.sdkInt ?? ''})';
      deviceModel =
          '${androidInfo.manufacturer ?? ''} ${androidInfo.model ?? ''}';
    } else {
      IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      os = iosInfo.systemName ?? 'iOS';
      uuid = iosInfo.identifierForVendor ?? '';
      osVersion = iosInfo.systemVersion ?? '';
      deviceModel = iosInfo.name ?? '';
      deviceModel = _escapeString(deviceModel);
    }

    requestJson.addAll({
      "UUID": uuid,
      "os": os,
      "version": osVersion,
      "device": deviceModel,
    });

    return await apiBaseHelper
        .postByUrl(url, jsonEncode(requestJson), headers: {
          "Content-Type": "application/json",
        })
        .then((value) => true)
        .catchError((error) {
          print('Pub/Sub error: $error');
          return false;
        })
        .timeout(const Duration(seconds: 10), onTimeout: () {
          print('Pub/Sub timeout');
          return false;
        });
  }

  String _escapeString(String value) {
    String escaped = value.replaceAll(RegExp(r"'"), "‘");
    String jsonString = jsonEncode(escaped);
    String jsonEscape = jsonString.substring(1, jsonString.length - 1);
    return jsonEscape;
  }
}
