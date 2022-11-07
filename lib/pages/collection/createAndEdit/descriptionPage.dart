import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/addToCollectionPageController.dart';
import 'package:readr/controller/collection/createAndEdit/chooseStoryPageController.dart';
import 'package:readr/controller/collection/createAndEdit/descriptionPageController.dart';
import 'package:readr/helpers/themes.dart';
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Theme.of(context).extension<CustomColors>()?.primary700,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'narrative'.tr,
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
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Theme.of(context).extension<CustomColors>()?.blue,
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

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(() {
              Color focusBorderColor =
                  Theme.of(context).extension<CustomColors>()!.primary600!;
              Color borderColor =
                  Theme.of(context).extension<CustomColors>()!.primaryLv6!;
              if (controller.collectionDescription.value.length >= 3000) {
                focusBorderColor =
                    Theme.of(context).extension<CustomColors>()!.redText!;
                borderColor =
                    Theme.of(context).extension<CustomColors>()!.redText!;
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
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary700,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'collectionNarrativeHint'.tr,
                  hintStyle: TextStyle(
                    color:
                        Theme.of(context).extension<CustomColors>()?.primary400,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
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
                style: TextStyle(
                  color: Theme.of(context).extension<CustomColors>()?.redText,
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
