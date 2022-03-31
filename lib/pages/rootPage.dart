import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readr/blocs/config/bloc.dart';
import 'package:readr/blocs/config/events.dart';
import 'package:readr/blocs/config/states.dart';
import 'package:readr/blocs/personalFile/personalFile_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/updateMessages.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:upgrader/upgrader.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
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
    return BlocConsumer<ConfigBloc, ConfigState>(
      listener: (context, state) {
        if (state is Onboarding) {
          AutoRouter.of(context).push(const WelcomeRoute());
        }
      },
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
            child: _buildBody(),
          );
        }

        if (state is LoginStateUpdate) {
          return _buildBody();
        }

        // state is Init, loading, or other
        return Container(
          color: const Color.fromRGBO(4, 13, 44, 1),
          child: Image.asset(
            splashIconPng,
            scale: 4,
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    Widget personalPageIcon;
    if (UserHelper.instance.isVisitor) {
      personalPageIcon = Image.asset(
        visitorAvatarPng,
      );
    } else {
      personalPageIcon =
          ProfilePhotoWidget(UserHelper.instance.currentUser, 11);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      body: AutoTabsScaffold(
        routes: [
          const HomeRouter(),
          const ReadrRouter(),
          PersonalFileWidgetRoute(
            viewMember: UserHelper.instance.currentUser,
            isFromBottomTab: true,
            isMine: true,
            isVisitor: UserHelper.instance.isVisitor,
          ),
        ],
        bottomNavigationBuilder: (_, tabsRouter) {
          return BottomNavigationBar(
            elevation: 10,
            backgroundColor: Colors.white,
            selectedFontSize: 12,
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              if (index == 2 && UserHelper.instance.isMember) {
                context
                    .read<PersonalFileCubit>()
                    .fetchMemberData(UserHelper.instance.currentUser);
              }
              tabsRouter.setActiveIndex(index);
            },
            selectedItemColor: bottomNavigationBarSelectedColor,
            unselectedItemColor: bottomNavigationBarUnselectedColor,
            items: [
              BottomNavigationBarItem(
                icon: SizedBox(
                  height: 20,
                  child: SvgPicture.asset(
                    homeDefaultSvg,
                  ),
                ),
                activeIcon: SizedBox(
                  height: 20,
                  child: SvgPicture.asset(
                    homeActiveSvg,
                  ),
                ),
                label: '首頁',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  height: 20,
                  margin: const EdgeInsets.only(bottom: 1.5),
                  child: SvgPicture.asset(
                    readrDefaultSvg,
                  ),
                ),
                activeIcon: Container(
                  height: 20,
                  margin: const EdgeInsets.only(bottom: 1.5),
                  child: SvgPicture.asset(
                    readrActiveSvg,
                  ),
                ),
                label: 'READr',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(
                  height: 20,
                  child: personalPageIcon,
                ),
                label: '個人檔案',
              ),
            ],
          );
        },
      ),
    );
  }
}
