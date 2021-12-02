import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:readr/blocs/author/bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/openProjectHelper.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/people.dart';
import 'package:readr/models/storyListItem.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/pages/author/authorSkeletonScreen.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/tabContentNoResultWidget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AuthorWidget extends StatefulWidget {
  final People people;
  const AuthorWidget(this.people);

  @override
  _AuthorWidgetState createState() => _AuthorWidgetState();
}

class _AuthorWidgetState extends State<AuthorWidget> {
  bool loadingMore = false;
  late StoryListItemList _authorStoryList;
  bool _isFollowed = false;
  bool _isShowed = true;

  @override
  void initState() {
    _fetchStoryListByAuthorSlug();
    super.initState();
  }

  @override
  void dispose() {
    VisibilityDetectorController.instance.forget(const Key('AuthorBlock'));
    super.dispose();
  }

  _fetchStoryListByAuthorSlug() {
    context
        .read<AuthorStoryListBloc>()
        .add(FetchStoryListByAuthorSlug(widget.people.slug));
  }

  _fetchNextPageByAuthorSlug() async {
    context
        .read<AuthorStoryListBloc>()
        .add(FetchNextPageByAuthorSlug(widget.people.slug));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorStoryListBloc, AuthorStoryListState>(
        builder: (BuildContext context, AuthorStoryListState state) {
      if (state.status == AuthorStoryListStatus.error) {
        final error = state.error;
        print('AuthorStoryListError: ${error.message}');
        if (loadingMore) {
          _fetchNextPageByAuthorSlug();
        } else {
          return ErrorPage(
            error: error,
            onPressed: () => _fetchNextPageByAuthorSlug(),
          );
        }
      }

      if (state.status == AuthorStoryListStatus.loadingMore) {
        _authorStoryList = state.authorStoryList!;
        loadingMore = true;
        return _buildBody();
      }

      if (state.status == AuthorStoryListStatus.loadingMoreFail) {
        _authorStoryList = state.authorStoryList!;
        loadingMore = true;
        _fetchNextPageByAuthorSlug();
        return _buildBody();
      }

      if (state.status == AuthorStoryListStatus.loaded) {
        _authorStoryList = state.authorStoryList!;
        loadingMore = false;
        return _buildBody();
      }
      // state is Init, loading, or other
      return AuthorSkeletonScreen();
    });
  }

  Widget _buildBody() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 246, 251, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: Platform.isIOS,
        title: _isShowed
            ? Container()
            : Text(
                widget.people.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight:
                      Platform.isIOS ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
        actions: [
          const SizedBox(
            width: 20,
          ),
          if (!_isShowed)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 11, 10),
              child: _followButton(),
            ),
        ],
      ),
      body: _buildList(_authorStoryList),
    );
  }

  Widget _followButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isFollowed = !_isFollowed;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color:
              _isFollowed ? const Color.fromRGBO(4, 41, 94, 1) : Colors.white,
          border: Border.all(
            width: 1,
            color:
                _isFollowed ? const Color.fromRGBO(4, 41, 94, 1) : Colors.black,
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: _isShowed ? 8 : 4,
          horizontal: _isShowed ? 16 : 12,
        ),
        child: Text(
          _isFollowed ? '取消追蹤' : '追蹤',
          style: TextStyle(
            fontSize: 16,
            color: _isFollowed ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _authorPhoto() {
    if (widget.people.photoUrl == null) {
      return Image.asset(
        authorDefaultPng,
        width: 78,
        height: 78,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(300.0),
      child: CachedNetworkImage(
        imageUrl: widget.people.photoUrl!,
        width: 78,
        height: 78,
        placeholder: (context, url) => Container(
          color: Colors.grey,
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey,
          child: const Icon(Icons.error),
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _authorBlock() {
    return VisibilityDetector(
      key: const Key('AuthorBlock'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage < 50) {
          setState(() {
            _isShowed = false;
          });
        } else {
          setState(() {
            _isShowed = true;
          });
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        margin: const EdgeInsets.only(bottom: 42),
        child: Row(
          children: [
            _authorPhoto(),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.people.name,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.people.bio != null)
                    Text(
                      widget.people.bio!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(0, 9, 40, 0.66),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            _followButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildList(StoryListItemList authorStoryList) {
    bool isAll = false;
    if (authorStoryList.length == authorStoryList.allStoryCount) {
      isAll = true;
    }
    if (authorStoryList.isEmpty) {
      return Column(
        children: [
          _authorBlock(),
          TabContentNoResultWidget(),
        ],
      );
    }
    return ListView.builder(
      itemCount: authorStoryList.length + 2,
      padding: const EdgeInsets.only(top: 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _authorBlock();
        }
        if (index == authorStoryList.length + 1) {
          if (isAll) {
            return Container(
              padding: const EdgeInsets.only(bottom: 24),
            );
          }
          if (!loadingMore) _fetchNextPageByAuthorSlug();
          return Center(
            child: Platform.isAndroid
                ? const CircularProgressIndicator()
                : const CupertinoActivityIndicator(),
          );
        }
        return _buildListItem(authorStoryList[index - 1]);
      },
    );
  }

  Widget _buildListItem(StoryListItem storyListItem) {
    Widget image;
    if (storyListItem.photoUrl != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: CachedNetworkImage(
          imageUrl: storyListItem.photoUrl!,
          placeholder: (context, url) => Container(
            color: Colors.grey,
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey,
            child: const Icon(Icons.error),
          ),
          fit: BoxFit.cover,
        ),
      );
    } else {
      double width = MediaQuery.of(context).size.width - 40;
      double height = width * 9 / 16;
      image = ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: SizedBox(
          width: width,
          height: height,
          child: SvgPicture.asset(defaultImageSvg, fit: BoxFit.cover),
        ),
      );
    }
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 12.0),
              child: Stack(
                children: [
                  image,
                  if (storyListItem.isProject)
                    Container(
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.only(
                        top: 8,
                        right: 8,
                      ),
                      child: _displayTag(),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        height: 1.5,
                      ),
                      text: storyListItem.name,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _displayTimeAndReadingTime(storyListItem),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        if (storyListItem.isProject) {
          OpenProjectHelper().phaseByStoryListItem(storyListItem);
        } else {
          AutoRouter.of(context).push(StoryRoute(id: storyListItem.id));
        }
      },
    );
  }

  Widget _displayTimeAndReadingTime(StoryListItem storyListItem) {
    TextStyle style = const TextStyle(
      fontSize: 12,
      color: Colors.black54,
    );
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(DateFormat('MM/dd').format(storyListItem.publishTime),
              style: style),
          if (storyListItem.readingTime != null &&
              storyListItem.readingTime! > 1.0)
            Text(
              '・閱讀時間 ${storyListItem.readingTime!.toString()} 分鐘',
              style: style,
            ),
        ],
      ),
    );
  }

  Widget _displayTag() {
    return Container(
      decoration: BoxDecoration(
        color: editorChoiceTagColor,
        borderRadius: BorderRadiusDirectional.circular(2),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: Text(
          '專題',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
