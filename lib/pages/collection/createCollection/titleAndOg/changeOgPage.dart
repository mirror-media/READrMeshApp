import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createCollectionController.dart';
import 'package:readr/helpers/dataConstants.dart';

class ChangeOgPage extends GetView<CreateCollectionController> {
  @override
  Widget build(BuildContext context) {
    List<String> imageUrlList = [];
    for (var item in controller.selectedList) {
      if (item.heroImageUrl != null) {
        imageUrlList.add(item.heroImageUrl!);
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
          '選擇封面照片',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: readrBlack,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(5),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (context, index) => InkWell(
          child: CachedNetworkImage(
            imageUrl: imageUrlList[index],
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
          onTap: () {
            controller.collectionOgUrl.value = controller.selectedList
                .firstWhere(
                    (element) => element.heroImageUrl == imageUrlList[index])
                .heroImageUrl!;
            Get.back();
          },
        ),
        itemCount: imageUrlList.length,
      ),
    );
  }
}
