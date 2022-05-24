import 'package:get/get.dart';
import 'package:readr/controller/mainAppBarController.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/invitationCode.dart';
import 'package:readr/services/invitationCodeService.dart';

class InvitationCodePageController extends GetxController {
  final InvitationCodeRepos invitationCodeRepos;
  InvitationCodePageController(this.invitationCodeRepos);

  final List<InvitationCode> usableCodeList = [];
  final List<InvitationCode> activatedCodeList = [];

  bool isLoading = true;
  bool isError = false;
  dynamic error;

  @override
  void onInit() {
    fetchMyInvitationCode();
    super.onInit();
  }

  void fetchMyInvitationCode() async {
    isLoading = true;
    isError = false;
    update();
    try {
      List<InvitationCode> allMyInvitationCodes =
          await invitationCodeRepos.fetchMyInvitationCode();
      usableCodeList.clear();
      activatedCodeList.clear();
      for (var code in allMyInvitationCodes) {
        if (code.activeMember == null) {
          usableCodeList.add(code);
        } else {
          activatedCodeList.add(code);
        }
      }

      //update app bar icon
      if (usableCodeList.isNotEmpty) {
        Get.find<MainAppBarController>().hasInvitationCode.value = true;
      } else {
        Get.find<MainAppBarController>().hasInvitationCode.value = false;
      }
    } catch (e) {
      print('Fetch invitation code error: $e');
      error = determineException(e);
      isError = true;
    }
    isLoading = false;
    update();
  }
}
