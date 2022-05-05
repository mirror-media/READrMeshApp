import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/blocs/personalFileTab/personalFileTab_bloc.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/models/pick.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/newsListItemWidget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BookmarkTabContent extends StatefulWidget {
  const BookmarkTabContent();
  @override
  _BookmarkTabContentState createState() => _BookmarkTabContentState();
}

class _BookmarkTabContentState extends State<BookmarkTabContent> {
  List<Pick> _bookmarkList = [];
  bool _isNoMore = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBookmark();
  }

  _fetchBookmark() {
    context.read<PersonalFileTabBloc>().add(FetchTabContent(
          tabContentType: TabContentType.bookmark,
          viewMember: Get.find<UserService>().currentUser,
        ));
  }

  _loadMore() {
    _isLoading = true;
    context
        .read<PersonalFileTabBloc>()
        .add(LoadMore(lastPickTime: _bookmarkList.last.pickedDate));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalFileTabBloc, PersonalFileTabState>(
      listener: (context, state) {
        if (state is PersonalFileTabLoadMoreFailed ||
            state is PersonalFileTabReloadFailed) {
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
        if (state is PersonalFileTabError) {
          final error = state.error;
          print('PickTabError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchBookmark(),
            hideAppbar: true,
          );
        }

        if (state is PersonalFileTabLoadingMore) {
          return _buildContent();
        }

        if (state is PersonalFileTabLoadMoreSuccess) {
          if (state.data != null && state.data!.isNotEmpty) {
            _bookmarkList.addAll(state.data!);
            if (state.data!.length < 10) {
              _isNoMore = true;
            }
          }
          _isLoading = false;
          return _buildContent();
        }

        if (state is PersonalFileTabLoaded) {
          if (state.data != null && state.data!.isNotEmpty) {
            _bookmarkList = state.data!;
            if (_bookmarkList.length < 10) {
              _isNoMore = true;
            }
            return _buildContent();
          } else {
            return _emptyWidget();
          }
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _emptyWidget() {
    return Container(
      color: homeScreenBackgroundColor,
      child: const Center(
        child: Text(
          '你沒有已儲存的書籤',
          style: TextStyle(
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == _bookmarkList.length) {
          if (_isNoMore) {
            return Container();
          }

          return VisibilityDetector(
            key: const Key('bookmarkTab'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 50 && !_isLoading) _loadMore();
            },
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
        return NewsListItemWidget(
          _bookmarkList[index].story!,
        );
      },
      separatorBuilder: (context, index) {
        if (index == _bookmarkList.length - 1) {
          return const SizedBox(
            height: 36,
          );
        }
        return const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 20),
          child: Divider(
            color: readrBlack10,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: _bookmarkList.length + 1,
    );
  }
}
