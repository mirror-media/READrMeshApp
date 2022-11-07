import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createAndEdit/titleAndOgPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
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
            backgroundColor: Theme.of(context).backgroundColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitWanderingCubes(
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'updatingCollection'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: _buildBar(context),
          body: _buildBody(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0.5,
      centerTitle: GetPlatform.isIOS,
      leadingWidth: 75,
      leading: isEdit
          ? TextButton(
              child: Text(
                'cancel'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primaryLv3,
                ),
              ),
              onPressed: () => Get.back(),
            )
          : IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Theme.of(context).extension<CustomColors>()?.primary700,
              ),
              onPressed: () => Get.back(),
            ),
      title: Text(
        isEdit ? 'editCollectionTitle'.tr : 'title'.tr,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18,
          color: Theme.of(context).extension<CustomColors>()?.primary700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Obx(
          () {
            if (controller.collectionTitle.isEmpty) {
              return Container();
            } else if (isEdit &&
                controller.collectionTitle.value == title &&
                controller.collectionOgUrlOrPath.value == imageUrl) {
              return Container();
            }

            return TextButton(
              child: Text(
                isEdit ? 'save'.tr : 'nextStep'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Theme.of(context).extension<CustomColors>()?.blue,
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
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _ogImage(context),
        _title(context),
      ],
    );
  }

  Widget _ogImage(BuildContext context) {
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
                  width: context.width,
                  height: context.width / 2,
                  imageUrl: controller.collectionOgUrlOrPath.value,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: meshBlack66,
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: meshBlack66,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return Image.file(
                File(controller.collectionOgUrlOrPath.value),
                width: context.width,
                height: context.width / 2,
                fit: BoxFit.cover,
              );
            },
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            'changeCollectionOg'.tr,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()?.blue,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Obx(
        () => TextField(
          style: TextStyle(
            color: Theme.of(context).extension<CustomColors>()?.primary700,
            fontWeight: FontWeight.w400,
          ),
          controller: controller.titleTextController,
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv2!,
              ),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).extension<CustomColors>()!.primaryLv6!,
              ),
            ),
            hintText: 'collectionTitleHint'.tr,
            hintStyle: TextStyle(
              color: Theme.of(context).extension<CustomColors>()?.primaryLv4,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffix: (controller.collectionTitle.value.isEmpty)
                ? null
                : GestureDetector(
                    onTap: () {
                      controller.titleTextController.clear();
                      controller.collectionTitle.value = '';
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
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
