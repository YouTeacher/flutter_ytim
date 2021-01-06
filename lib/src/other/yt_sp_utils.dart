import 'dart:convert';

import 'package:flutter_ytim/src/bean/im_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YTSPUtils {
  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  YTSPUtils._internal();

  static SharedPreferences _spf;

  static Future<SharedPreferences> init() async {
    if (_spf == null) {
      _spf = await SharedPreferences.getInstance();
    }
    return _spf;
  }

  /// IM 保存与对方聊天的最后一条消息
  static Future<bool> saveLastMsg(String pk, IMMessage msg) {
    if (msg == null) {
      return _spf.remove('im_$pk');
    } else {
      return _spf.setString('im_$pk', msg?.toString());
    }
  }

  /// IM 读取与对方聊天的最后一条消息
  static IMMessage getLastMsg(String pk) {
    String s = _spf.getString('im_$pk');
    if (s == null) {
      return null;
    } else {
      return IMMessage.fromJson(json.decode(s));
    }
  }
}
