import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/editCollectionController.dart';
import 'package:readr/getxServices/internetCheckService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/pages/collection/editCollection/titleAndOg/editOgPage.dart';
import 'package:readr/services/collectionService.dart';

class EditTitlePage extends GetView<EditCollectionController> {
  final Collection collection;
  const EditTitlePage({required this.collection});

  @override
  Widget build(BuildContext context) {
    Get.put(EditCollectionController(
      collectionRepos: CollectionService(),
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
      leading: TextButton(
        child: const Text(
          '取消',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: readrBlack50,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        '修改標題',
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
            if (controller.title.isNotEmpty) {
              return TextButton(
                child: const Text(
                  '儲存',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () async {
                  if (await Get.find<InternetCheckService>()
                      .meshCheckInstance
                      .hasConnection) {
                    controller.updateTitleAndOg();
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
      onTap: () => Get.to(() => EditOgPage()),
      child: Column(
        children: [
          Obx(
            () => CachedNetworkImage(
              width: Get.width,
              height: Get.width / 2,
              imageUrl: controller.heroImageUrl.value,
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
            ),
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
            suffix: (controller.title.value.isEmpty)
                ? null
                : GestureDetector(
                    onTap: () {
                      controller.titleTextController.clear();
                      controller.title.value = '';
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: readrBlack87,
                      size: 16,
                    ),
                  ),
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) => controller.title.value = value,
        ),
      ),
    );
  }
}
