import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';

class EditPersonalFilePageController extends GetxController {
  final MemberRepos memberRepos;
  final PersonalFileRepos personalFileRepos;
  EditPersonalFilePageController(
      {required this.memberRepos, required this.personalFileRepos});

  late final TextEditingController nicknameController;
  late final TextEditingController customIdController;
  late final TextEditingController introController;
  final FocusNode nicknameFocusNode = FocusNode();
  final FocusNode customIdFocusNode = FocusNode();
  final FocusNode introFocusNode = FocusNode();
  final isFocusNickname = false.obs;
  final isFocusCustomId = false.obs;
  final isSaving = false.obs;
  final customIdError = false.obs;
  final nicknameError = false.obs;
  final alreadyShowError = false.obs;
  final saveError = false.obs;
  final isEdited = false.obs;
  final introLength = 0.obs;
  final formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isError = false;
  dynamic error;

  @override
  void onInit() {
    loadPersonalFile();
    nicknameFocusNode.addListener(() {
      if (nicknameFocusNode.hasFocus) {
        isFocusNickname.value = true;
        isFocusCustomId.value = false;
      }
    });
    customIdFocusNode.addListener(() {
      if (customIdFocusNode.hasFocus) {
        isFocusNickname.value = false;
        isFocusCustomId.value = true;
      }
    });
    introFocusNode.addListener(() {
      if (introFocusNode.hasFocus) {
        isFocusNickname.value = false;
        isFocusCustomId.value = false;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    if (!isError) {
      nicknameFocusNode.dispose();
      customIdFocusNode.dispose();
      introFocusNode.dispose();
      nicknameController.dispose();
      customIdController.dispose();
      introController.dispose();
    }
    super.onClose();
  }

  void loadPersonalFile() async {
    isLoading = true;
    isError = false;
    update();
    try {
      await Get.find<UserService>().fetchUserData();
      nicknameController = TextEditingController(
          text: Get.find<UserService>().currentUser.nickname);
      customIdController = TextEditingController(
          text: Get.find<UserService>().currentUser.customId);
      introController = TextEditingController(
          text: Get.find<UserService>().currentUser.intro);
      introLength.value =
          Get.find<UserService>().currentUser.intro?.length ?? 0;
    } catch (e) {
      print('EditPersonalFilePage error: $e');
      error = determineException(e);
      isError = true;
    }
    isLoading = false;
    update();
  }

  void savePersonalFile() async {
    Member member = Member(
      memberId: Get.find<UserService>().currentUser.memberId,
      nickname: nicknameController.text,
      customId: customIdController.text,
      avatar: Get.find<UserService>().currentUser.avatar,
      intro: introController.text,
      followingPublisher:
          Get.find<UserService>().currentUser.followingPublisher,
      following: Get.find<UserService>().currentUser.following,
    );
    nicknameError.value = false;
    customIdError.value = false;
    alreadyShowError.value = false;
    saveError.value = false;
    isSaving.value = true;
    try {
      List<Publisher> publisherList =
          await personalFileRepos.fetchAllPublishers();
      bool checkResult = _validateNicknameAndId(publisherList, member);
      if (!checkResult) {
        nicknameError.value = true;
        isSaving.value = false;
        formKey.currentState!.validate();
      } else {
        bool? result = await memberRepos
            .updateMember(member)
            .timeout(const Duration(seconds: 90), onTimeout: () => null);
        if (result == null) {
          Fluttertoast.showToast(
            msg: "儲存失敗 請稍後再試一次",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          saveError.value = true;
          isSaving.value = false;
        } else if (result) {
          await Get.find<PersonalFilePageController>(tag: 'OwnPersonalFile')
              .fetchMemberData();
          Fluttertoast.showToast(
            msg: "更新完成",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Get.back();
        } else {
          customIdError.value = true;
          isSaving.value = false;
          formKey.currentState!.validate();
        }
      }
    } catch (e) {
      print('Save new personal file error: $e');
      Fluttertoast.showToast(
        msg: "儲存失敗 請稍後再試一次",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      saveError.value = true;
      isSaving.value = false;
    }
  }

  bool _validateNicknameAndId(List<Publisher> publisherList, Member member) {
    for (var publisher in publisherList) {
      if (_equalsIgnoreCase(publisher.title, member.nickname)) {
        return false;
      }
    }
    return true;
  }

  bool _equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase() == string2.toLowerCase();
  }

  void checkIsEdited() {
    if (nicknameController.text.isEmpty || customIdController.text.isEmpty) {
      isEdited.value = false;
    } else if (nicknameController.text !=
        Get.find<UserService>().currentUser.nickname) {
      isEdited.value = true;
    } else if (customIdController.text !=
        Get.find<UserService>().currentUser.customId) {
      isEdited.value = true;
    } else if (introController.text !=
        Get.find<UserService>().currentUser.intro) {
      isEdited.value = true;
    } else {
      isEdited.value = false;
    }
    introLength.value = introController.text.length;
  }
}
