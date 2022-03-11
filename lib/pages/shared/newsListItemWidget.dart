import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';

class NewsListItemWidget extends StatelessWidget {
  final NewsListItem news;
  final bool hidePublisher;
  const NewsListItemWidget(this.news, {this.hidePublisher = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (news.source != null && !hidePublisher)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              news.source!.title,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                news.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (news.heroImageUrl != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  width: 96,
                  height: 96 / 2,
                  imageUrl: news.heroImageUrl!,
                  placeholder: (context, url) => Container(
                    color: Colors.grey,
                  ),
                  errorWidget: (context, url, error) => Container(),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<PickButtonCubit, PickButtonState>(
          builder: (context, state) => NewsInfo(
            news,
            commentCount: NewsListItemPick(news).commentCount,
          ),
        ),
        const SizedBox(height: 16),
        PickBar(
          NewsListItemPick(news),
        ),
      ],
    );
  }
}
