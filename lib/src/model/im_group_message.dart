import 'dart:convert';

import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_base_message.dart';

// "groupId":10002,"time":"1700465977534","isRecall":1,"from":7,"to":[0],"type":1,"content":"该消息已经撤回"
/// IM群组消息体
class IMGroupMessage extends IMBaseMessage{
  String? groupId;
  List<int>? at;

  IMGroupMessage({
    required super.chatType,
    this.groupId,
    super.from,
    this.at,
    super.uuid,
    super.content,
    super.filePath,
    super.isRecall,
    super.status,
    super.time,
    super.type,
  });

  factory IMGroupMessage.fromJson(Map<String, dynamic> json,ChatType chatType) {

    return IMGroupMessage(
      chatType: chatType,
        groupId: json['groupId']?.toString(),
        type: json['type']?.toString(),
        from: json['from']?.toString(),
        at: json['at'],
        time: json['time'],
        content: json['content'],
        isRecall: json['isRecall']?.toString(),
        filePath: json['filePath']?.toString(),
        uuid: json['uuid'],
        status: json['status']);
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'type': type,
      'from': from,
      'at': at,
      'time': time,
      'content': content,
      'isRecall': isRecall,
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
