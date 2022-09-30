import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/readr/readrPageController.dart';
import 'package:readr/helpers/themes.dart';
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
        toolbarHeight: 0,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
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
                          width: context.width,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        height: 8,
                      ),
                    ),
                    SliverAppBar(
                      pinned: true,
                      primary: false,
                      elevation: 0,
                      flexibleSpace: Stack(
                        fit: StackFit.passthrough,
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context)
                                      .extension<CustomColors>()!
                                      .primaryLv6!,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          TabBar(
                            isScrollable: true,
                            indicatorColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .primaryLv1!,
                            labelColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .primaryLv1!,
                            unselectedLabelColor: Theme.of(context)
                                .extension<CustomColors>()!
                                .primaryLv5!,
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
