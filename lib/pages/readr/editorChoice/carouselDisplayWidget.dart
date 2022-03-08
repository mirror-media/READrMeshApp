import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/openProjectHelper.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickButton.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';

class CarouselDisplayWidget extends StatefulWidget {
  final EditorChoiceItem editorChoiceItem;
  final StoryPick storyPick;
  final double width;
  const CarouselDisplayWidget({
    required this.editorChoiceItem,
    required this.width,
    required this.storyPick,
  });

  @override
  _CarouselDisplayWidgetState createState() => _CarouselDisplayWidgetState();
}

class _CarouselDisplayWidgetState extends State<CarouselDisplayWidget> {
  final double aspectRatio = 16 / 9;
  bool _isPicked = false;
  List<Member> _pickedMembers = [];
  int _pickCount = 0;
  late NewsListItem _news;

  @override
  void initState() {
    super.initState();
    _news = widget.editorChoiceItem.newsListItem!;
    if (widget.storyPick.myPickId != null) {
      _isPicked = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _pickCount = _news.pickCount;
    return InkWell(
      highlightColor: Colors.grey[100],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _displayTitle(),
            const SizedBox(height: 8),
            NewsInfo(_news),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildBottom(),
            )
          ],
        ),
      ),
      onTap: () async {},
    );
  }

  Widget _displayTitle() {
    return Container(
      color: editorChoiceBackgroundColor,
      child: Text(
        _news.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildBottom() {
    _pickedMembers = [];
    if (_isPicked) {
      _pickedMembers.add(UserHelper.instance.currentUser);
    }
    _pickedMembers.addAll(_news.followingPickMembers);
    _pickedMembers.addAll(_news.otherPickMembers);
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
    return bottom;
  }

  Widget _pickButton() {
    return PickButton(
      widget.storyPick,
      afterPicked: () {
        setState(() {
          _isPicked = true;
          _pickCount++;
          widget.editorChoiceItem.newsListItem!.pickCount++;
        });
      },
      afterRemovePick: () {
        setState(() {
          _isPicked = false;
          _pickCount--;
          widget.editorChoiceItem.newsListItem!.pickCount--;
        });
      },
      whenPickFailed: () {
        setState(() {
          _isPicked = false;
          _pickCount--;
          widget.editorChoiceItem.newsListItem!.pickCount--;
        });
      },
      whenRemoveFailed: () {
        setState(() {
          _isPicked = true;
          _pickCount++;
          widget.editorChoiceItem.newsListItem!.pickCount++;
        });
      },
    );
  }
}
