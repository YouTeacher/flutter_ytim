import 'package:flutter_ytim/src/bean/im_store.dart';
import 'package:flutter_ytim/src/bean/im_unread_count.dart';
import 'package:flutter_ytim/src/ytim.dart';

/// 通用工具类
class YTUtils {
  /// 将时间戳转换为本地格式化时间：1586182731897 -> 2020-04-07 11:35
  static String millisecondsToString(String milliseconds) {
    if (milliseconds == null || milliseconds == '') {
      return '';
    }
    String dateOriginal =
        DateTime.fromMillisecondsSinceEpoch(int.parse(milliseconds))
            .toLocal()
            .toString();
    var today = DateTime.now();
    var standardDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
    //传入的日期与今天的23:59:59秒进行比较
    Duration diff = standardDate.difference(DateTime.parse(dateOriginal));
    if (diff < Duration(days: 1)) {
      return dateOriginal.substring(11, 16);
    } else {
      if (diff >= Duration(days: 1) &&
          today.year.toString() == dateOriginal.substring(0, 4)) {
        return dateOriginal.substring(5, 10);
      } else {
        // 2019.01.23
        return dateOriginal.substring(0, 10);
      }
    }
  }

  static void updateUnreadCount(Map<String, IMLastInfo> map) {
    List<IMLastInfo> values = map.values.toList();
    int count = 0;
    if (values.isNotEmpty) {
      values.forEach((element) {
        count += element.unreadCount;
      });
    }
    YTIM().streamController.sink.add(IMUnreadCount(count: count));
  }
}
