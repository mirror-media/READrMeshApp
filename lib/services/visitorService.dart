import 'dart:convert';

import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitorService {
  final ApiBaseHelper _helper = ApiBaseHelper();

  final String api = Environment().config.readrMeshApi;

  Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    return headers;
  }

  Future<Member> fetchMemberData() async {
    // fetch shared preferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> followingPublisherIds =
        prefs.getStringList('followingPublisherIds') ?? [];

    // fetch remain data by id and slug
    const String query = """
    query(
      \$followingPublisherIds: [ID!]
    ){
      followingPublisher: publishers(
        where:{
          id:{
            in: \$followingPublisherIds
          }
        }
      ){
        id
        title
      }
    }
    """;

    Map<String, dynamic> variables = {
      "followingPublisherIds": followingPublisherIds,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await getHeaders(),
    );

    List<Publisher> followingPublishers = [];
    for (var publisher in jsonResponse['data']['followingPublisher']) {
      followingPublishers.add(Publisher.fromJson(publisher));
    }

    return Member(
      memberId: "-1",
      nickname: "訪客",
      customId: "個人檔案", //show in personalFile page
      following: [],
      followingPublisher: followingPublishers,
      avatar: null,
    );
  }

  Future<List<Publisher>?> addFollowPublisher(String publisherId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> followingPublisherIds =
        prefs.getStringList('followingPublisherIds') ?? [];
    followingPublisherIds.add(publisherId);
    List<Publisher>? followPublisher =
        await fetchFollowPublisherData(followingPublisherIds);
    if (followPublisher != null) {
      await prefs.setStringList('followingPublisherIds', followingPublisherIds);
    }

    return followPublisher;
  }

  Future<List<Publisher>?> removeFollowPublisher(String publisherId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> followingPublisherIds =
        prefs.getStringList('followingPublisherIds') ?? [];
    followingPublisherIds.remove(publisherId);
    List<Publisher>? followPublisher =
        await fetchFollowPublisherData(followingPublisherIds);
    if (followPublisher != null) {
      await prefs.setStringList('followingPublisherIds', followingPublisherIds);
    }

    return followPublisher;
  }

  Future<List<Publisher>?> fetchFollowPublisherData(
      List<String> followingPublisherIdList) async {
    const String query = """
    query(
      \$followPublisherId: [ID!]
    ){
      publishers(
        where:{
          id:{
            in: \$followPublisherId
          }
        }
      ){
        id
        title
        logo
      }
    }
    """;

    Map<String, dynamic> variables = {
      "followPublisherId": followingPublisherIdList,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await getHeaders(),
    );

    if (jsonResponse.containsKey('errors')) {
      return null;
    }

    List<Publisher> followPublisher = [];
    for (var publisher in jsonResponse['data']['publishers']) {
      followPublisher.add(Publisher.fromJson(publisher));
    }
    return followPublisher;
  }
}
