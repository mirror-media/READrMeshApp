import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/readr/categories/bloc.dart';
import 'package:readr/blocs/readr/categories/events.dart';
import 'package:readr/blocs/readr/categories/states.dart';
import 'package:readr/blocs/readr/editorChoice/editorChoice_cubit.dart';
import 'package:readr/blocs/readr/tabStoryList/bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/category.dart';
import 'package:readr/models/categoryList.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/readr/editorChoice/editorChoiceCarousel.dart';
import 'package:readr/pages/readr/readrSkeletonScreen.dart';
import 'package:readr/pages/readr/readrTabContent.dart';

import 'package:readr/services/tabStoryListService.dart';

class ReadrPage extends StatefulWidget {
  @override
  _ReadrPageState createState() => _ReadrPageState();
}

class _ReadrPageState extends State<ReadrPage> with TickerProviderStateMixin {
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
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );

      _tabWidgets.add(BlocProvider(
        create: (context) =>
            TabStoryListBloc(tabStoryListRepos: TabStoryListServices()),
        child: ReadrTabContent(
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
      if (state.status == CategoriesStatus.error) {
        final error = state.error;
        print('CategoriesError: ${error.message}');

        return ErrorPage(error: error, onPressed: () => _fetchCategoryList());
      }

      if (state.status == CategoriesStatus.loaded) {
        categoryList = state.categoryList!;
        _initializeTabController();

        return Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.white,
            toolbarHeight: 0,
            elevation: 0,
          ),
          body: Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: BlocProvider(
                        create: (context) => EditorChoiceCubit(),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: BuildEditorChoiceCarousel(),
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
                                bottom: BorderSide(
                                    color: Colors.black12, width: 1.0),
                              ),
                            ),
                          ),
                          TabBar(
                            isScrollable: true,
                            indicatorColor: tabBarSelectedColor,
                            unselectedLabelColor: Colors.black26,
                            tabs: _tabs.toList(),
                            controller: _tabController,
                            indicatorWeight: 1,
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: _tabWidgets.toList(),
                ),
              ),
            ),
          ),
        );
      }
      return ReadrSkeletonScreen();
    });
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0.5,
      title: const Text(
        'Logo',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.black,
          ),
        )
      ],
    );
  }
}
