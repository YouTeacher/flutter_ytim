import 'dart:convert';

import 'package:flutter_ytim/src/bean/im_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 处理一些需要保存在本地的数据。
class YTSPUtils {
  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  YTSPUtils._internal();

  static SharedPreferences? _spf;

  static Future<SharedPreferences?> init() async {
    if (_spf == null) {
      _spf = await SharedPreferences.getInstance();
    }
    return _spf;
  }

  /// IM 保存与对方聊天的最后一条消息
  static Future<bool> saveLastMsg(String pk, IMMessage? msg) {
    if (msg == null) {
      return _spf!.remove('im_$pk');
    } else {
      return _spf!.setString('im_$pk', msg.toString());
    }
  }

  /// IM 读取与对方聊天的最后一条消息
  static IMMessage? getLastMsg(String? pk) {
    if (pk == null) {
      return null;
    }
    String? s = _spf!.getString('im_$pk');
    if (s == null) {
      return null;
    } else {
      return IMMessage.fromJson(json.decode(s));
    }
  }

  /// 将用户加入免打扰用户列表
  static Future<bool> insertMuteList(String id) async {
    List<String> list = getMuteList();
    if (list.contains(id)) {
      return true;
    } else {
      list.add(id);
      return _spf!.setString('im_mute_list', list.join(','));
    }
  }

  /// 将用户从免打扰列表中移除。
  static Future<bool> removeFromMuteList(String id) async {
    List<String> list = getMuteList();
    if (list.contains(id)) {
      list.remove(id);
      return _spf!.setString('im_mute_list', list.join(','));
    } else {
      return true;
    }
  }

  /// 获取免打扰用户列表
  static List<String> getMuteList() {
    List<String> ids = [];
    String? s = _spf!.getString('im_mute_list');
    if (s == null) {
      return ids;
    } else {
      return s.split(',');
    }
  }

  /// 获取黑名单
  static List<String> getBlockList() {
    List<String> ids = [];
    String? s = _spf!.getString('im_block_list');
    if (s == null) {
      return ids;
    } else {
      return s.split(',');
    }
  }

  /// 将用户加入黑名单
  static Future<bool> insertBlockList(String id) async {
    List<String> list = getBlockList();
    if (list.contains(id)) {
      return true;
    } else {
      list.add(id);
      return _spf!.setString('im_block_list', list.join(','));
    }
  }

  /// 将用户从黑名单中移除。
  static Future<bool> removeFromBlockList(String id) async {
    List<String> list = getBlockList();
    if (list.contains(id)) {
      list.remove(id);
      return _spf!.setString('im_block_list', list.join(','));
    } else {
      return true;
    }
  }
}
