import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/pages/readr/readrTabContent.dart';
import 'package:readr/services/categoryService.dart';
import 'package:readr/services/editorChoiceService.dart';

class ReadrPageController extends GetxController
    with GetTickerProviderStateMixin {
  final CategoryRepos categoryRepos;
  final EditorChoiceRepos editorChoiceRepo;
  ReadrPageController({
    required this.categoryRepos,
    required this.editorChoiceRepo,
  });

  bool isLoading = true;
  bool isError = false;
  final List<EditorChoiceItem> editorChoiceList = [];
  final List<Category> categoryList = [];
  dynamic error;

  late TabController tabController;
  bool _initializedTabController = false;
  final List<Tab> tabs = [];
  final List<Widget> tabWidgets = [];

  @override
  void onInit() {
    super.onInit();
    fetchCategoryAndEditorChoice();
  }

  @override
  void onClose() {
    if (_initializedTabController) tabController.dispose();
    super.onClose();
  }

  void fetchCategoryAndEditorChoice() async {
    isLoading = true;
    isError = false;
    update();
    await Get.find<UserService>().fetchUserData();
    try {
      await editorChoiceRepo
          .fetchNewsListItemList()
          .then((value) => editorChoiceList.assignAll(value));
    } catch (e) {
      print('Fetch READr editorChoice error: $e');
      editorChoiceList.clear();
    }

    try {
      categoryList.assignAll(await categoryRepos.fetchCategoryList());
      _initializeTabController();
    } catch (e) {
      print('Fetch READr category error: $e');
      isError = true;
      error = determineException(e);
    }
    isLoading = false;

    update();
  }

  _initializeTabController() {
    tabs.clear();
    tabWidgets.clear();

    for (int i = 0; i < categoryList.length; i++) {
      Category category = categoryList[i];
      tabs.add(
        Tab(
          child: Text(
            category.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );

      tabWidgets.add(
        ReadrTabContent(
          categorySlug: category.slug,
        ),
      );
    }

    // set controller
    tabController = TabController(
      vsync: this,
      length: categoryList.length,
    );
    _initializedTabController = true;
  }
}
