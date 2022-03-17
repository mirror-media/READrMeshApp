import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/followingList/followingList_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/memberListItemWidget.dart';
import 'package:readr/pages/shared/publisherListItemWidget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FollowingListWidget extends StatefulWidget {
  final Member viewMember;
  const FollowingListWidget({required this.viewMember});
  @override
  _FollowingListWidgetState createState() => _FollowingListWidgetState();
}

class _FollowingListWidgetState extends State<FollowingListWidget> {
  List<Member> _followingMemberList = [];
  List<Publisher> _followPublisherList = [];
  bool _isLoading = false;
  bool _isNoMore = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchFollowerList();
  }

  _fetchFollowerList() {
    context
        .read<FollowingListCubit>()
        .fetchFollowingList(viewMember: widget.viewMember);
  }

  _loadMore() {
    _isLoading = true;
    context.read<FollowingListCubit>().loadMore(
          viewMember: widget.viewMember,
          skip: _followingMemberList.length,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowingListCubit, FollowingListState>(
      listener: (context, state) {
        if (state is FollowingListLoadMoreFailed) {
          _isLoading = false;
          Fluttertoast.showToast(
            msg: "載入失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
      builder: (context, state) {
        if (state is FollowingListError) {
          final error = state.error;
          print('PickTabError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchFollowerList(),
            hideAppbar: true,
          );
        }

        if (state is FollowingListLoadingMore) {
          return _buildContent();
        }

        if (state is FollowingListLoadMoreSuccess) {
          if (state.followingMemberList.length < 10) {
            _isNoMore = true;
          }
          _followingMemberList.addAll(state.followingMemberList);
          _followingMemberList.sort((a, b) => a.customId.compareTo(b.customId));
          _isLoading = false;
          return _buildContent();
        }

        if (state is FollowingListLoaded) {
          if (state.followingMemberList.isEmpty &&
              state.followPublisherList.isEmpty) {
            return _emptyWidget();
          } else {
            _followPublisherList = state.followPublisherList;
            _followingMemberList = state.followingMemberList;
            if (_followingMemberList.length < 10) {
              _isNoMore = true;
            }
            return _buildContent();
          }
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _emptyWidget() {
    bool isMine =
        UserHelper.instance.currentUser.memberId == widget.viewMember.memberId;
    return Container(
      color: homeScreenBackgroundColor,
      child: Center(
        child: Text(
          isMine ? '目前沒有追蹤中的對象' : '這個人目前沒有追蹤中的對象',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black26,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        if (_followPublisherList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '媒體  (${_followPublisherList.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          color: readrBlack87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.expand_less_outlined
                          : Icons.expand_more_outlined,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded)
            SliverToBoxAdapter(
              child: _buildPublisherList(),
            ),
        ],
        if (_followingMemberList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Text(
                '人物  (${_followingMemberList.length})',
                style: const TextStyle(
                  fontSize: 18,
                  color: readrBlack87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: _buildFollowingMemberList(),
          ),
        ]
      ],
    );
  }

  Widget _buildPublisherList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == _followPublisherList.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Divider(
              color: Colors.black12,
              thickness: 1,
              height: 1,
            ),
          );
        }
        return InkWell(
          onTap: () {
            AutoRouter.of(context).push(PublisherRoute(
              publisher: _followPublisherList[index],
            ));
          },
          child: PublisherListItemWidget(
            publisher: _followPublisherList[index],
          ),
        );
      },
      separatorBuilder: (context, index) {
        if (index == _followPublisherList.length - 1) {
          return Container();
        }
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(
            color: Colors.black12,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: _followPublisherList.length + 1,
    );
  }

  Widget _buildFollowingMemberList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == _followingMemberList.length) {
          if (_isNoMore) {
            return Container();
          }

          return VisibilityDetector(
            key: const Key('followingList'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 50 && !_isLoading) _loadMore();
            },
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
        return InkWell(
          onTap: () {
            AutoRouter.of(context).push(PersonalFileRoute(
              viewMember: _followingMemberList[index],
            ));
          },
          child: MemberListItemWidget(
            viewMember: _followingMemberList[index],
          ),
        );
      },
      separatorBuilder: (context, index) {
        if (index == _followingMemberList.length - 1) {
          return const SizedBox(
            height: 36,
          );
        }
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(
            color: Colors.black12,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: _followingMemberList.length + 1,
    );
  }
}
