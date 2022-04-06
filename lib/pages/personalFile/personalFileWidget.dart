import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/blocs/comment/comment_bloc.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/blocs/personalFile/personalFile_cubit.dart';
import 'package:readr/blocs/personalFileTab/personalFileTab_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/bookmarkTabContent.dart';
import 'package:readr/pages/personalFile/personalFileSkeletonScreen.dart';
import 'package:readr/pages/personalFile/pickTabContent.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:readr/services/commentService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validated/validated.dart' as validate;

class PersonalFileWidget extends StatefulWidget {
  final Member viewMember;
  final bool isMine;
  final bool isVisitor;
  final bool isFromBottomTab;
  const PersonalFileWidget({
    required this.viewMember,
    required this.isMine,
    required this.isVisitor,
    required this.isFromBottomTab,
  });

  @override
  _PersonalFileWidgetState createState() => _PersonalFileWidgetState();
}

class _PersonalFileWidgetState extends State<PersonalFileWidget>
    with TickerProviderStateMixin {
  late Member _viewMember;
  int _pickCount = 0;
  int _followerCount = 0;
  int _originFollowerCount = 0;
  int _followingCount = 0;
  late TabController _tabController;
  final List<Tab> _tabs = List.empty(growable: true);
  final List<Widget> _tabWidgets = List.empty(growable: true);
  bool _tabIsInitialized = false;
  late bool _isFollowed;

  @override
  void initState() {
    super.initState();
    if (!widget.isMine) {
      _fetchMemberData();
    } else if (!widget.isFromBottomTab && !widget.isVisitor) {
      _fetchMemberData();
    }
  }

  @override
  void dispose() {
    if (_tabIsInitialized) {
      _tabController.dispose();
    }
    super.dispose();
  }

  _fetchMemberData() async {
    context.read<PersonalFileCubit>().fetchMemberData(widget.viewMember);
  }

  _refetchMemberData() async {
    context
        .read<PersonalFileCubit>()
        .fetchMemberData(widget.viewMember, isReload: true);
  }

  _initializeTabController() {
    _tabs.clear();
    _tabWidgets.clear();

    _tabs.add(
      const Tab(
        child: Text(
          '精選',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );

    _tabWidgets.add(MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              PersonalFileTabBloc(personalFileRepos: PersonalFileService()),
        ),
        BlocProvider(
          create: (context) => CommentBloc(
            pickButtonCubit: BlocProvider.of<PickButtonCubit>(context),
            commentRepos: CommentService(),
          ),
        ),
      ],
      child: PickTabContent(
        viewMember: widget.viewMember,
      ),
    ));

    // if (!widget.isMine || _pickCount != 0 || _viewMember.bookmarkCount != 0) {
    //   _tabs.add(
    //     const Tab(
    //       child: Text(
    //         '集錦',
    //         style: TextStyle(
    //           fontSize: 16,
    //         ),
    //       ),
    //     ),
    //   );

    //   _tabWidgets.add(BlocProvider(
    //     create: (context) => PersonalFileTabBloc(),
    //     child: CollectionTabContent(
    //       viewMember: widget.viewMember,
    //       isMine: widget.isMine,
    //     ),
    //   ));
    // }

    if (widget.isMine) {
      _tabs.add(
        const Tab(
          child: Text(
            '書籤',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );

      _tabWidgets.add(BlocProvider(
        create: (context) =>
            PersonalFileTabBloc(personalFileRepos: PersonalFileService()),
        child: const BookmarkTabContent(),
      ));
    }

    // set controller
    _tabController = TabController(
      vsync: this,
      length: _tabs.length,
    );
    _tabIsInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVisitor && widget.isFromBottomTab) {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: _visitorContent(),
            ),
          ],
        ),
      );
    }
    return BlocBuilder<PersonalFileCubit, PersonalFileState>(
      builder: (context, state) {
        if (state is PersonalFileError) {
          final error = state.error;
          print('PersonalFileError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchMemberData(),
            hideAppbar: true,
          );
        }

        if (state is PersonalFileLoaded) {
          _viewMember = state.viewMember;
          _isFollowed = UserHelper.instance.isLocalFollowingMember(_viewMember);
          if (_viewMember.pickCount != null) {
            _pickCount = _viewMember.pickCount!;
          }

          if (_viewMember.followerCount != null) {
            _followerCount = _viewMember.followerCount!;
            _originFollowerCount = _followerCount;
          }

          if (_viewMember.followingCount != null) {
            _followingCount = _viewMember.followingCount!;
          }

          if (_viewMember.followingPublisherCount != null) {
            _followingCount =
                _followingCount + _viewMember.followingPublisherCount!;
          }

          _initializeTabController();
          return _buildContent(context);
        }

        if (state is PersonalFileReloading) {
          return _buildContent(context);
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              _appBar(),
              const Expanded(
                child: PersonalFileSkeletonScreen(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _appBar() {
    return AppBar(
      elevation: 0,
      leading: widget.isFromBottomTab
          ? _settingButton()
          : IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: readrBlack87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
      title: Text(
        widget.isVisitor && widget.isFromBottomTab
            ? '個人檔案'
            : widget.viewMember.customId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: readrBlack87,
        ),
      ),
      centerTitle: Platform.isIOS,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            _buildBar(),
            SliverToBoxAdapter(
              child: _memberDataWidget(),
            ),
            const SliverToBoxAdapter(
              child: Divider(
                color: readrBlack10,
                thickness: 0.5,
                height: 0.5,
              ),
            ),
            SliverAppBar(
              pinned: true,
              primary: false,
              elevation: 0,
              toolbarHeight: 8,
              backgroundColor: Colors.white,
              bottom: TabBar(
                indicatorColor: tabBarSelectedColor,
                labelColor: readrBlack87,
                unselectedLabelColor: readrBlack30,
                indicatorWeight: 0.5,
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
  }

  Widget _settingButton() {
    return IconButton(
      icon: const Icon(
        Icons.settings,
        color: readrBlack,
      ),
      onPressed: () async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String version = packageInfo.version;
        String buildNumber = packageInfo.buildNumber;
        final prefs = await SharedPreferences.getInstance();
        String loginType = prefs.getString('loginType') ?? '';
        AutoRouter.of(context).push(SettingRoute(
          version: 'v$version ($buildNumber)',
          loginType: loginType,
        ));
      },
    );
  }

  Widget _buildBar() {
    Widget leading;
    if (widget.isFromBottomTab) {
      leading = _settingButton();
    } else {
      leading = IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: readrBlack87,
        ),
        onPressed: () => Navigator.pop(context),
      );
    }
    return SliverAppBar(
      pinned: true,
      primary: true,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: Platform.isIOS,
      leading: leading,
      title: Text(
        _viewMember.customId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: readrBlack,
        ),
      ),
      // actions: widget.isMine && !widget.isVisitor && _pickCount != 0
      //     ? [
      //         IconButton(
      //           icon: const Icon(
      //             Icons.add_sharp,
      //             color: readrBlack87,
      //           ),
      //           onPressed: () {},
      //         )
      //       ]
      //     : null,
    );
  }

  Widget _visitorContent() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 24),
          child: Text(
            '建立帳號，客製化追蹤更多優質新聞',
            style: TextStyle(
              color: readrBlack87,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            onPressed: () {
              AutoRouter.of(context).push(LoginRoute());
            },
            child: const Text(
              '立即建立',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: readrBlack87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _memberDataWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 32),
      child: Column(
        children: [
          ProfilePhotoWidget(
            _viewMember,
            40,
            textSize: 40,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ExtendedText(
                  _viewMember.nickname,
                  maxLines: 1,
                  joinZeroWidthSpace: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: readrBlack87,
                  ),
                ),
              ),
              if (_viewMember.verified)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.verified,
                    size: 16,
                    color: readrBlack87,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (_viewMember.intro != null && _viewMember.intro!.isNotEmpty)
            _buildIntro(_viewMember.intro!),
          const SizedBox(height: 12),
          if (!widget.isMine)
            FollowButton(
              MemberFollowableItem(_viewMember),
              expanded: true,
              textSize: 16,
            ),
          if (widget.isMine) _editProfileButton(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      text: _convertNumberToString(_pickCount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: readrBlack87,
                      ),
                      children: const [
                        TextSpan(
                          text: '\n精選',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: readrBlack50,
                          ),
                        )
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 20,
                child: const VerticalDivider(
                  color: readrBlack10,
                  thickness: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AutoRouter.of(context).push(FollowerListRoute(
                    viewMember: widget.viewMember,
                  ));
                },
                child: BlocBuilder<FollowButtonCubit, FollowButtonState>(
                  builder: (context, state) {
                    _updateFollowerCount();
                    return RichText(
                      text: TextSpan(
                        text: _convertNumberToString(_followerCount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: readrBlack87,
                        ),
                        children: [
                          const TextSpan(
                            text: '\n粉絲 ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: readrBlack50,
                            ),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: SvgPicture.asset(
                              personalFileArrowSvg,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 20,
                child: const VerticalDivider(
                  color: readrBlack10,
                  thickness: 0.5,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      AutoRouter.of(context).push(FollowingListRoute(
                        viewMember: widget.viewMember,
                      ));
                    },
                    child: BlocBuilder<FollowButtonCubit, FollowButtonState>(
                      builder: (context, state) {
                        _updateFollowingCount();
                        return RichText(
                          text: TextSpan(
                            text: _convertNumberToString(_followingCount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: readrBlack87,
                            ),
                            children: [
                              const TextSpan(
                                text: '\n追蹤中 ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: readrBlack50,
                                ),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: SvgPicture.asset(
                                  personalFileArrowSvg,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  String _convertNumberToString(int number) {
    if (number >= 10000) {
      double newNumber = number / 10000;
      return newNumber.toStringAsFixed(
              newNumber.truncateToDouble() == newNumber ? 0 : 1) +
          '萬';
    } else {
      return number.toString();
    }
  }

  Widget _buildIntro(String intro) {
    List<String> introChar = intro.characters.toList();
    return RichText(
      text: TextSpan(
        text: introChar[0],
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: validate.isEmoji(introChar[0]) ? readrBlack : readrBlack50,
        ),
        children: [
          for (int i = 1; i < introChar.length; i++)
            TextSpan(
              text: introChar[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color:
                    validate.isEmoji(introChar[i]) ? readrBlack : readrBlack50,
              ),
            )
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  void _updateFollowerCount() {
    if (_isFollowed &&
        !UserHelper.instance.isLocalFollowingMember(_viewMember)) {
      _followerCount = _originFollowerCount - 1;
    } else if (!_isFollowed &&
        UserHelper.instance.isLocalFollowingMember(_viewMember)) {
      _followerCount = _originFollowerCount + 1;
    } else {
      _followerCount = _originFollowerCount;
    }
  }

  void _updateFollowingCount() {
    if (widget.isMine) {
      _followingCount = UserHelper.instance.localFollowingMemberList.length +
          UserHelper.instance.localPublisherList.length;
    }
  }

  Widget _editProfileButton() {
    return OutlinedButton(
      onPressed: () async {
        final needReload =
            await context.pushRoute(const EditPersonalFileRoute());

        if (needReload is bool && needReload) {
          _refetchMemberData();
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: readrBlack87, width: 1),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
      child: const Text(
        '編輯個人檔案',
        softWrap: true,
        maxLines: 1,
        style: TextStyle(
          fontSize: 16,
          color: readrBlack87,
        ),
      ),
    );
  }
}
