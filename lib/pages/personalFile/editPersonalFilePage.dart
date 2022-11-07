import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/controller/personalFile/editPersonalFilePageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';

class EditPersonalFilePage extends GetView<EditPersonalFilePageController> {
  @override
  Widget build(BuildContext context) {
    Get.put(EditPersonalFilePageController(
      memberRepos: MemberService(),
      personalFileRepos: PersonalFileService(),
    ));
    return WillPopScope(
        onWillPop: () async => controller.isSaving.isFalse,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: _buildBar(context),
          body: SafeArea(
            child: GetBuilder<EditPersonalFilePageController>(
              builder: (controller) {
                if (controller.isError) {
                  return ErrorPage(
                    error: controller.error,
                    onPressed: () => controller.loadPersonalFile(),
                    hideAppbar: true,
                  );
                }

                if (!controller.isLoading) {
                  return GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: ListView(
                      children: [
                        _buildAvatar(context),
                        const Divider(
                          thickness: 1,
                          height: 1,
                        ),
                        _buildForm(context),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              },
            ),
          ),
        ));
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: Obx(
        () {
          if (controller.isSaving.isTrue) {
            return Container();
          }

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () => Get.back(result: false),
              child: GetPlatform.isIOS
                  ? Text(
                      'cancel'.tr,
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv3!,
                        fontSize: 18,
                      ),
                    )
                  : Icon(
                      Icons.close,
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary700!,
                    ),
            ),
          );
        },
      ),
      leadingWidth: 80,
      centerTitle: GetPlatform.isIOS,
      title: Text('editPersonalFile'.tr,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
            fontWeight: FontWeight.w400,
          )),
      actions: [
        Obx(
          () {
            if (controller.isEdited.isTrue) {
              return TextButton(
                onPressed: controller.isSaving.value
                    ? null
                    : () {
                        controller.savePersonalFile();
                      },
                child: Text(
                  controller.isSaving.value ? 'updating'.tr : 'save'.tr,
                  style: TextStyle(
                    color: Theme.of(context).extension<CustomColors>()!.blue!,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }
            return Container();
          },
        )
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        autovalidateMode: AutovalidateMode.always,
        key: controller.formKey,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const SizedBox(
              height: 20,
            ),
            Obx(
              () => TextFormField(
                focusNode: controller.nicknameFocusNode,
                controller: controller.nicknameController,
                autocorrect: false,
                keyboardType: TextInputType.name,
                maxLength: 20,
                readOnly: controller.isSaving.isTrue,
                onChanged: (value) {
                  controller.nicknameError.value = false;
                  controller.checkIsEdited();
                },
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  labelText: 'name'.tr,
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primaryLv3!,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary700!,
                    ),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv6!,
                    ),
                  ),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  suffix: (controller.nicknameController.text.isEmpty ||
                          !controller.isFocusNickname.value)
                      ? null
                      : GestureDetector(
                          onTap: () {
                            controller.nicknameController.clear();
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .primary700!,
                            size: 16,
                          ),
                        ),
                ),
                validator: (value) {
                  if (controller.nicknameError.isTrue) {
                    return 'nameError'.tr;
                  }

                  return value!.trim().isNotEmpty ? null : "nameEmptyError".tr;
                },
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Obx(
              () => TextFormField(
                controller: controller.customIdController,
                focusNode: controller.customIdFocusNode,
                keyboardType: TextInputType.name,
                autocorrect: false,
                readOnly: controller.isSaving.isTrue,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[\u4E00-\u9FFF]')),
                  FilteringTextInputFormatter.allow(RegExp(r'[_.\w]'))
                ],
                onChanged: (value) {
                  controller.customIdError.value = false;
                  controller.checkIsEdited();
                },
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  labelText: 'ID',
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primaryLv3!,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary700!,
                    ),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv6!,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  suffix: (controller.customIdController.text.isEmpty ||
                          !controller.isFocusCustomId.value)
                      ? null
                      : GestureDetector(
                          onTap: () {
                            controller.customIdController.clear();
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .primary700!,
                            size: 16,
                          ),
                        ),
                ),
                validator: (value) {
                  if (controller.customIdError.value) {
                    return 'customIdError'.tr;
                  }
                  return value!.trim().isNotEmpty
                      ? null
                      : "customIdEmptyError".tr;
                },
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'introduction'.tr,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv3!,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(
                    () => Text(
                      '${controller.introLength}/250 ${'characters'.tr}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv3!,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Obx(
              () => TextFormField(
                controller: controller.introController,
                focusNode: controller.introFocusNode,
                keyboardType: TextInputType.multiline,
                maxLines: 17,
                maxLength: 250,
                readOnly: controller.isSaving.isTrue,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (value) {
                  controller.checkIsEdited();
                },
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'introductionHint'.tr,
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primaryLv4!,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary700!,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primaryLv6!,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    Color randomColor = Colors.primaries[
        int.parse(Get.find<UserService>().currentUser.memberId) %
            Colors.primaries.length];
    Color textColor =
        randomColor.computeLuminance() > 0.5 ? meshBlack87 : Colors.white;
    List<String> splitNickname =
        Get.find<UserService>().currentUser.nickname.split('');
    String firstLetter = '';
    for (int i = 0; i < splitNickname.length; i++) {
      if (splitNickname[i] != " ") {
        firstLetter = splitNickname[i];
        break;
      }
    }

    Widget child = AutoSizeText(
      firstLetter,
      style: TextStyle(color: textColor, fontSize: 40),
      minFontSize: 5,
    );

    return GestureDetector(
      onTap: () async => await _showAvatarBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        color: Theme.of(context).backgroundColor,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Obx(
              () {
                ImageProvider? image;
                if (controller.avatarImagePath.isNotEmpty) {
                  image = FileImage(File(controller.avatarImagePath.value));
                } else if (controller.avatarImageUrl.isNotEmpty) {
                  image = NetworkImage(controller.avatarImageUrl.value);
                }

                return CircleAvatar(
                  backgroundColor: randomColor,
                  foregroundImage: image,
                  radius: 40,
                  child: child,
                );
              },
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              'changeAvatar'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.blue!,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showAvatarBottomSheet(BuildContext context) async {
    String? result;
    if (GetPlatform.isIOS) {
      result = await showCupertinoModalPopup<String>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop('camera'),
              child: Text(
                'openCamera'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: Theme.of(context).extension<CustomColors>()!.blue!,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop('photo'),
              child: Text(
                'choosePhoto'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: Theme.of(context).extension<CustomColors>()!.blue!,
                ),
              ),
            ),
            if (controller.avatarImageUrl.isNotEmpty ||
                controller.avatarImagePath.isNotEmpty)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop('delete'),
                child: Text(
                  'deleteAvatar'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color:
                        Theme.of(context).extension<CustomColors>()!.redText!,
                  ),
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Theme.of(context).extension<CustomColors>()!.blue!,
              ),
            ),
          ),
        ),
      );
    } else {
      result = await showCupertinoModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        topRadius: const Radius.circular(24),
        builder: (context) => Material(
          color: Theme.of(context).backgroundColor,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: Container(
                    height: 4,
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Theme.of(context).backgroundColor,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .primaryLv5!,
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop('camera'),
                  icon: Icon(
                    Icons.photo_camera_outlined,
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primary700!,
                    size: 18,
                  ),
                  label: Text(
                    'openCamera'.tr,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary700!,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop('photo'),
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context)
                        .extension<CustomColors>()!
                        .primary700!,
                    size: 18,
                  ),
                  label: Text(
                    'choosePhoto'.tr,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary700!,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                if (controller.avatarImageUrl.isNotEmpty ||
                    controller.avatarImagePath.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop('delete'),
                    icon: Icon(
                      Icons.delete_outlined,
                      color: Theme.of(context).extension<CustomColors>()!.red!,
                      size: 18,
                    ),
                    label: Text(
                      'deleteAvatar'.tr,
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomColors>()!
                            .redText!,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    try {
      if (result == 'photo' || result == 'camera') {
        final XFile? image = await ImagePicker().pickImage(
            source:
                result == 'photo' ? ImageSource.gallery : ImageSource.camera);
        if (image != null) {
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            cropStyle: CropStyle.circle,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'crop'.tr,
                toolbarColor: Theme.of(context).backgroundColor,
                toolbarWidgetColor:
                    Theme.of(context).extension<CustomColors>()!.primary700!,
                statusBarColor:
                    Theme.of(context).extension<CustomColors>()!.primary700!,
                initAspectRatio: CropAspectRatioPreset.original,
                backgroundColor: Theme.of(context).backgroundColor,
                activeControlsWidgetColor:
                    Theme.of(context).extension<CustomColors>()!.blue!,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'crop'.tr,
              ),
            ],
          );

          if (croppedFile != null) {
            controller.avatarImagePath.value = croppedFile.path;
            controller.isEdited.value = true;
          }
        }
      } else if (result == 'delete') {
        controller.avatarImagePath.value = '';
        controller.avatarImageUrl.value = '';
      }
      controller.checkIsEdited();
    } catch (e) {
      print('Pick photo error: $e');
    }
  }
}
