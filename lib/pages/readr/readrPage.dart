import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:readr/controller/readr/readrPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/readr/editorChoice/editorChoiceCarousel.dart';
import 'package:readr/pages/shared/mainAppBar.dart';
import 'package:readr/pages/shared/homeSkeletonScreen.dart';
import 'package:readr/services/categoryService.dart';
import 'package:readr/services/editorChoiceService.dart';

class ReadrPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<ReadrPageController>(
          init: ReadrPageController(
            categoryRepos: CategoryServices(),
            editorChoiceRepo: EditorChoiceService(),
          ),
          builder: (controller) {
            if (controller.isError) {
              final error = controller.error;

              return ErrorPage(
                  error: error,
                  onPressed: () => controller.fetchCategoryAndEditorChoice());
            }

            if (!controller.isLoading) {
              return ExtendedNestedScrollView(
                onlyOneScrollInBody: true,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    MainAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: EditorChoiceCarousel(
                          editorChoiceList: controller.editorChoiceList,
                          width: Get.width,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: const Color.fromRGBO(246, 246, 251, 1),
                        height: 8,
                      ),
                    ),
                    SliverAppBar(
                      pinned: true,
                      primary: false,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      flexibleSpace: Stack(
                        fit: StackFit.passthrough,
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(color: readrBlack10, width: 1.0),
                              ),
                            ),
                          ),
                          TabBar(
                            isScrollable: true,
                            indicatorColor: tabBarSelectedColor,
                            labelColor: readrBlack87,
                            unselectedLabelColor: readrBlack20,
                            tabs: controller.tabs.toList(),
                            controller: controller.tabController,
                            indicatorWeight: 1,
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: controller.tabController,
                  children: controller.tabWidgets.toList(),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                MainAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: HomeSkeletonScreen(),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
