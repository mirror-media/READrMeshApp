import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/home/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';

class LatestNewsItem extends StatefulWidget {
  final NewsListItem news;
  const LatestNewsItem(this.news);
  @override
  _LatestNewsItemState createState() => _LatestNewsItemState();
}

class _LatestNewsItemState extends State<LatestNewsItem> {
  bool _isPicked = false;
  List<Member> _pickedMembers = [];
  int _pickCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.news.myPickId != null) {
      _isPicked = true;
    }
    _pickCount = widget.news.pickCount;
  }

  @override
  Widget build(BuildContext context) {
    _pickedMembers = [];
    if (_isPicked) {
      _pickedMembers.add(UserHelper.instance.currentUser);
    }
    _pickedMembers.addAll(widget.news.followingPickMembers);
    _pickedMembers.addAll(widget.news.otherPickMembers);
    List<Widget> bottom = [];
    if (_pickCount == 0) {
      bottom = [
        const Text(
          '尚無人精選',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Expanded(
          child: Container(),
        ),
        _pickButton(),
      ];
    } else {
      bottom = [
        ProfilePhotoStack(_pickedMembers, 14),
        const SizedBox(width: 8),
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: _pickCount.toString(),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: ' 人精選',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Container(),
        ),
        _pickButton(),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.news.source != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.news.source!.title,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                widget.news.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.news.heroImageUrl != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  width: 96,
                  height: 96 / 2,
                  imageUrl: widget.news.heroImageUrl!,
                  placeholder: (context, url) => Container(
                    color: Colors.grey,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        NewsInfo(widget.news),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: bottom,
        )
      ],
    );
  }

  Widget _pickButton() {
    return PickButton(
      StoryPick(widget.news.id, widget.news.myPickId),
      afterPicked: () {
        setState(() {
          _isPicked = true;
          _pickCount++;
        });
      },
      afterRemovePick: () {
        setState(() {
          _isPicked = false;
          _pickCount--;
        });
      },
      whenPickFailed: () {
        setState(() {
          _isPicked = false;
          _pickCount--;
        });
      },
      whenRemoveFailed: () {
        setState(() {
          _isPicked = true;
          _pickCount++;
        });
      },
    );
  }
}
