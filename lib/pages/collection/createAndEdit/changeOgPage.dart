import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readr/helpers/dataConstants.dart';

class ChangeOgPage extends StatelessWidget {
  final List<String> imageUrlList;
  const ChangeOgPage(this.imageUrlList);

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'changeCollectionOg'.tr,
          style: const TextStyle(
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
            onTap: () => Get.back<String>(result: imageUrlList[index - 1]),
          );
        },
        itemCount: imageUrlList.length + 1,
      ),
    );
  }

  Future<void> _showImageBottomSheet(BuildContext context) async {
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
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop('photo'),
              child: Text(
                'choosePhoto'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
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
          color: Colors.white,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: Container(
                    height: 4,
                    width: 48,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: readrBlack20,
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop('camera'),
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    color: readrBlack87,
                    size: 18,
                  ),
                  label: Text(
                    'openCamera'.tr,
                    style: const TextStyle(
                      color: readrBlack87,
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
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: readrBlack87,
                    size: 18,
                  ),
                  label: Text(
                    'choosePhoto'.tr,
                    style: const TextStyle(
                      color: readrBlack87,
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
            aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'crop'.tr,
                toolbarColor: Colors.white,
                toolbarWidgetColor: readrBlack87,
                statusBarColor: readrBlack87,
                initAspectRatio: CropAspectRatioPreset.original,
                backgroundColor: Colors.white,
                activeControlsWidgetColor: Colors.blue,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'crop'.tr,
                aspectRatioLockEnabled: true,
                rotateButtonsHidden: true,
              ),
            ],
          );

          if (croppedFile != null) {
            Get.back<String>(result: croppedFile.path);
          }
        }
      }
    } catch (e) {
      print('Pick photo error: $e');
    }
  }
}
