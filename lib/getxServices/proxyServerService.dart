import 'dart:convert';

import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/models/graphqlBody.dart';

class ProxyServerService extends GetxService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final EnvironmentService environmentService = Get.find();
  late final GraphQLClient client;
  late String proxyServerEndPoint;
  late String proxyServerApiPath;
  late String authToken;

  Future<ProxyServerService> init() async {
    proxyServerApiPath = environmentService.config.proxyServerApi;
    proxyServerEndPoint = environmentService.config.readrMeshApi;
    final meshHttpLink = HttpLink(proxyServerEndPoint);

    final meshToken = await _fetchCMSUserToken(proxyServerEndPoint);
    authToken = meshToken;

    final meshAuthLink = AuthLink(
      getToken: () => 'Bearer $meshToken',
    );

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: meshAuthLink.concat(meshHttpLink),
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
      "email": environmentService.config.appHelperEmail,
      "password": environmentService.config.appHelperPassword,
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

  Future<void> test() async {
    String query = """
        query{
          announcements(
            orderBy:{
              createdAt: desc
            }
            where:{
              status:{
                equals: "published"
              }
            }
          ){
            name
            type
          }
        }
    """;
    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: {},
    );
    final jsonResponse = await _helper.postByUrl(
        'https://mesh-proxy-server-dev-4g6paft7cq-de.a.run.app/forward',
        jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});
  }

  Future<dynamic> gql(
      {required String query, Map<String, dynamic>? variables}) async {
    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables ?? {},
    );

    final jsonResponse = await _helper.postByUrl(
        '$proxyServerApiPath/gql', jsonEncode(graphqlBody.toJson()),
        headers: {
          "Content-Type": "application/json",
          "Bearer": authToken,
          "token":authToken,
        }) as Map<String, dynamic>;
    if (jsonResponse.containsKey('data')) {
      return jsonResponse['data'];
    }

    return jsonResponse;
  }
}
