import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:readr/blocs/tag/bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/openProjectHelper.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/storyListItem.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/models/tag.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/storyListSkeletonScreen.dart';

class TagWidget extends StatefulWidget {
  final Tag tag;
  const TagWidget(this.tag);

  @override
  _TagWidgetState createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  bool loadingMore = false;
  late StoryListItemList _tagStoryList;

  @override
  void initState() {
    _fetchStoryListByTagSlug();
    super.initState();
  }

  _fetchStoryListByTagSlug() {
    context
        .read<TagStoryListBloc>()
        .add(FetchStoryListByTagSlug(widget.tag.slug));
  }

  _fetchNextPageByTagSlug() async {
    context
        .read<TagStoryListBloc>()
        .add(FetchNextPageByTagSlug(widget.tag.slug));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagStoryListBloc, TagStoryListState>(
        builder: (BuildContext context, TagStoryListState state) {
      if (state.status == TagStoryListStatus.error) {
        final error = state.error;
        print('TagStoryListError: ${error.message}');
        if (loadingMore) {
          _fetchNextPageByTagSlug();
        } else {
          return ErrorPage(
            error: error,
            onPressed: () => _fetchStoryListByTagSlug(),
            hideAppbar: true,
          );
        }
      }

      if (state.status == TagStoryListStatus.loadingMore) {
        _tagStoryList = state.tagStoryList!;
        loadingMore = true;
        return _buildList(_tagStoryList);
      }

      if (state.status == TagStoryListStatus.loadingMoreFail) {
        _tagStoryList = state.tagStoryList!;
        loadingMore = true;
        _fetchNextPageByTagSlug();
        return _buildList(_tagStoryList);
      }

      if (state.status == TagStoryListStatus.loaded) {
        _tagStoryList = state.tagStoryList!;
        loadingMore = false;
        return _buildList(_tagStoryList);
      }
      // state is Init, loading, or other
      return StoryListSkeletonScreen();
    });
  }

  Widget _buildList(StoryListItemList tagStoryList) {
    bool isAll = false;
    if (tagStoryList.length == tagStoryList.allStoryCount) {
      isAll = true;
    }
    return ListView.builder(
      itemCount: tagStoryList.length + 1,
      padding: const EdgeInsets.only(top: 24),
      itemBuilder: (context, index) {
        if (index == tagStoryList.length) {
          if (isAll) {
            return Container(
              padding: const EdgeInsets.only(bottom: 24),
            );
          }
          _fetchNextPageByTagSlug();
          return Center(
            child: Platform.isAndroid
                ? const CircularProgressIndicator()
                : const CupertinoActivityIndicator(),
          );
        }
        Widget image;
        if (tagStoryList[index].photoUrl != null) {
          image = ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: CachedNetworkImage(
              imageUrl: tagStoryList[index].photoUrl!,
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
                      if (tagStoryList[index].isProject)
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
                          text: tagStoryList[index].name,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      _displayTimeAndReadingTime(tagStoryList[index]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap: () async {
            if (tagStoryList[index].isProject) {
              OpenProjectHelper().phaseByStoryListItem(tagStoryList[index]);
            } else {
              AutoRouter.of(context)
                  .push(StoryRoute(id: tagStoryList[index].id));
            }
          },
        );
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
