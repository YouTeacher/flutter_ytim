import 'package:flutter/foundation.dart';
import 'package:flutter_ytim/flutter_ytim.dart';

/// 日志输出方法封装
class YTLog {
  YTLog._();

  static void d(String tag, Object? content) {
    if ((kDebugMode || kProfileMode) && YTIM().logEnabled) {
      print('$tag : $content');
    }
  }

  static void i(Object? content) {
    if ((kDebugMode || kProfileMode) && YTIM().logEnabled) {
      print('$content');
    }
  }
}
