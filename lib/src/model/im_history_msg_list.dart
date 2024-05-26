import 'dart:convert';

import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_group_message.dart';
import 'package:flutter_ytim/src/model/im_message.dart';
import 'package:flutter_ytim/src/model/im_store_message.dart';
import 'package:flutter_ytim/src/ytim.dart';

/// 历史消息列表
class IMHistoryMsgList {
  ChatType chatType;
  String? userId, timestamp, nextTime,groupId;
  int? pageSize;
  List<IMBaseMessage>? messageList;
  bool hasMore;

  IMHistoryMsgList({
    required this.chatType,
    this.userId,
    this.groupId,
    this.nextTime,
    this.timestamp,
    this.pageSize,
    this.messageList,
    this.hasMore = false,
  });

  factory IMHistoryMsgList.fromJson(Map<String, dynamic> data,ChatType chatType) {
    return IMHistoryMsgList(
      chatType: chatType,
      userId: data['userId']?.toString(),
      groupId:data['groupId']?.toString(),
      nextTime: data['nextTime'],
      pageSize: data['pageSize'] ?? 15,
      hasMore: data['hasMore'],
      timestamp: data['timestamp'],
      messageList: data['messageList'] == null
          ? null
          : (data['messageList'] as List)
              .map((e) => IMBaseMessage.fromJson(e,chatType))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'pageSize': pageSize,
      'nextTime': nextTime,
      'userId': userId,
      'messageList': messageList,
      'hasMore': hasMore,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
