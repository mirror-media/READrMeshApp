import 'dart:convert';

import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/cacheDurationCache.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/models/graphqlBody.dart';

abstract class EditorChoiceRepos {
  Future<List<EditorChoiceItem>> fetchEditorChoiceList();
}

class EditorChoiceServices implements EditorChoiceRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<EditorChoiceItem>> fetchEditorChoiceList() async {
    const key = 'fetchEditorChoiceList';

    String query = """
    query(
      \$where: EditorChoiceWhereInput, 
      \$first: Int){
      allEditorChoices(
        where: \$where, 
        first: \$first, 
        sortBy: [sortOrder_ASC, createdAt_DESC]
      ) {
        name
        link
        publishTime
        heroImage {
          urlMobileSized
        }
        choice {
          id
          slug
          style
          ogDescription
          readingTime
          heroImage {
            urlMobileSized
          }
          heroVideo {
            coverPhoto {
              urlMobileSized
            }
          }
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {"state": "published"},
      "first": 3
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: editorChoiceCacheDuration,
        headers: {"Content-Type": "application/json"});

    List<EditorChoiceItem> editorChoiceList = [];
    for (int i = 0; i < jsonResponse['data']['allEditorChoices'].length; i++) {
      editorChoiceList.add(EditorChoiceItem.fromJson(
          jsonResponse['data']['allEditorChoices'][i]));
    }
    return editorChoiceList;
  }
}
