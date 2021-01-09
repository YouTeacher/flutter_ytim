import 'package:flutter/foundation.dart';

class YTLog {
  static void d(String tag, Object content) {
    if (kDebugMode || kProfileMode) {
      print('$tag : $content');
    }
  }
}
