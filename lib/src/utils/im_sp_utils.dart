import 'dart:convert';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_group_message.dart';
import 'package:flutter_ytim/src/model/im_message.dart';
import 'package:flutter_ytim/src/model/im_store_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IMSPUtils {
  IMSPUtils._internal();

  static SharedPreferences? _spf;

  static Future<SharedPreferences?> init() async {
    _spf ??= await SharedPreferences.getInstance();
    return _spf;
  }

  /// IM 保存与对方聊天的最后一条消息
  static Future<bool> saveLastMsg(String? pk, String? msg) {
    if (msg == null) {
      return _spf!.remove('im_$pk');
    } else {
      return _spf!.setString('im_$pk', msg);
    }
  }

  /// IM 读取与对方聊天的最后一条消息
  static IMMessage? getLastMsg(String? pk) {
    String? s = _spf!.getString('im_$pk');
    if (s == null) {
      return null;
    } else {
      return IMMessage.fromJson(json.decode(s),ChatType.user);
    }
  }

  /// IM 删除与对方聊天的最后一条消息
  static Future<bool> removeLastMsg(String? pk) {
    return _spf!.remove('im_$pk');
  }

  /// IM 保存群组聊天的最后一条消息
  static Future<bool> saveGroupLastMsg(String? groupId, String? msg) {
    if (msg == null) {
      return _spf!.remove('im_group_$groupId');
    } else {
      return _spf!.setString('im_group_$groupId', msg);
    }
  }

  /// IM 群组读取与对方聊天的最后一条消息
  static IMGroupMessage? getGroupLastMsg(String? groupId) {
    String? s = _spf!.getString('im_group_$groupId');
    if (s == null) {
      return null;
    } else {
      return IMGroupMessage.fromJson(json.decode(s),ChatType.groups);
    }
  }

  /// IM 删除与对方聊天的最后一条消息
  static Future<bool> removeGroupLastMsg(String? groupId) {
    return _spf!.remove('im_group_$groupId');
  }


  /// IM 客服保存与对方聊天的最后一条消息
  static Future<bool> saveStoreLastMsg(String? pk, String? msg) {
    if (msg == null) {
      return _spf!.remove('im_store_$pk');
    } else {
      return _spf!.setString('im_store_$pk', msg);
    }
  }

  /// IM 客服读取与对方聊天的最后一条消息
  static IMStoreMessage? getStoreLastMsg(String? pk) {
    String? s = _spf!.getString('im_store_$pk');
    if (s == null) {
      return null;
    } else {
      return IMStoreMessage.fromJson(json.decode(s),ChatType.store);
    }
  }

  /// 获取所有保存记录
  static Set<String> getIMKeys(){
    return _spf!.getKeys();
  }

  /// 按key删除数据
  static void removeByKey(String name){
    _spf!.remove(name);
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

  /// 将用群组加入免打扰用户列表
  static Future<bool> insertGroupMuteList(String groupId) async {
    List<String> list = getGroupMuteList();
    if (list.contains(groupId)) {
      return true;
    } else {
      list.add(groupId);
      return _spf!.setString('im_group_mute_list', list.join(','));
    }
  }

  /// 将群组从免打扰列表中移除。
  static Future<bool> removeFromGroupMuteList(String groupId) async {
    List<String> list = getGroupMuteList();
    if (list.contains(groupId)) {
      list.remove(groupId);
      return _spf!.setString('im_group_mute_list', list.join(','));
    } else {
      return true;
    }
  }

  /// 获取免打扰群组列表
  static List<String> getGroupMuteList() {
    List<String> ids = [];
    String? s = _spf!.getString('im_group_mute_list');
    if (s == null) {
      return ids;
    } else {
      return s.split(',');
    }
  }

  /// 将用客服加入免打扰用户列表
  static Future<bool> insertStoreMuteList(String storeId) async {
    List<String> list = getStoreMuteList();
    if (list.contains(storeId)) {
      return true;
    } else {
      list.add(storeId);
      return _spf!.setString('im_store_mute_list', list.join(','));
    }
  }

  /// 将客服从免打扰列表中移除。
  static Future<bool> removeFromStoreMuteList(String storeId) async {
    List<String> list = getStoreMuteList();
    if (list.contains(storeId)) {
      list.remove(storeId);
      return _spf!.setString('im_store_mute_list', list.join(','));
    } else {
      return true;
    }
  }

  /// 获取免打扰客服列表
  static List<String> getStoreMuteList() {
    List<String> ids = [];
    String? s = _spf!.getString('im_store_mute_list');
    if (s == null) {
      return ids;
    } else {
      return s.split(',');
    }
  }

  /// 获取已删除好友的id
  static List<String> getRemoveUserList() {
    List<String> ids = [];
    String? s = _spf!.getString('im_remove_user_list');
    if (s == null) {
      return ids;
    }
    return s.split(',');
  }

  /// 记录已删除好友的id
  static Future<bool> insertRemoveUserId(String id) async {
    List<String> list = getRemoveUserList();
    if (list.contains(id)) {
      return true;
    } else {
      list.add(id);
      return _spf!.setString('im_remove_user_list', list.join(','));
    }
  }
}
