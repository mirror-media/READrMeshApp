import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:readr/controller/collection/createCollectionController.dart';
import 'package:readr/helpers/dataConstants.dart';

class ChangeOgPage extends GetView<CreateCollectionController> {
  @override
  Widget build(BuildContext context) {
    List<String> imageUrlList = [];
    for (var item in controller.selectedList) {
      if (item.news!.heroImageUrl != null) {
        imageUrlList.add(item.news!.heroImageUrl!);
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
          '更換封面照片',
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
        padding: const EdgeInsets.all(0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.0,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: () async => await _showImageBottomSheet(context),
              hoverColor: readrBlack50,
              child: Container(
                color: readrBlack30,
                child: const Icon(
                  CupertinoIcons.camera,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            );
          }
          return InkWell(
            child: CachedNetworkImage(
              imageUrl: imageUrlList[index - 1],
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
              controller.collectionOgUrlOrPath.value = imageUrlList[index - 1];
              Get.back();
            },
          );
        },
        itemCount: imageUrlList.length + 1,
      ),
    );
  }

  Future<void> _showImageBottomSheet(BuildContext context) async {
    String? result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('camera'),
            child: const Text(
              '開啟相機',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('photo'),
            child: const Text(
              '選擇照片',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: const Text(
            '取消',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );

    try {
      if (result == 'photo' || result == 'camera') {
        final XFile? image = await ImagePicker().pickImage(
            source:
                result == 'photo' ? ImageSource.gallery : ImageSource.camera);
        if (image != null) {
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: '裁切',
                toolbarColor: Colors.white,
                toolbarWidgetColor: readrBlack87,
                statusBarColor: readrBlack87,
                initAspectRatio: CropAspectRatioPreset.original,
                backgroundColor: Colors.white,
                activeControlsWidgetColor: Colors.blue,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: '裁切',
                doneButtonTitle: '完成',
                cancelButtonTitle: '取消',
              ),
            ],
          );

          if (croppedFile != null) {
            controller.collectionOgUrlOrPath.value = croppedFile.path;
            Get.back();
          }
        }
      }
    } catch (e) {
      print('Pick photo error: $e');
    }
  }
}
