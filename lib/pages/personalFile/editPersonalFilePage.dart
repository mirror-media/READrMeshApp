import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/editPersonalFilePageController.dart';
import 'package:readr/helpers/dataConstants.dart';
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
          backgroundColor: Colors.white,
          appBar: _buildBar(),
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
                  return _buildForm(context);
                }

                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              },
            ),
          ),
        ));
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0.5,
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
                  ? const Text(
                      '取消',
                      style: TextStyle(
                        color: readrBlack50,
                        fontSize: 18,
                      ),
                    )
                  : const Icon(
                      Icons.close,
                      color: readrBlack,
                    ),
            ),
          );
        },
      ),
      centerTitle: GetPlatform.isIOS,
      title: const Text('編輯個人檔案',
          style: TextStyle(
            fontSize: 18,
            color: readrBlack,
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
                  controller.isSaving.value ? '更新中' : '儲存',
                  style: const TextStyle(
                    color: Colors.blue,
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
        child: Column(
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
                style: const TextStyle(
                  color: readrBlack87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: '姓名',
                  labelStyle: const TextStyle(
                    color: readrBlack50,
                    fontSize: 18,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: readrBlack87,
                    ),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white10,
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
                          child: const Icon(
                            Icons.cancel,
                            color: readrBlack87,
                            size: 16,
                          ),
                        ),
                ),
                validator: (value) {
                  if (controller.nicknameError.isTrue) {
                    return '這個名稱目前無法使用，請使用其他名稱。';
                  }

                  return value!.trim().isNotEmpty ? null : "姓名不能空白";
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
                style: const TextStyle(
                  color: readrBlack87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'ID',
                  labelStyle: const TextStyle(
                    color: readrBlack50,
                    fontSize: 18,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: readrBlack87,
                    ),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white10,
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
                          child: const Icon(
                            Icons.cancel,
                            color: readrBlack87,
                            size: 16,
                          ),
                        ),
                ),
                validator: (value) {
                  if (controller.customIdError.value) {
                    return '這個 ID 目前無法使用，請使用其他 ID。';
                  }
                  return value!.trim().isNotEmpty ? null : "ID不能空白";
                },
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '簡介',
                    style: TextStyle(
                      color: readrBlack50,
                      fontSize: 14,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(
                    () => Text(
                      '${controller.introLength}/250字',
                      style: const TextStyle(
                        color: readrBlack50,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: Obx(
                () => TextFormField(
                  controller: controller.introController,
                  focusNode: controller.introFocusNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 250,
                  readOnly: controller.isSaving.isTrue,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  onChanged: (value) {
                    controller.checkIsEdited();
                  },
                  style: const TextStyle(
                    color: readrBlack87,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: '向大家介紹一下自己吧...',
                    hintStyle: TextStyle(
                      color: readrBlack30,
                      fontSize: 16,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: readrBlack87,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white10,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(12),
                    counterText: '',
                  ),
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
}
