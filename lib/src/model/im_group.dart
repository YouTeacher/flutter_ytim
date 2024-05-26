import 'dart:convert';

import 'package:flutter_ytim/src/model/im_user.dart';

/// IM用户信息
class IMGroup {
  /// 群组id。
  String? groupId;

  /// 群组名称
  String? name;

  /// 群组头像
  String? avatar;

  /// 群组描述
  String? desc;

  ///群组时间
  String? lastTalkAt;

  /// 本地字段。 未读消息数，用于在聊天历史列表设置未读消息个数。
  List<IMUser>? userList;

  int? unreadMessageCount;

  // 本地字段 申请入群状态  0待申请 1已申请
  int? groupdStatus;

  IMGroup({
    this.groupId,
    this.name,
    this.avatar,
    this.desc,
    this.lastTalkAt,
    this.userList,
    this.unreadMessageCount,
  });

  factory IMGroup.fromJson(Map<String, dynamic> json) {
    return IMGroup(
      groupId: json['groupId']?.toString(),
      name: json['name'].toString(),
      avatar: json['avatar'].toString(),
      desc: json['desc'].toString(),
      lastTalkAt: json['lastTalkAt'] ?? '',
      userList: json['userList'] == null
          ? null
          : (json['userList'] as List).map((e) => IMUser.fromJson(e)).toList(),
      unreadMessageCount: json['unreadMessageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'name': name,
      'avatar': avatar,
      'desc': desc,
      'userList': userList,
      'lastTalkAt': lastTalkAt,
      'unreadMessageCount': unreadMessageCount,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
