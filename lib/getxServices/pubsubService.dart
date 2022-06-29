import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis/pubsub/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/dataConstants.dart';

class PubsubService extends GetxService {
  late final PubsubApi _pubSubClient;

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
      "'action'": "'add_pick'",
      "'memberId'": "'$memberId'",
      "'objective'": "'${objective.toString().split('.').last}'",
      "'targetId'": "'$targetId'",
      "'state'": "'${state.toString().split('.').last}'",
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
      "'action'": "'pick_and_comment'",
      "'memberId'": "'$memberId'",
      "'objective'": "'${objective.toString().split('.').last}'",
      "'targetId'": "'$targetId'",
      "'state'": "'${state.toString().split('.').last}'",
      "'content'": "'$commentContent'",
    });
  }

  Future<bool> unPick({
    required String memberId,
    required String targetId,
    required PickObjective objective,
  }) async {
    return await _publishRequest({
      "'action'": "'unpick'",
      "'memberId'": "'$memberId'",
      "'objective'": "'${objective.toString().split('.').last}'",
      "'targetId'": "'$targetId'",
    });
  }

  Future<bool> addFollow({
    required String memberId,
    required String targetId,
    required FollowObjective objective,
  }) async {
    return await _publishRequest({
      "'action'": "'add_follow'",
      "'memberId'": "'$memberId'",
      "'objective'": "'${objective.toString().split('.').last}'",
      "'targetId'": "'$targetId'",
    });
  }

  Future<bool> removeFollow({
    required String memberId,
    required String targetId,
    required FollowObjective objective,
  }) async {
    return await _publishRequest({
      "'action'": "'remove_follow'",
      "'memberId'": "'$memberId'",
      "'objective'": "'${objective.toString().split('.').last}'",
      "'targetId'": "'$targetId'",
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
      "'action'": "'add_comment'",
      "'memberId'": "'$memberId'",
      "'objective'": "'${objective.toString().split('.').last}'",
      "'targetId'": "'$targetId'",
      "'state'": "'${state.toString().split('.').last}'",
      "'content'": "'$commentContent'",
    });
  }

  Future<bool> editComment({
    required String commentId,
    required String newContent,
  }) async {
    return await _publishRequest({
      "'action'": "'edit_comment'",
      "'commentId'": "'$commentId'",
      "'content'": "'$newContent'",
    });
  }

  Future<bool> removeComment({
    required String commentId,
  }) async {
    return await _publishRequest({
      "'action'": "'remove_comment'",
      "'commentId'": "'$commentId'",
    });
  }

  Future<bool> addBookmark({
    required String memberId,
    required String storyId,
  }) async {
    return await _publishRequest({
      "'action'": "'add_bookmark'",
      "'memberId'": "'$memberId'",
      "'storyId'": "'$storyId'",
    });
  }

  Future<bool> removeBookmark({
    required String memberId,
    required String storyId,
  }) async {
    return await _publishRequest({
      "'action'": "'remove_bookmark'",
      "'memberId'": "'$memberId'",
      "'storyId'": "'$storyId'",
    });
  }

  Future<bool> addLike({
    required String memberId,
    required String commentId,
  }) async {
    return await _publishRequest({
      "'action'": "'add_like'",
      "'memberId'": "'$memberId'",
      "'commentId'": "'$commentId'",
    });
  }

  Future<bool> removeLike({
    required String memberId,
    required String commentId,
  }) async {
    return await _publishRequest({
      "'action'": "'remove_like'",
      "'memberId'": "'$memberId'",
      "'commentId'": "'$commentId'",
    });
  }

  Future<void> logReadStory({
    required String memberId,
    required String storyId,
  }) async {}

  Future<void> logViewCollection({
    required String memberId,
    required String collectionId,
  }) async {}

  Future<bool> _publishRequest(Map<String, dynamic> requestJson) async {
    var messages = {
      'messages': [
        {
          'data': base64Encode(utf8.encode(requestJson.toString())),
        },
      ]
    };
    return await _pubSubClient.projects.topics
        .publish(PublishRequest.fromJson(messages),
            Get.find<EnvironmentService>().config.pubSubTopic)
        .then((value) => true)
        .catchError((error) {
      print('Pub/Sub error: $error');
      return false;
    }).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('Pub/Sub timeout');
        return false;
      },
    );
  }
}
