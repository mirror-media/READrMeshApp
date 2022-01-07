import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/pages/errorPage.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();
    _fetchHomeList();
  }

  _fetchHomeList() async {
    context.read<HomeBloc>().add(FetchHomeStoryList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeError) {
          final error = state.error;
          print('HomePageError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchHomeList(),
            hideAppbar: true,
          );
        }

        if (state is HomeLoaded) {
          return _buildHomeList(state.newsList);
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildHomeList(List<NewsListItem> newsList) {
    return ListView.builder(
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        return _homeListItem(newsList[index]);
      },
    );
  }

  Widget _homeListItem(NewsListItem newsListItem) {
    double width = MediaQuery.of(context).size.width - 10;
    double imageHeight = width / (16 / 9);
    return Card(
      elevation: 5,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: [
          CachedNetworkImage(
            width: width,
            height: imageHeight,
            imageUrl: newsListItem.heroImageUrl,
            placeholder: (context, url) => Container(
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey,
              child: const Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          if (newsListItem.source != null) Text(newsListItem.source!.title),
          Text(newsListItem.title),
          if (newsListItem.summary != null) Text(newsListItem.summary!),
        ],
      ),
    );
  }
}
