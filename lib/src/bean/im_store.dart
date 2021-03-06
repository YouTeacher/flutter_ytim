import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/bean/im_msg.dart';

/// 全局IM信息
class IMLastInfo {
  IMMessage? msg;
  int unreadCount;

  IMLastInfo({this.msg, this.unreadCount = 0});
}

/// 全局IM信息，支持刷新
class IMStore with ChangeNotifier {
  Map<String?, IMLastInfo> _lastInfos;

  IMStore(this._lastInfos);

  Map<String?, IMLastInfo> get lastInfos => this._lastInfos;

  void update(Map<String?, IMLastInfo> map) {
    _lastInfos = map;
    notifyListeners();
  }
}
