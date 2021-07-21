import 'dart:convert';

import 'package:flutter_ytim/src/bean/im_msg.dart';

/// 历史消息列表
class IMHistoryMsgList {
  String? action, module, lastTimestamp;
  int? code, limit, userId;
  List<IMMessage>? messageList;

  IMHistoryMsgList({
    this.action,
    this.module,
    this.lastTimestamp,
    this.code,
    this.limit,
    this.userId,
    this.messageList,
  });

  factory IMHistoryMsgList.fromJson(Map<String, dynamic> data) {
    return IMHistoryMsgList(
      action: data['action'],
      module: data['module'],
      lastTimestamp: data['lastTimestamp'],
      code: data['code'],
      limit: data['limit'],
      userId: data['userId'],
      messageList: data['messageList'] == null
          ? null
          : (data['messageList'] as List)
              .map((e) => IMMessage.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'module': module,
      'lastTimestamp': lastTimestamp,
      'code': code,
      'limit': limit,
      'userId': userId,
      'messageList': messageList,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
