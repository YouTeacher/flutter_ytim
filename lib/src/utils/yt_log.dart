import 'package:flutter/foundation.dart';

/// 日志输出方法封装
class YTLog {
  YTLog._();
  static bool logEnabled = true;

  static void d(String tag, Object content) {
    if ((kDebugMode || kProfileMode) && logEnabled) {
      print('$tag : $content');
    }
  }

  static void i(Object content) {
    if ((kDebugMode || kProfileMode) && logEnabled) {
      print('$content');
    }
  }
}
