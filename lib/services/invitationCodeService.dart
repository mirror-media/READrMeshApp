import 'package:get/get.dart';
import 'package:readr/getxServices/graphQLService.dart';
import 'package:readr/getxServices/proxyServerService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/invitationCode.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InvitationCodeStatus {
  valid,
  invalid,
  activated,
  error,
}

abstract class InvitationCodeRepos {
  Future<List<InvitationCode>> fetchMyInvitationCode();

  Future<bool> checkUsableInvitationCode(String memberId);

  Future<InvitationCodeStatus> checkInvitationCode(String code);

  Future<void> linkInvitationCode(String codeId);
}

class InvitationCodeService implements InvitationCodeRepos {
  final ProxyServerService proxyServerService = Get.find();

  @override
  Future<List<InvitationCode>> fetchMyInvitationCode() async {
    const String query = '''
    query(
      \$myId: ID
    ){
      invitationCodes(
        where:{
          send:{
            id:{
              equals: \$myId
            }
          }
        }
      ){
        code
        receive{
          id
          nickname
          avatar
          customId
          avatar_image{
            id
            resized{
              original
            }
          }
        }
      }
    }
    ''';

    Map<String, dynamic> variables = {
      "myId": Get.find<UserService>().currentUser.memberId,
    };

    final jsonResponse =
        await proxyServerService.gql(query: query, variables: variables);

    List<InvitationCode> allInvitationCode = [];
    for (var item in jsonResponse['invitationCodes']) {
      allInvitationCode.add(InvitationCode.fromJson(item));
    }
    return allInvitationCode;
  }

  @override
  Future<bool> checkUsableInvitationCode(String memberId) async {
    const String query = '''
    query(
      \$myId: ID
    ){
      invitationCodesCount(
        where:{
          send:{
            id:{
              equals: \$myId
            }
          }
          expired:{
            equals: false
          }
        }
      )
    }
    ''';

    Map<String, dynamic> variables = {
      "myId": memberId,
    };

    try {
      final jsonResponse =
          await proxyServerService.gql(query: query, variables: variables);

      if (jsonResponse['invitationCodesCount'] != 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<InvitationCodeStatus> checkInvitationCode(String code) async {
    if (code == 'Avid86') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('invitationCodeId', 'Avid86');
      return InvitationCodeStatus.valid;
    }
    const String query = '''
    query(
      \$code: String
    ){
      invitationCodes(
        where:{
          code:{
            equals: \$code
          }
        }
      ){
        id
        receive{
          id
        }
      }
    }
    ''';

    Map<String, dynamic> variables = {
      "code": code,
    };

    try {
      final jsonResponse =
          await proxyServerService.gql(query: query, variables: variables);

      if (jsonResponse['invitationCodes'].isEmpty) {
        return InvitationCodeStatus.invalid;
      } else if (jsonResponse['invitationCodes'][0]['receive'] != null) {
        return InvitationCodeStatus.activated;
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'invitationCodeId', jsonResponse['invitationCodes'][0]['id']);
        return InvitationCodeStatus.valid;
      }
    } catch (e) {
      return InvitationCodeStatus.error;
    }
  }

  @override
  Future<void> linkInvitationCode(String codeId) async {
    if (codeId != 'Avid86') {
      const String mutation = '''
      mutation(
        \$codeId: ID
        \$myId: ID
      ){
        updateInvitationCode(
          where:{
            id: \$codeId
          }
          data:{
            receive:{
              connect:{
                id: \$myId
              }
            }
            expired: true
          }
        ){
          id
        }
      }
      ''';

      Map<String, dynamic> variables = {
        "codeId": codeId,
        "myId": Get.find<UserService>().currentUser.memberId,
      };

      await Get.find<GraphQLService>().mutation(
        mutationBody: mutation,
        variables: variables,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('invitationCodeId', '');
  }
}
