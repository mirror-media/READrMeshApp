import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/timelineCollectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/collectionStoryItem.dart';
import 'package:readr/pages/shared/news/newsListItemWidget.dart';

class TimelineItemWidget extends StatelessWidget {
  final TimelineCollectionPick timelineStory;
  final TimelineCollectionPick? previousTimelineStory;
  final bool editMode;
  const TimelineItemWidget(
    this.timelineStory, {
    Key? key,
    this.previousTimelineStory,
    this.editMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: _buildTimestamp(),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              border: Border.all(
                color: readrBlack10,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: editMode
                ? CollectionStoryItem(
                    timelineStory.news,
                    inTimeline: true,
                  )
                : NewsListItemWidget(
                    timelineStory.news,
                    key: Key(timelineStory.news.id),
                    inTimeline: true,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp() {
    List<Widget> children = [
      const SizedBox(
        height: 16,
      )
    ];

    switch (_compareTwoStory()) {
      case 4:
        break;
      case 3:
        if (timelineStory.time != null) {
          children.add(Text(
            DateFormat('HH:mm').format(timelineStory.time!),
            style: const TextStyle(
              fontSize: 12,
              color: readrBlack50,
            ),
          ));
        }
        break;
      case 2:
        if (timelineStory.time != null) {
          children.addAll([
            Text(
              '${timelineStory.month!}/${timelineStory.day!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              DateFormat('HH:mm').format(timelineStory.time!),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
          ]);
        } else if (timelineStory.day != null) {
          children.add(
            Text(
              '${timelineStory.month!}/${timelineStory.day!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        } else if (!editMode) {
          children.add(
            Text(
              '${timelineStory.month!}月',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        break;
      case 1:
        if (timelineStory.time != null) {
          children.addAll([
            Text(
              '${timelineStory.month!}/${timelineStory.day!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              DateFormat('HH:mm').format(timelineStory.time!),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
          ]);
        } else if (timelineStory.day != null) {
          children.add(
            Text(
              '${timelineStory.month!}/${timelineStory.day!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        } else if (timelineStory.month != null) {
          children.add(
            Text(
              '${timelineStory.month!}月',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        } else {
          children.add(
            Text(
              timelineStory.year.toString(),
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        break;

      case 0:
        if (timelineStory.time != null) {
          children.addAll([
            Text(
              timelineStory.year.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              '${timelineStory.month!}/${timelineStory.day!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              DateFormat('HH:mm').format(timelineStory.time!),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
          ]);
        } else if (timelineStory.day != null) {
          children.addAll([
            Text(
              timelineStory.year.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              '${timelineStory.month!}/${timelineStory.day!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]);
        } else if (timelineStory.month != null) {
          children.addAll([
            Text(
              timelineStory.year.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              '${timelineStory.month!}月',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]);
        } else {
          children.add(
            Text(
              timelineStory.year.toString(),
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
    }

    if (editMode) {
      if (children.length > 1) {
        children.add(const SizedBox(
          height: 12,
        ));
      }
      children.add(const Text(
        '編輯',
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue,
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  int _compareTwoStory() {
    // return 0 if they are all different or previousTimelineStory is null
    // return 1 if their year are same
    // return 2 if their year and month are same
    // return 3 if their year, month, and day are same
    // return 4 if they are all same

    if (previousTimelineStory != null) {
      if (previousTimelineStory!.year != timelineStory.year) {
        return 0;
      }

      if (previousTimelineStory!.month != timelineStory.month ||
          timelineStory.month == null) {
        return 1;
      }

      if (previousTimelineStory!.day != timelineStory.day ||
          timelineStory.day == null) {
        return 2;
      }

      if (previousTimelineStory!.time != timelineStory.time ||
          timelineStory.time == null) {
        return 3;
      } else {
        return 4;
      }
    }
    return 0;
  }
}
