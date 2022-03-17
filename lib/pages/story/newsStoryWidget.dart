import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/story/storyAppBar.dart';

class NewsStoryWidget extends StatefulWidget {
  final NewsListItem news;
  const NewsStoryWidget({
    required this.news,
  });

  @override
  _NewsStoryWidgetState createState() => _NewsStoryWidgetState();
}

class _NewsStoryWidgetState extends State<NewsStoryWidget> {
  late NewsStoryItem _newsStoryItem;
  String _inputText = '';
  bool _isPicked = false;
  bool _isSlideDown = false;
  final ScrollController _scrollController = ScrollController();
  double _oldOffset = 0;

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
    _scrollController.addListener(() {
      if (_scrollController.offset > _oldOffset) {
        setState(() {
          _isSlideDown = true;
        });
      } else {
        setState(() {
          _isSlideDown = false;
        });
      }
      _oldOffset = _scrollController.offset;
    });
  }

  _fetchNewsData() async {
    context.read<NewsCubit>().fetchNewsData(
          newsId: widget.news.id,
        );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsError) {
          final error = state.error;
          print('NewsPageError: ${error.message}');

          return Column(
            children: [
              StoryAppBar(
                newsStoryItem: null,
                inputText: _inputText,
                url: widget.news.url,
              ),
              Expanded(
                child: ErrorPage(
                  error: error,
                  onPressed: () => _fetchNewsData(),
                  hideAppbar: true,
                ),
              ),
            ],
          );
        }

        if (state is NewsLoaded) {
          _newsStoryItem = state.newsStoryItem;
          if (_newsStoryItem.myPickId != null) {
            _isPicked = true;
          }

          return SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    StoryAppBar(
                      newsStoryItem: _newsStoryItem,
                      inputText: _inputText,
                      url: widget.news.url,
                    ),
                    Expanded(
                      child: _buildContent(context),
                    ),
                  ],
                ),
                if (!_isSlideDown)
                  BottomCardWidget(
                    news: _newsStoryItem,
                    onTextChanged: (value) => _inputText = value,
                    isPicked: _isPicked,
                  ),
              ],
            ),
          );
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              StoryAppBar(
                newsStoryItem: null,
                inputText: _inputText,
                url: widget.news.url,
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      children: [
        _buildHeroWidget(),
        const SizedBox(height: 24),
        _buildPublisher(),
        const SizedBox(height: 4),
        _buildTitle(),
        const SizedBox(height: 12),
        _buildPublishDate(),
        const SizedBox(height: 4),
        _buildAuthor(),
        const SizedBox(height: 24),
        _buildStoryContent(),
        const SizedBox(height: 32),
        const SizedBox(height: 160),
      ],
      controller: _scrollController,
    );
  }

  Widget _buildHeroWidget() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 16 * 9;

    if (widget.news.heroImageUrl == null) {
      return Container();
    }

    return CachedNetworkImage(
      width: width,
      imageUrl: widget.news.heroImageUrl!,
      placeholder: (context, url) => Container(
        height: height,
        width: width,
        color: Colors.grey,
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width,
        color: Colors.grey,
        child: const Icon(Icons.error),
      ),
      fit: BoxFit.cover,
    );
  }

  Widget _buildPublisher() {
    if (widget.news.source == null) {
      return Container();
    }
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          widget.news.source!.title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _newsStoryItem.title,
        style: const TextStyle(
          color: readrBlack87,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPublishDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '更新時間：' +
            DateFormat('yyyy/MM/dd HH:mm').format(widget.news.publishedDate),
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildAuthor() {
    if (_newsStoryItem.writer == null || _newsStoryItem.writer!.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '記者：' + _newsStoryItem.writer!,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    return HtmlWidget(
      _newsStoryItem.content!,
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {
            'text-decoration-color': 'black',
            'color': 'black',
            'text-decoration-thickness': '100%',
          };
        } else if (element.localName == 'h1') {
          return {
            'line-height': '140%',
            'font-weight': '600',
            'font-size': '20px',
            'padding': '32px 20px 16px 20px',
          };
        } else if (element.localName == 'h2') {
          return {
            'line-height': '140%',
            'font-weight': '600',
            'font-size': '20px',
            'padding': '32px 20px 16px 20px',
          };
        } else if (element.localName == 'div') {
          return {
            'padding': '12px 0px 12px 0px',
          };
        }
        return {
          'padding': '0px 20px 0px 20px',
        };
      },
      textStyle: const TextStyle(
        fontSize: 18,
        height: 2,
        color: readrBlack87,
      ),
    );
  }
}
