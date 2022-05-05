import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/blocs/followerList/followerList_cubit.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/followSkeletonScreen.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/memberListItemWidget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FollowerListWidget extends StatefulWidget {
  final Member viewMember;
  const FollowerListWidget({required this.viewMember});
  @override
  _FollowerListWidgetState createState() => _FollowerListWidgetState();
}

class _FollowerListWidgetState extends State<FollowerListWidget> {
  List<Member> _followerList = [];
  bool _isLoading = false;
  bool _isNoMore = false;

  @override
  void initState() {
    super.initState();
    _fetchFollowerList();
  }

  _fetchFollowerList() {
    context
        .read<FollowerListCubit>()
        .fetchFollowerList(viewMember: widget.viewMember);
  }

  _loadMore() {
    _isLoading = true;
    context.read<FollowerListCubit>().loadMore(
          viewMember: widget.viewMember,
          skip: _followerList.length,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowerListCubit, FollowerListState>(
      listener: (context, state) {
        if (state is FollowerListLoadMoreFailed) {
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
        if (state is FollowerListError) {
          final error = state.error;
          print('PickTabError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchFollowerList(),
            hideAppbar: true,
          );
        }

        if (state is FollowerListLoadingMore) {
          return _buildContent();
        }

        if (state is FollowerListLoadMoreSuccess) {
          if (state.followerList.length < 10) {
            _isNoMore = true;
          }
          _followerList.addAll(state.followerList);
          _followerList.sort((a, b) => a.customId.compareTo(b.customId));
          _isLoading = false;
          return _buildContent();
        }

        if (state is FollowerListLoaded) {
          if (state.followerList.isEmpty) {
            return _emptyWidget();
          } else {
            _followerList = state.followerList;
            if (_followerList.length < 10) {
              _isNoMore = true;
            }
            return _buildContent();
          }
        }

        return const FollowSkeletonScreen();
      },
    );
  }

  Widget _emptyWidget() {
    bool isMine = Get.find<UserService>().currentUser.memberId ==
        widget.viewMember.memberId;
    return Container(
      color: homeScreenBackgroundColor,
      child: Center(
        child: Text(
          isMine ? '目前還沒有粉絲' : '這個人還沒有粉絲',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: readrBlack30,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemBuilder: (context, index) {
        if (index == _followerList.length) {
          if (_isNoMore) {
            return Container();
          }

          return VisibilityDetector(
            key: const Key('followerList'),
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
            Get.to(() => PersonalFilePage(
                  viewMember: _followerList[index],
                ));
          },
          child: MemberListItemWidget(
            viewMember: _followerList[index],
          ),
        );
      },
      separatorBuilder: (context, index) {
        if (index == _followerList.length - 1) {
          return const SizedBox(
            height: 36,
          );
        }
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(
            color: readrBlack10,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: _followerList.length + 1,
    );
  }
}
