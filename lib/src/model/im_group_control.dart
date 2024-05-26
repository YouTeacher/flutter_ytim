import 'dart:convert';

import 'package:flutter_ytim/src/model/im_user.dart';

/// IM群聊成员以及群变化信息
class IMGroupControl {
  /// 操作对象
  String? module;

  /// 操作事件
  String? event;

  /// 群组id。
  String? groupId;

  /// 群组名称
  String? groupName;

  /// 群组头像
  String? groupAvatar;

  /// 来源
  String? from;

  /// 来源名称
  String? fromName;

  /// 内容
  String? content;

  List<IMUser>? userList;


  IMGroupControl({
    this.groupId,
    this.groupName,
    this.groupAvatar,
    this.from,
    this.fromName,
    this.content,
    this.userList
  });

  factory IMGroupControl.fromJson(Map<String, dynamic> json) {
    return IMGroupControl(
      groupId: json['groupId']?.toString(),
      groupName: json['groupName'].toString(),
      groupAvatar: json['groupAvatar'].toString(),
      from: json['from'].toString(),
      fromName: json['fromName'] ?? '',
      content: json['content'] ?? '',
      userList: json['userList'] == null
          ? null
          : (json['userList'] as List).map((e) => IMUser.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
      'from': from,
      'fromName': fromName,
      'content': content,
      'userList': userList,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
