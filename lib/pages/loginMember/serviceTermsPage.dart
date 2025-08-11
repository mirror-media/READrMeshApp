import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/controller/login/serviceTermsController.dart';

class ServiceTermsPage extends GetView<ServiceTermsController> {
  const ServiceTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ServiceTermsController(), permanent: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '服務條款',
          style: TextStyle(
            color: Theme.of(context).extension<CustomColors>()?.primary700,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).extension<CustomColors>()?.primary700,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '繼續使用前，請先詳閱我們的服務條款及隱私權政策',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildTermsContent(context),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(() => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '請滑動到最後再勾選',
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<CustomColors>()
                                ?.primary500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.rxCanAgree.value
                            ? () {
                                controller.toggleAgreed();
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: controller.rxAgreed.value,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              side: !controller.rxAgreed.value
                                  ? BorderSide(
                                      color: controller.rxCanAgree.value
                                          ? Theme.of(context)
                                                  .extension<CustomColors>()
                                                  ?.primary400 ??
                                              Colors.grey
                                          : Theme.of(context)
                                                  .extension<CustomColors>()
                                                  ?.primary300 ??
                                              Colors.grey[400]!,
                                      width: 1.5,
                                    )
                                  : null,
                              onChanged: controller.rxCanAgree.value
                                  ? (bool? value) {
                                      controller.rxAgreed.value =
                                          value ?? false;
                                    }
                                  : null,
                              activeColor: controller.rxCanAgree.value
                                  ? Theme.of(context)
                                      .extension<CustomColors>()
                                      ?.primary700
                                  : Theme.of(context)
                                      .extension<CustomColors>()
                                      ?.primary300,
                            ),
                            Text(
                              '我同意以上條款',
                              style: TextStyle(
                                color: controller.rxCanAgree.value
                                    ? Theme.of(context)
                                        .extension<CustomColors>()
                                        ?.primary700
                                    : Theme.of(context)
                                        .extension<CustomColors>()
                                        ?.primary400,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Obx(() => ElevatedButton(
                    onPressed: controller.rxAgreed.value
                        ? () {
                            controller.handleNextStep();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.rxAgreed.value
                          ? Theme.of(context)
                              .extension<CustomColors>()
                              ?.primary700
                          : Theme.of(context)
                              .extension<CustomColors>()
                              ?.primary200,
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: Text(
                      '下一步',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: controller.rxAgreed.value
                            ? Theme.of(context).colorScheme.background
                            : Theme.of(context)
                                .extension<CustomColors>()
                                ?.primary400,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsContent(BuildContext context) {
    return Obx(() {
      if (controller.rxIsLoading.value) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }
      if (controller.rxnError.value != null) {
        return Center(child: Text(controller.rxnError.value!));
      }
      if (controller.rxnTermsContent.value != null) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).extension<CustomColors>()?.primary200 ??
                  Colors.grey,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Scrollbar(
            controller: controller.scrollController,
            child: SingleChildScrollView(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                child: HtmlWidget(
                  controller.rxnTermsContent.value!,
                ),
              ),
            ),
          ),
        );
      }
      return const Center(child: Text('無法載入服務條款內容。'));
    });
  }
}
