import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/personalFile/personalFile_cubit.dart';
import 'package:readr/blocs/personalFileTab/personalFileTab_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/bookmarkTabContent.dart';
import 'package:readr/pages/personalFile/collectionTabContent.dart';
import 'package:readr/pages/personalFile/pickTabContent.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

class PersonalFileWidget extends StatefulWidget {
  final Member viewMember;
  final bool isMine;
  final bool isVisitor;
  final Member currentMember;
  final bool isFromBottomTab;
  const PersonalFileWidget({
    required this.viewMember,
    required this.isMine,
    required this.isVisitor,
    required this.currentMember,
    required this.isFromBottomTab,
  });

  @override
  _PersonalFileWidgetState createState() => _PersonalFileWidgetState();
}

class _PersonalFileWidgetState extends State<PersonalFileWidget>
    with TickerProviderStateMixin {
  late Member _viewMember;
  late Member _currentMember;
  bool _isFollowed = false;
  int _pickCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  late TabController _tabController;
  final List<Tab> _tabs = List.empty(growable: true);
  final List<Widget> _tabWidgets = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if (!widget.isVisitor || !widget.isFromBottomTab) {
      _fetchMemberData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _fetchMemberData() async {
    context
        .read<PersonalFileCubit>()
        .fetchMemberData(widget.viewMember, widget.currentMember);
  }

  _refetchMemberData() async {
    context.read<PersonalFileCubit>().fetchMemberData(
        widget.viewMember, widget.currentMember,
        isReload: true);
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

    _tabWidgets.add(BlocProvider(
      create: (context) => PersonalFileTabBloc(),
      child: PickTabContent(
        viewMember: widget.viewMember,
        currentMember: widget.currentMember,
      ),
    ));

    if (!widget.isMine || _pickCount != 0 || _viewMember.bookmarkCount != 0) {
      _tabs.add(
        const Tab(
          child: Text(
            '集錦',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );

      _tabWidgets.add(BlocProvider(
        create: (context) => PersonalFileTabBloc(),
        child: CollectionTabContent(
          viewMember: widget.viewMember,
          currentMember: widget.currentMember,
          isMine: widget.isMine,
        ),
      ));
    }

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
        create: (context) => PersonalFileTabBloc(),
        child: BookmarkTabContent(
          widget.currentMember,
        ),
      ));
    }

    // set controller
    _tabController = TabController(
      vsync: this,
      length: _tabs.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVisitor && widget.isFromBottomTab) {
      return _visitorContent();
    }
    return BlocBuilder<PersonalFileCubit, PersonalFileState>(
      builder: (context, state) {
        if (state is PersonalFileError) {
          final error = state.error;
          print('HomePageError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchMemberData(),
            hideAppbar: true,
          );
        }

        if (state is PersonalFileLoaded) {
          _viewMember = state.viewMember;
          _currentMember = state.currentMember;
          if (_viewMember.pickCount != null) {
            _pickCount = _viewMember.pickCount!;
          }

          if (_viewMember.followerCount != null) {
            _followerCount = _viewMember.followerCount!;
          }

          if (_viewMember.followingCount != null) {
            _followingCount = _viewMember.followingCount!;
          }

          _initializeTabController();
          return RefreshIndicator(
            child: _buildContent(context),
            onRefresh: () => _refetchMemberData(),
            notificationPredicate: (scrollNotification) {
              if (scrollNotification.depth == 2) {
                return true;
              }
              return false;
            },
          );
        }

        if (state is PersonalFileReloading) {
          return _buildContent(context);
        }

        return Column(
          children: [
            AppBar(
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.viewMember.customId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
            ),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return ExtendedNestedScrollView(
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
              color: Colors.black12,
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
              unselectedLabelColor: Colors.black26,
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
    );
  }

  Widget _buildBar() {
    Widget leading;
    if (widget.isFromBottomTab) {
      leading = IconButton(
        icon: const Icon(
          Icons.settings,
          color: Colors.black,
        ),
        onPressed: () {
          AutoRouter.of(context).push(const MemberCenterRoute());
        },
      );
    } else {
      leading = IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      );
    }
    return SliverAppBar(
      pinned: true,
      primary: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: leading,
      title: Text(
        widget.viewMember.customId,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      actions: widget.isMine && !widget.isVisitor && _pickCount != 0
          ? [
              IconButton(
                icon: const Icon(
                  Icons.add_sharp,
                  color: Colors.black,
                ),
                onPressed: () {},
              )
            ]
          : null,
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
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            onPressed: () async {},
            child: const Text(
              '立即建立',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.black87,
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
              Text(
                _viewMember.nickname,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (_viewMember.verified)
                const Icon(
                  Icons.verified,
                  size: 12,
                  color: Colors.black87,
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (_viewMember.intro != null)
            Text(
              _viewMember.intro!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 12),
          if (!widget.isMine) _followButton(),
          if (widget.isMine) _editProfileButton(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: _convertNumberToString(_pickCount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  children: const [
                    TextSpan(
                      text: '\n精選',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 20,
                child: const VerticalDivider(
                  color: Colors.black12,
                  thickness: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: RichText(
                  text: TextSpan(
                    text: _convertNumberToString(_followerCount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    children: const [
                      TextSpan(
                        text: '\n粉絲',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      WidgetSpan(
                        child: Icon(
                          Icons.navigate_next_outlined,
                          size: 18,
                          color: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 20,
                child: const VerticalDivider(
                  color: Colors.black12,
                  thickness: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: RichText(
                  text: TextSpan(
                    text: _convertNumberToString(_followingCount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    children: const [
                      TextSpan(
                        text: '\n追蹤中',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      WidgetSpan(
                        child: Icon(
                          Icons.navigate_next_outlined,
                          size: 18,
                          color: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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

  Widget _followButton() {
    if (_currentMember.following != null) {
      int index = _currentMember.following!
          .indexWhere((member) => member.memberId == _viewMember.memberId);
      if (index != -1) {
        _isFollowed = true;
      }
    }
    return OutlinedButton(
      onPressed: () async {
        bool originFollowState = _isFollowed;
        setState(() {
          _isFollowed = !_isFollowed;
        });
        List<Member>? newFollowingList;
        // check whether is login
        if (FirebaseAuth.instance.currentUser != null) {
          final MemberService _memberService = MemberService();

          if (originFollowState) {
            newFollowingList = await _memberService.addFollowingMember(
                _currentMember.memberId, _viewMember.memberId);
          } else {
            newFollowingList = await _memberService.removeFollowingMember(
                _currentMember.memberId, _viewMember.memberId);
          }
        } else {
          final VisitorService _visitorService = VisitorService();

          if (originFollowState) {
            newFollowingList =
                await _visitorService.addFollowingMember(_viewMember.memberId);
          } else {
            newFollowingList = await _visitorService
                .removeFollowingMember(_viewMember.memberId);
          }
        }
        if (newFollowingList == null) {
          setState(() {
            _isFollowed = !_isFollowed;
          });
        } else {
          _currentMember.following = newFollowingList;
        }
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1),
        backgroundColor: _isFollowed ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: const Size.fromHeight(48),
      ),
      child: Text(
        _isFollowed ? '追蹤中' : '追蹤',
        maxLines: 1,
        style: TextStyle(
          fontSize: 16,
          color: _isFollowed ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _editProfileButton() {
    return OutlinedButton(
      onPressed: () async {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
      child: const Text(
        '編輯個人檔案',
        softWrap: true,
        maxLines: 1,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
