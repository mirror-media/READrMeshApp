import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/addToCollectionPageController.dart';
import 'package:readr/controller/collection/createAndEdit/chooseStoryPageController.dart';
import 'package:readr/controller/collection/createAndEdit/descriptionPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/chooseFormatPage.dart';
import 'package:readr/services/collectionService.dart';

class DescriptionPage extends GetView<DescriptionPageController> {
  final String? description;
  final Collection? collection;
  final bool isEdit;
  const DescriptionPage({
    this.description,
    this.collection,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(DescriptionPageController(
      CollectionService(),
      description: description,
      collection: collection,
    ));
    return Obx(
      () {
        if (controller.isUpdating.isTrue) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitWanderingCubes(
                  color: readrBlack,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'updatingCollection'.tr,
                    style: const TextStyle(
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
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: readrBlack87,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'narrative'.tr,
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
            String buttonText = isEdit ? 'save'.tr : 'skip'.tr;
            if (controller.collectionDescription.isNotEmpty && !isEdit) {
              buttonText = 'nextStep'.tr;
            } else if (controller.collectionDescription.value == description &&
                isEdit) {
              return Container();
            }
            return TextButton(
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                if (isEdit) {
                  controller.updateDescription();
                } else {
                  List<CollectionPick> chooseStoryList = [];
                  if (Get.isRegistered<AddToCollectionPageController>()) {
                    chooseStoryList.add(CollectionPick.fromNewsListItem(
                        Get.find<AddToCollectionPageController>().news));
                  } else {
                    chooseStoryList =
                        Get.find<ChooseStoryPageController>().selectedList;
                  }
                  Get.to(
                    () => ChooseFormatPage(
                      chooseStoryList,
                      isQuickCreate:
                          Get.isRegistered<AddToCollectionPageController>(),
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(() {
              Color focusBorderColor = readrBlack66;
              Color borderColor = readrBlack10;
              if (controller.collectionDescription.value.length >= 3000) {
                focusBorderColor = Colors.red;
                borderColor = Colors.red;
              }
              return TextFormField(
                keyboardType: TextInputType.multiline,
                autofocus: true,
                maxLines: null,
                maxLength: 3000,
                expands: true,
                initialValue: description,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (value) => controller.collectionDescription(value),
                style: const TextStyle(
                  color: readrBlack87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'collectionNarrativeHint'.tr,
                  hintStyle: const TextStyle(
                    color: readrBlack30,
                    fontSize: 16,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(
                      color: focusBorderColor,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  counterText: '',
                ),
              );
            }),
          ),
          const SizedBox(
            height: 8,
          ),
          Obx(() {
            if (controller.collectionDescription.value.length >= 3000) {
              return Text(
                'collectionNarrativeLengthAlert'.tr,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              );
            }

            return Container();
          }),
        ],
      ),
    );
  }
}
