import 'package:get/get.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/services/categoryService.dart';
import 'package:readr/services/editorChoiceService.dart';

class ReadrPageController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();
    fetchCategoryAndEditorChoice();
  }

  void fetchCategoryAndEditorChoice() async {
    isLoading = true;
    isError = false;
    update();
    try {
      editorChoiceList
          .assignAll(await editorChoiceRepo.fetchNewsListItemList());
    } catch (e) {
      print('Fetch READr editorChoice error: $e');
      editorChoiceList.clear();
    }

    try {
      categoryList.assignAll(await categoryRepos.fetchCategoryList());
    } catch (e) {
      print('Fetch READr category error: $e');
      isError = true;
      error = determineException(e);
    }
    isLoading = false;
    update();
  }
}
