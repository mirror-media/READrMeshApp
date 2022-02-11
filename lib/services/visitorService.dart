import 'dart:convert';

import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitorService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  // TODO: Change to Environment config when all environment built
  final String api = DevConfig().keystoneApi;

  Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    return headers;
  }

  Future<Member> fetchMemberData() async {
    // fetch shared preferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> followingMemberIds =
        prefs.getStringList('followingMemberIds') ?? [];
    final List<String> followingCategorySlugs =
        prefs.getStringList('followingCategorySlugs') ?? [];
    final List<String> followingPublisherIds =
        prefs.getStringList('followingPublisherIds') ?? [];

    // fetch remain data by id and slug
    const String query = """
    query(
      \$followingMembers: [ID!]
      \$followingCategorySlugs: [String!]
      \$followingPublisherIds: [ID!]
    ){
      followingMember: members(
        where:{
          is_active:{
            equals: true
          }
          id:{
            in: \$followingMembers
          }
        }
      ){
        id
        nickname
        email
        avatar
      }
      followingCategory: categories(
        where:{
          slug:{
            in: \$followingCategorySlugs
          }
        }
      ){
        id
        slug
        title
      }
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
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "followingCategorySlugs": followingCategorySlugs,
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

    List<Member> followingMembers = [];
    for (var member in jsonResponse['data']['followingMember']) {
      followingMembers.add(Member.fromJson(member));
    }

    List<Category> followingCategories = [];
    for (var category in jsonResponse['data']['followingCategory']) {
      followingCategories.add(Category.fromNewProductJson(category));
    }

    List<Publisher> followingPublishers = [];
    for (var publisher in jsonResponse['data']['followingPublisher']) {
      followingPublishers.add(Publisher.fromJson(publisher));
    }

    return Member(
      memberId: "-1",
      nickname: "訪客",
      following: followingMembers,
      followingCategory: followingCategories,
      followingPublisher: followingPublishers,
    );
  }
}
