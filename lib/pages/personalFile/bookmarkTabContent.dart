import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/personalFileTab/personalFileTab_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/models/pick.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/latestNewsItem.dart';
import 'package:readr/helpers/router/router.dart';

class BookmarkTabContent extends StatefulWidget {
  final Member currentMember;
  const BookmarkTabContent(this.currentMember);
  @override
  _BookmarkTabContentState createState() => _BookmarkTabContentState();
}

class _BookmarkTabContentState extends State<BookmarkTabContent> {
  List<Pick> _bookmarkList = [];
  bool _isNoMore = false;

  @override
  void initState() {
    super.initState();
    _fetchBookmark();
  }

  _fetchBookmark() {
    context.read<PersonalFileTabBloc>().add(FetchTabContent(
          viewMember: widget.currentMember,
          currentMember: widget.currentMember,
          tabContentType: TabContentType.bookmark,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalFileTabBloc, PersonalFileTabState>(
      listener: (context, state) {
        if (state is PersonalFileTabLoadingMoreFailed ||
            state is PersonalFileTabReloadFailed) {
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
          child: CircularProgressIndicator(),
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
            color: Colors.black26,
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return InkWell(
          onTap: () {
            AutoRouter.of(context).push(NewsStoryRoute(
              news: _bookmarkList[index].story!,
              member: widget.currentMember,
            ));
          },
          child: LatestNewsItem(
            _bookmarkList[index].story!,
            widget.currentMember,
          ),
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
            color: Colors.black12,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: _bookmarkList.length + 1,
    );
  }
}
