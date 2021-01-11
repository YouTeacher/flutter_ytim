import 'package:flutter/foundation.dart';

/// 日志输出方法封装
class YTLog {
  static void d(String tag, Object content) {
    if (kDebugMode || kProfileMode) {
      print('$tag : $content');
    }
  }
}
