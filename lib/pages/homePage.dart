import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/config/bloc.dart';
import 'package:readr/blocs/config/events.dart';
import 'package:readr/blocs/config/states.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/updateMessages.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/home/homeWidget.dart';
import 'package:readr/pages/initLoadingPage.dart';
import 'package:upgrader/upgrader.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _loadingConfig();
    super.initState();
  }

  _loadingConfig() async {
    context.read<ConfigBloc>().add(LoadingConfig(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(
        builder: (BuildContext context, ConfigState state) {
      if (state is ConfigError) {
        final error = state.error;
        print('ConfigError: ${error.message}');
        return ErrorPage(error: error, onPressed: () => _loadingConfig());
      }
      if (state is ConfigLoaded) {
        return UpgradeAlert(
          minAppVersion: state.minAppVersion,
          messages: UpdateMessages(),
          dialogStyle: Platform.isAndroid
              ? UpgradeDialogStyle.material
              : UpgradeDialogStyle.cupertino,
          child: HomeWidget(),
          // Hide bottomNavigationBar due to only one page now
          // child: AutoTabsScaffold(
          //   routes: const [HomeRouter(), CategoryRouter()],
          //   bottomNavigationBuilder: (_, tabsRouter) {
          //     return BottomNavigationBar(
          //       elevation: 10,
          //       currentIndex: tabsRouter.activeIndex,
          //       onTap: tabsRouter.setActiveIndex,
          //       selectedItemColor: bottomNavigationBarSelectedColor,
          //       unselectedItemColor: bottomNavigationBarUnselectedColor,
          //       items: [
          //         BottomNavigationBarItem(
          //           activeIcon: SvgPicture.asset(
          //             homeIconSvg,
          //           ),
          //           icon: SvgPicture.asset(
          //             homeIconSvg,
          //             color: bottomNavigationBarUnselectedColor,
          //           ),
          //           label: '首頁',
          //         ),
          //         const BottomNavigationBarItem(
          //           icon: Icon(Icons.menu),
          //           label: '分類',
          //         ),
          //       ],
          //     );
          //   },
          // ),
        );
      }

      // state is Init, loading, or other
      return InitLoadingPage();
    });
  }
}
