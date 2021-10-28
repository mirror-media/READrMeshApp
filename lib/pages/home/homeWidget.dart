import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/categories/bloc.dart';
import 'package:readr/blocs/categories/events.dart';
import 'package:readr/blocs/categories/states.dart';
import 'package:readr/blocs/editorChoice/bloc.dart';
import 'package:readr/blocs/tabStoryList/bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/pages/home/homeTabContent.dart';
import 'package:readr/pages/shared/editorChoice/editorChoiceCarousel.dart';
import 'package:readr/services/editorChoiceService.dart';
import 'package:readr/services/tabStoryListService.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  late CategoryList categoryList;
  final int _initialTabIndex = 0;
  TabController? _tabController;
  final List<Tab> _tabs = List.empty(growable: true);
  final List<Widget> _tabWidgets = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _fetchCategoryList();
  }

  _fetchCategoryList() async {
    context.read<CategoriesBloc>().add(FetchCategories());
  }

  _initializeTabController() {
    _tabs.clear();
    _tabWidgets.clear();

    for (int i = 0; i < categoryList.length; i++) {
      Category category = categoryList[i];
      _tabs.add(
        Tab(
          child: Text(
            category.name,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      );

      _tabWidgets.add(BlocProvider(
        create: (context) =>
            TabStoryListBloc(tabStoryListRepos: TabStoryListServices()),
        child: HomeTabContent(
          categorySlug: category.slug,
        ),
      ));
    }

    // set controller
    _tabController = TabController(
      vsync: this,
      length: categoryList.length,
      initialIndex:
          _tabController == null ? _initialTabIndex : _tabController!.index,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (BuildContext context, CategoriesState state) {
      if (state.status == CategoriesStatus.initial ||
          state.status == CategoriesStatus.loading) {
        return const Center(child: CupertinoActivityIndicator());
      }

      if (state.status == CategoriesStatus.error) {
        final error = state.error;
        print('TabStoryListError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(
              onPressed: () {
                _fetchCategoryList();
              },
              isColumn: true);
        }
        return error.renderWidget(isNoButton: true, isColumn: true);
      }

      if (state.status == CategoriesStatus.loaded) {
        categoryList = state.categoryList!;
        _initializeTabController();
      }
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.light,
                  child: BlocProvider(
                    create: (context) => EditorChoiceBloc(
                      editorChoiceRepos: EditorChoiceServices(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: BuildEditorChoiceCarousel(),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 4,
                ),
              ),
              SliverAppBar(
                pinned: true,
                primary: false,
                elevation: 0,
                toolbarHeight: 25,
                backgroundColor: Colors.white,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                bottom: TabBar(
                  isScrollable: true,
                  indicatorColor: tabBarSelectedColor,
                  unselectedLabelColor: Colors.black38,
                  tabs: _tabs.toList(),
                  controller: _tabController,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _tabWidgets.toList(),
          ),
        ),
      );
    });
  }
}
