import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/createCollectionController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/collection/createCollection/sortStoryPage.dart';

class DescriptionPage extends GetView<CreateCollectionController> {
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
        '敘述',
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
            String buttonText = '略過';
            if (controller.collectionDescription.isNotEmpty) {
              buttonText = '下一步';
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
                if (controller.collectionDescription.value.length < 3000) {
                  Get.to(() => SortStoryPage());
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
                textAlignVertical: TextAlignVertical.top,
                onChanged: (value) => controller.collectionDescription(value),
                style: const TextStyle(
                  color: readrBlack87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '輸入集錦敘述',
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
              return const Text(
                '字數不能超過 3000 字',
                style: TextStyle(
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
