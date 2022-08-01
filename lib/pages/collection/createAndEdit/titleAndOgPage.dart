import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createAndEdit/titleAndOgPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/createAndEdit/descriptionPage.dart';
import 'package:readr/pages/collection/createAndEdit/changeOgPage.dart';
import 'package:readr/services/collectionService.dart';

class TitleAndOgPage extends GetView<TitleAndOgPageController> {
  final String? title;
  final String imageUrl;
  final bool isEdit;
  final List<String> ogImageUrlList;
  final Collection? collection;
  const TitleAndOgPage(
    this.title,
    this.imageUrl,
    this.ogImageUrlList, {
    this.isEdit = false,
    this.collection,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(TitleAndOgPageController(
      title,
      imageUrl,
      CollectionService(),
      collection: collection,
    ));
    return Obx(
      () {
        if (controller.isUpdating.isTrue) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SpinKitWanderingCubes(
                  color: readrBlack,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    '更新集錦中',
                    style: TextStyle(
                      fontSize: 20,
                      color: readrBlack,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildBar(),
          body: _buildBody(),
        );
      },
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: GetPlatform.isIOS,
      leading: isEdit
          ? TextButton(
              child: const Text(
                '取消',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: readrBlack50,
                ),
              ),
              onPressed: () => Get.back(),
            )
          : IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: readrBlack87,
              ),
              onPressed: () => Get.back(),
            ),
      title: Text(
        isEdit ? '修改標題' : '標題',
        style: const TextStyle(
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
                child: Text(
                  isEdit ? '儲存' : '下一步',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  if (isEdit) {
                    controller.updateTitleAndOg();
                  } else {
                    Get.to(() => const DescriptionPage());
                  }
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
        controller.collectionOgUrlOrPath.value =
            await Get.to(() => ChangeOgPage(ogImageUrlList));
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
