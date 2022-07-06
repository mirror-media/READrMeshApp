import 'dart:convert';

import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/models/graphqlBody.dart';

enum Api {
  readr,
  mesh,
}

class GraphQLService extends GetxService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  late final GraphQLClient _meshClient;
  late final GraphQLClient _readrClient;

  Future<GraphQLService> init() async {
    final meshHttpLink =
        HttpLink(Get.find<EnvironmentService>().config.readrMeshApi);
    final readrHttpLink =
        HttpLink(Get.find<EnvironmentService>().config.readrApi);
    final meshToken = await _fetchCMSUserToken(
        Get.find<EnvironmentService>().config.readrMeshApi);

    final meshAuthLink = AuthLink(
      getToken: () => 'Bearer $meshToken',
    );

    _meshClient = GraphQLClient(
      cache: GraphQLCache(),
      link: meshAuthLink.concat(meshHttpLink),
    );

    _readrClient = GraphQLClient(
      cache: GraphQLCache(),
      link: readrHttpLink,
    );
    return this;
  }

  Future<String> _fetchCMSUserToken(String api) async {
    String mutation = """
    mutation(
	    \$email: String!,
	    \$password: String!
    ){
	    authenticateUserWithPassword(
		    email: \$email
		    password: \$password
      ){
        ... on UserAuthenticationWithPasswordSuccess{
        	sessionToken
      	}
        ... on UserAuthenticationWithPasswordFailure{
          message
      	}
      }
    }
    """;

    Map<String, String> variables = {
      "email": Get.find<EnvironmentService>().config.appHelperEmail,
      "password": Get.find<EnvironmentService>().config.appHelperPassword,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        api, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String token =
        jsonResponse['data']['authenticateUserWithPassword']['sessionToken'];

    return token;
  }

  Future<QueryResult> query({
    required Api api,
    required String queryBody,
    Map<String, dynamic>? variables,
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(queryBody),
      variables: variables ?? {},
    );

    final GraphQLClient client;
    switch (api) {
      case Api.readr:
        client = _readrClient;
        break;
      case Api.mesh:
        client = _meshClient;
        break;
    }

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print('Query error');
      print(result.exception.toString());
    }

    return result;
  }

  //only for mesh API
  Future<QueryResult> mutation({
    required String mutationBody,
    Map<String, dynamic>? variables,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(mutationBody),
      variables: variables ?? {},
    );

    final QueryResult result = await _meshClient.mutate(options);

    if (result.hasException) {
      print('Mutation error');
      print(result.exception.toString());
    }

    return result;
  }
}
