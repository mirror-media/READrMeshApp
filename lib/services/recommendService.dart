import 'dart:convert';

import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';

abstract class RecommendRepos {
  Future<List<Publisher>> fetchAllPublishers();
  Future<List<Member>> fetchRecommendedMembers();
}

class RecommendService implements RecommendRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  final String api = Environment().config.readrMeshApi;

  Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    return headers;
  }

  @override
  Future<List<Publisher>> fetchAllPublishers() async {
    const String query = """
    query(
      \$readrId: ID
    ){
      publishers(
        where:{
          id:{
            not:{
              equals: \$readrId
            }
          }
        }
      ){
        id
        title
        customId
        followerCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
      }
    }
    """;

    Map<String, dynamic> variables = {
      "readrId": Environment().config.readrPublisherId
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
      headers: await _getHeaders(),
    );

    List<Publisher> allPublisherList = [];
    for (var publisher in jsonResponse['data']['publishers']) {
      allPublisherList.add(Publisher.fromJson(publisher));
    }

    return allPublisherList;
  }

  @override
  Future<List<Member>> fetchRecommendedMembers() async {
    const String query = """
    query(
      \$followPublisher: [ID!]
      \$myId: ID
    ){
      recommendMember: members(
        where:{
          follow_publisher:{
            some:{
              id:{
                in: \$followPublisher
              }
            }
          }
          is_active:{
            equals: true
          }
          id:{
            not:{
              equals: \$myId
            }
          }
        }
        take: 20
      ){
        id
        nickname
        customId
        avatar
      }
      otherMember: members(
        where:{
          is_active:{
            equals: true
          }
          id:{
            not:{
              equals: \$myId
            }
          }
        }
        take: 20
      ){
        id
        nickname
        customId
        avatar
      }
    }
    """;

    List<String> followPublisherIdList = [];
    for (var publisher in UserHelper.instance.localPublisherList) {
      followPublisherIdList.add(publisher.id);
    }

    Map<String, dynamic> variables = {
      "followPublisher": followPublisherIdList,
      "myId": UserHelper.instance.currentUser.memberId,
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
      headers: await _getHeaders(),
    );

    List<Member> recommedMembers = [];
    for (var member in jsonResponse['data']['recommendMember']) {
      recommedMembers.add(Member.fromJson(member));
    }

    if (recommedMembers.length < 20) {
      for (var item in jsonResponse['data']['otherMember']) {
        Member member = Member.fromJson(item);
        if (!recommedMembers
            .any((element) => element.memberId == member.memberId)) {
          recommedMembers.add(member);
          if (recommedMembers.length == 20) {
            break;
          }
        }
      }
    }

    return recommedMembers;
  }
}
