import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createCollectionController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/collection/createCollection/descriptionPage.dart';
import 'package:readr/pages/collection/shared/changeOgPage.dart';

class InputTitlePage extends GetView<CreateCollectionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: GetPlatform.isIOS,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: readrBlack87,
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        '標題',
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18,
          color: readrBlack,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Obx(
          () {
            if (controller.collectionTitle.isNotEmpty) {
              return TextButton(
                child: const Text(
                  '下一步',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  controller.collectionDescription.value = '';
                  Get.to(() => DescriptionPage());
                },
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _ogImage(),
        _title(),
      ],
    );
  }

  Widget _ogImage() {
    return GestureDetector(
      onTap: () async {
        List<String> imageUrlList = [];
        for (var item in controller.selectedList) {
          if (item.news!.heroImageUrl != null) {
            imageUrlList.add(item.news!.heroImageUrl!);
          }
        }
        controller.collectionOgUrlOrPath.value =
            await Get.to(() => ChangeOgPage(imageUrlList));
      },
      child: Column(
        children: [
          Obx(
            () {
              if (controller.collectionOgUrlOrPath.value.contains('http')) {
                return CachedNetworkImage(
                  width: Get.width,
                  height: Get.width / 2,
                  imageUrl: controller.collectionOgUrlOrPath.value,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: readrBlack66,
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: readrBlack66,
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return Image.file(
                File(controller.collectionOgUrlOrPath.value),
                width: Get.width,
                height: Get.width / 2,
                fit: BoxFit.cover,
              );
            },
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            '更換封面照片',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Obx(
        () => TextField(
          style: const TextStyle(color: readrBlack87),
          controller: controller.titleTextController,
          decoration: InputDecoration(
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: readrBlack66,
              ),
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white10,
              ),
            ),
            hintText: '輸入集錦標題',
            hintStyle: const TextStyle(color: readrBlack30),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffix: (controller.collectionTitle.value.isEmpty)
                ? null
                : GestureDetector(
                    onTap: () {
                      controller.titleTextController.clear();
                      controller.collectionTitle.value = '';
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: readrBlack87,
                      size: 16,
                    ),
                  ),
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) => controller.collectionTitle.value = value,
        ),
      ),
    );
  }
}
