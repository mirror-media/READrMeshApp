import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (timelineStory.summary != null)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Text(
              timelineStory.summary!,
              style: TextStyle(
                fontWeight:
                    GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                fontSize: 18,
                color: readrBlack87,
              ),
            ),
          ),
        Flexible(
          child: IntrinsicHeight(
            child: Row(
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
                      borderRadius:
                          const BorderRadius.all(Radius.circular(6.0)),
                      border: Border.all(
                        color: readrBlack10,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp() {
    List<Widget> children = [];

    switch (_compareTwoStory()) {
      case 4:
        break;
      case 3:
        if (timelineStory.customTime != null) {
          children.add(Text(
            DateFormat('HH:mm').format(timelineStory.customTime!),
            style: const TextStyle(
              fontSize: 12,
              color: readrBlack50,
            ),
          ));
        } else {
          children.add(
            Text(
              '${timelineStory.customMonth!}/${timelineStory.customDay!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        break;
      case 2:
        if (timelineStory.customTime != null) {
          children.addAll([
            Text(
              '${timelineStory.customMonth!}/${timelineStory.customDay!}',
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
              DateFormat('HH:mm').format(timelineStory.customTime!),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
          ]);
        } else if (timelineStory.customDay != null) {
          children.add(
            Text(
              '${timelineStory.customMonth!}/${timelineStory.customDay!}',
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
              '${timelineStory.customMonth!}月',
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
        if (timelineStory.customTime != null) {
          children.addAll([
            Text(
              '${timelineStory.customMonth!}/${timelineStory.customDay!}',
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
              DateFormat('HH:mm').format(timelineStory.customTime!),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
          ]);
        } else if (timelineStory.customDay != null) {
          children.add(
            Text(
              '${timelineStory.customMonth!}/${timelineStory.customDay!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        } else if (timelineStory.customMonth != null) {
          children.add(
            Text(
              '${timelineStory.customMonth!}月',
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
              timelineStory.customYear.toString(),
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
        if (timelineStory.customTime != null) {
          children.addAll([
            Text(
              timelineStory.customYear.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              '${timelineStory.customMonth!}/${timelineStory.customDay!}',
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
              DateFormat('HH:mm').format(timelineStory.customTime!),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
          ]);
        } else if (timelineStory.customDay != null) {
          children.addAll([
            Text(
              timelineStory.customYear.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              '${timelineStory.customMonth!}/${timelineStory.customDay!}',
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]);
        } else if (timelineStory.customMonth != null) {
          children.addAll([
            Text(
              timelineStory.customYear.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              '${timelineStory.customMonth!}月',
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
              timelineStory.customYear.toString(),
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
      children.insert(0, const SizedBox(height: 16));
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
    } else {
      if (children.isNotEmpty) {
        children.insert(0, const SizedBox(height: 16));
        if (_checkIsCustomTime()) {
          children.addAll([
            const SizedBox(
              height: 8,
            ),
            _customTimeTag(),
          ]);
        }
        children.add(const SizedBox(
          height: 16,
        ));
      } else if (_checkIsCustomTime()) {
        children.addAll([
          const SizedBox(
            height: 16,
          ),
          _customTimeTag(),
          const SizedBox(
            height: 16,
          ),
        ]);
      }

      children.add(
        const Expanded(
          child: VerticalDivider(
            color: readrBlack10,
            thickness: 1,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  int _compareTwoStory() {
    // return 0 if they are all different or previousTimelineStory is null
    // return 1 if their customYear are same
    // return 2 if their customYear and customMonth are same
    // return 3 if their customYear, customMonth, and customDay are same
    // return 4 if they are all same

    if (previousTimelineStory != null) {
      if (previousTimelineStory!.customYear == timelineStory.customYear &&
          previousTimelineStory!.customMonth == timelineStory.customMonth &&
          previousTimelineStory!.customDay == timelineStory.customDay &&
          previousTimelineStory!.customTime == timelineStory.customTime &&
          timelineStory.summary == null) {
        return 4;
      }

      if (previousTimelineStory!.customYear != timelineStory.customYear) {
        return 0;
      }

      if (previousTimelineStory!.customMonth != timelineStory.customMonth ||
          timelineStory.customMonth == null) {
        return 1;
      }

      if (previousTimelineStory!.customDay != timelineStory.customDay ||
          timelineStory.customDay == null) {
        return 2;
      }

      if (previousTimelineStory!.customTime != timelineStory.customTime ||
          timelineStory.customTime == null ||
          timelineStory.summary != null) {
        return 3;
      } else {
        return 4;
      }
    }
    return 0;
  }

  bool _checkIsCustomTime() {
    if (timelineStory.customTime != null) {
      return true;
    }

    if (timelineStory.customDay != null &&
        timelineStory.customDay != timelineStory.news.publishedDate.day) {
      return true;
    }

    if (timelineStory.customMonth != null &&
        timelineStory.customMonth != timelineStory.news.publishedDate.month) {
      return true;
    }

    if (timelineStory.customYear != timelineStory.news.publishedDate.year) {
      return true;
    }

    return false;
  }

  Widget _customTimeTag() {
    return Container(
      decoration: const BoxDecoration(
        color: readrBlack10,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      padding: const EdgeInsets.all(4),
      child: const Text(
        '自訂',
        style: TextStyle(
          fontSize: 11,
          color: readrBlack30,
        ),
      ),
    );
  }
}
