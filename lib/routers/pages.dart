import 'package:get/get.dart';
import 'package:readr/pages/category_edit_page/category_edit_binding.dart';
import 'package:readr/pages/category_edit_page/category_edit_page.dart';
import 'package:readr/pages/rootPage.dart';

import 'routers.dart';

class Pages {
  static final pages = [
    GetPage(
        name: Routes.categoryEditPage,
        page: () => const CategoryEditPage(),
        binding: CategoryEditBinding()),
    GetPage(name: Routes.rootPage, page: () => RootPage()),
  ];
}
