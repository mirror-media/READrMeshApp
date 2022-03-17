import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/followButton/followButton_cubit.dart';
import 'package:readr/blocs/publisher/publisher_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:readr/pages/shared/newsListItemWidget.dart';
import 'package:readr/pages/shared/publisherLogoWidget.dart';

class PublisherWidget extends StatefulWidget {
  final Publisher publisher;
  const PublisherWidget(this.publisher);
  @override
  _PublisherWidgetState createState() => _PublisherWidgetState();
}

class _PublisherWidgetState extends State<PublisherWidget> {
  final List<NewsListItem> _publisherNewsList = [];
  bool _isLoading = false;
  bool _isNoMore = false;
  int _originFollowerCount = 0;
  int _publisherCount = 0;
  bool _isFollowed = false;

  @override
  void initState() {
    super.initState();
    _fetchPublisherNews();
    _isFollowed =
        UserHelper.instance.isLocalFollowingPublisher(widget.publisher);
  }

  _fetchPublisherNews() {
    context.read<PublisherCubit>().fetchPublisherNews(widget.publisher.id);
  }

  _fetchMorePublisherNews() {
    _isLoading = true;
    context.read<PublisherCubit>().fetchMorePublisherNews(
        widget.publisher.id, _publisherNewsList.last.publishedDate);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublisherCubit, PublisherState>(
      listener: (context, state) {
        if (state is PublisherLoadMoreFailed) {
          Fluttertoast.showToast(
            msg: "載入失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          _fetchMorePublisherNews();
        }
      },
      builder: (context, state) {
        if (state is PublisherError) {
          final error = state.error;
          print('PublisherPageError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchPublisherNews(),
            hideAppbar: true,
          );
        }

        if (state is PublisherLoadingMore) {
          return _buildContent(context);
        }

        if (state is PublisherLoadMoreFailed) {
          _isLoading = false;
          return _buildContent(context);
        }

        if (state is PublisherLoaded) {
          _isLoading = false;
          _publisherNewsList.addAll(state.publisherNewsList);
          _originFollowerCount = state.publisherFollowerCount;
          if (state.publisherNewsList.length < 20) {
            _isNoMore = true;
          }
          return _buildContent(context);
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Colors.black12,
                width: 0.5,
              ),
            ),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 64),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PublisherLogoWidget(widget.publisher, size: 72),
              const SizedBox(
                width: 41.5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocBuilder<FollowButtonCubit, FollowButtonState>(
                    builder: (context, state) {
                      _updateFollowCount();
                      return RichText(
                          text: TextSpan(
                        text: _convertNumberToString(
                          _publisherCount,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: readrBlack87,
                        ),
                        children: const [
                          TextSpan(
                            text: ' 人追蹤',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: readrBlack50,
                            ),
                          )
                        ],
                      ));
                    },
                  ),
                  const SizedBox(height: 8),
                  FollowButton(
                    PublisherFollowableItem(widget.publisher),
                    textSize: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _latestNewsList(context, _publisherNewsList),
        ),
      ],
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

  void _updateFollowCount() {
    if (_isFollowed &&
        !UserHelper.instance.isLocalFollowingPublisher(widget.publisher)) {
      _publisherCount = _originFollowerCount - 1;
    } else if (!_isFollowed &&
        UserHelper.instance.isLocalFollowingPublisher(widget.publisher)) {
      _publisherCount = _originFollowerCount + 1;
    } else {
      _publisherCount = _originFollowerCount;
    }
  }

  Widget _latestNewsList(BuildContext context, List<NewsListItem> newsList) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      itemBuilder: (context, index) {
        if (index == newsList.length) {
          if (_isNoMore) {
            return Container();
          }
          if (!_isLoading) {
            _fetchMorePublisherNews();
          }
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
        return NewsListItemWidget(
          newsList[index],
        );
      },
      separatorBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 20),
          child: Divider(
            color: Colors.black12,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: newsList.length + 1,
    );
  }
}
