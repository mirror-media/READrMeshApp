import 'package:get/get.dart';
import 'package:readr/models/timelineStory.dart';
import 'package:readr/services/collectionService.dart';

enum TimeDimension { yearAndDate, onlyMonth, onlyYear }

class TimeDimensionPageController extends GetxController {
  final CollectionRepos collectionRepos;
  final List<TimelineStory> timelineStory;
  TimeDimensionPageController(this.collectionRepos, this.timelineStory);

  final isUpdating = false.obs;
  bool hasChange = false;
  bool editItemTime = false;
  final timeDimension = TimeDimension.yearAndDate.obs;
  final timelineStoryList = <TimelineStory>[].obs;

  //for CustomTimePage
  final year = 1900.obs;
  final month = RxnInt();
  final day = RxnInt();
  final time = Rxn<DateTime>();

  @override
  void onInit() {
    timelineStoryList.assignAll(timelineStory);
    ever<int>(year, (callback) {
      if (month.value != null && day.value != null) {
        if (day.value! > DateTime(callback, month.value! + 1, 0).day) {
          day.value = null;
          time.value = null;
        }
      }
    });
    ever<int?>(
      month,
      (callback) {
        if (callback != null && day.value != null) {
          if (day.value! > DateTime(year.value, callback + 1, 0).day) {
            day.value = null;
            time.value = null;
          }
        }
      },
    );
    ever<int?>(
      day,
      (callback) {
        if (callback == null) {
          time.value = null;
        }
      },
    );
    super.onInit();
  }

  void updateTimeDimension(TimeDimension timeDimension) {
    for (var element in timelineStoryList) {
      switch (timeDimension) {
        case TimeDimension.yearAndDate:
          element.month = element.news.publishedDate.month;
          element.day = element.news.publishedDate.day;
          element.time = null;
          break;
        case TimeDimension.onlyMonth:
          element.month = element.news.publishedDate.month;
          element.day = null;
          element.time = null;
          break;
        case TimeDimension.onlyYear:
          element.month = null;
          element.day = null;
          element.time = null;
          break;
      }
    }
    this.timeDimension.value = timeDimension;
    timelineStoryList.refresh();
  }

  void sortListByTime() {
    timelineStoryList.sort((a, b) {
      // compare year
      int result = b.year.compareTo(a.year);
      if (result != 0) {
        return result;
      }

      //compare month
      if (a.month == null && b.month == null) {
        return b.news.publishedDate.compareTo(a.news.publishedDate);
      } else if (a.month == null) {
        return 1;
      } else if (b.month == null) {
        return -1;
      } else {
        result = b.month!.compareTo(a.month!);
        if (result != 0) {
          return result;
        }
      }

      // compare day
      if (a.day == null && b.day == null) {
        return b.news.publishedDate.compareTo(a.news.publishedDate);
      } else if (a.day == null) {
        return 1;
      } else if (b.day == null) {
        return -1;
      } else {
        result = b.day!.compareTo(a.day!);
        if (result != 0) {
          return result;
        }
      }

      // compare time
      if (a.time == null && b.time == null) {
        return b.news.publishedDate.compareTo(a.news.publishedDate);
      } else if (a.time == null) {
        return 1;
      } else if (b.time == null) {
        return -1;
      } else {
        result = b.time!.compareTo(a.time!);
        if (result != 0) {
          return result;
        } else {
          return b.news.publishedDate.compareTo(a.news.publishedDate);
        }
      }
    });
  }
}
