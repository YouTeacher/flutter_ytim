import 'dart:convert';

import 'package:flutter_ytim/flutter_ytim.dart';

/// IM消息体
class IMMessage extends IMBaseMessage {
  String? fromName, to, at, groupId;

  // 本地保存的最后一条消息主键：对方的im_id
  String? pk;

  IMMessage({
    required super.chatType,
    super.type,
    super.from,
    this.fromName,
    this.to,
    this.at,
    super.time,
    super.content,
    super.isRead,
    super.isRecall,
    super.filePath,
    super.uuid,
    super.status,
  });

  factory IMMessage.fromJson(Map<String, dynamic> json, ChatType chatType) {
    return IMMessage(
      chatType: chatType,
      type: json['type']?.toString(),
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      at: json['at'],
      fromName: json['fromName'],
      time: json['time'],
      content: json['content'],
      isRead: json['isRead']?.toString(),
      isRecall: json['isRecall']?.toString(),
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'from': from,
      'fromName': fromName,
      'to': to,
      'at': at,
      'time': time,
      'content': content,
      'isRead': isRead,
      'isRecall': isRecall,
      'pk': pk,
      'filePath': filePath,
      'uuid': uuid,
      'status': status,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
