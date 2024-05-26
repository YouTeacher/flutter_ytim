import 'dart:convert';

import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_sys_msg.dart';
import 'package:flutter_ytim/src/model/im_user.dart';

/// IM用户列表
class IMUserList {
  String? action, module;
  int? code;
  List<IMUser>? friendList; //朋友列表
  List<IMChatModel>? sessionList; //会话列表
  List<IMSysMessage>? systemMessageList; //系统消息列表
  List<IMGroup>? groupList;

  IMUserList(
      {this.action,
      this.module,
      this.code,
      this.friendList,
      this.sessionList,
      this.systemMessageList,
      this.groupList});

  factory IMUserList.fromJson(Map<String, dynamic> data) {
    return IMUserList(
      action: data['action'],
      module: data['module'],
      code: data['code'],
      friendList: data['friendList'] == null
          ? null
          : (data['friendList'] as List)
              .map((e) => IMUser.fromJson(e))
              .toList(),
      sessionList: data['sessionList'] == null
          ? null
          : (data['sessionList'] as List)
              .map((e) => IMChatModel.fromJson(e))
              .toList(),
      groupList: data['groupList'] == null
          ? null
          : (data['groupList'] as List).map((e) {
              IMGroup? group = IMGroup.fromJson(e['group']);
              group.unreadMessageCount = e['unreadMessageCount'] ?? 0;
              return group;
            }).toList(),
      systemMessageList: data['systemMessageList'] == null
          ? null
          : (data['systemMessageList'] as List)
              .map((e) => IMSysMessage.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'module': module,
      'code': code,
      'friendList': friendList,
      'sessionList': sessionList,
      'groupList': groupList,
      'systemMessageList': systemMessageList,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
