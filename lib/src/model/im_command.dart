import 'dart:convert';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/ytim.dart';
/// 指令消息，已读回执、撤回消息
/// event: set、"cnl"
class IMCommand {
  ChatType chatType;

  String? event;

  IMBaseMessage? msgData;

  IMCommand({required this.chatType,this.event, this.msgData});

  factory IMCommand.fromJson(Map<String, dynamic> data,ChatType chatType) {
    return IMCommand(
      chatType: chatType,
      event: data['event'],
      msgData: data['data'] != null ? IMBaseMessage.fromJson(data['data'],chatType) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'data': msgData,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
