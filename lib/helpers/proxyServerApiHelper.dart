import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';

class ProxyServerApiHelper extends GetConnect {
  ProxyServerApiHelper._();

  static final ProxyServerApiHelper _instance = ProxyServerApiHelper._();

  static ProxyServerApiHelper get instance => _instance;
  final ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  final EnvironmentService environmentService = Get.find();
  ValueNotifier<GraphQLClient>? client;

  @override
  void onInit() {
    final Link link = HttpLink(environmentService.config.readrMeshApi);
    client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      ),
    );
  }

  Future test ()async {



  }

}
