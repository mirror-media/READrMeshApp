import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
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
  final avatarImageUrl = ''.obs;
  final avatarImagePath = ''.obs;

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
      avatarImageUrl.value = Get.find<UserService>().currentUser.avatar ?? '';

    } catch (e) {
      print('EditPersonalFilePage error: $e');
      error = determineException(e);
      isError = true;
    }
    isLoading = false;
    update();
  }

  void savePersonalFile() async {
    nicknameError.value = false;
    customIdError.value = false;
    alreadyShowError.value = false;
    saveError.value = false;
    isSaving.value = true;
    try {
      List<Publisher> publisherList =
          await personalFileRepos.fetchAllPublishers();
      bool checkResult =
          _validateNickname(publisherList, nicknameController.text);
      if (!checkResult) {
        nicknameError.value = true;
        isSaving.value = false;
        formKey.currentState!.validate();
      } else {
        bool result;

        /// avatarImagePath is local image file path
        /// if not empty mean user choose local image to be avatar
        if (avatarImagePath.isNotEmpty) {
          await _deleteOldAvatar();
          result = await memberRepos
              .updateMemberAndAvatar(
                memberId: Get.find<UserService>().currentUser.memberId,
                nickname: nicknameController.text,
                customId: customIdController.text,
                intro: introController.text,
                imagePath: avatarImagePath.value,
              )
              .timeout(const Duration(seconds: 90));

        } else {
          // if avatarImageUrl is empty mean user delete avatar
          if (avatarImageUrl.isEmpty) {
            await _deleteOldAvatar();
          }
          result = await memberRepos
              .updateMember(
                memberId: Get.find<UserService>().currentUser.memberId,
                nickname: nicknameController.text,
                customId: customIdController.text,
                intro: introController.text,
              )
              .timeout(const Duration(seconds: 90));
        }

        if (result) {
          await Get.find<PersonalFilePageController>(
                  tag: Get.find<UserService>().currentUser.memberId)
              .fetchMemberData();
          // refresh to trigger bottom navigation bar icon update
          Get.find<UserService>().isMember.refresh();
          Fluttertoast.showToast(
            msg: "updateSuccessToast".tr,
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
        msg: "saveFailedToast".tr,
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

  //check nickname whether is same with any publisher name
  bool _validateNickname(List<Publisher> publisherList, String nickname) {
    for (var publisher in publisherList) {
      if (_equalsIgnoreCase(publisher.title, nickname)) {
        return false;
      }
    }
    return true;
  }

  bool _equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase() == string2.toLowerCase();
  }

  Future<void> _deleteOldAvatar() async {
    bool deleteImageResult;
    //use avatarImageId to determine whether remove photo item in CMS
    if (Get.find<UserService>().currentUser.avatarImageId != null) {
      deleteImageResult = await memberRepos
          .deleteAvatarPhoto(Get.find<UserService>().currentUser.avatarImageId!)
          .timeout(const Duration(seconds: 90));
    } else {
      deleteImageResult = await memberRepos
          .deleteAvatarUrl(Get.find<UserService>().currentUser.memberId)
          .timeout(const Duration(seconds: 90));
    }

    if (!deleteImageResult) {
      throw Exception('Delete old avatar image failed');
    }
  }

  void checkIsEdited() {
    if (nicknameController.text.isEmpty || customIdController.text.isEmpty) {
      isEdited.value = false;
    } else if (nicknameController.text !=
            Get.find<UserService>().currentUser.nickname ||
        customIdController.text !=
            Get.find<UserService>().currentUser.customId ||
        introController.text != Get.find<UserService>().currentUser.intro ||
        avatarImageUrl.isEmpty ||
        avatarImagePath.isNotEmpty) {

      isEdited.value = true;
    } else {
      isEdited.value = false;
    }
    introLength.value = introController.text.length;
  }
}
