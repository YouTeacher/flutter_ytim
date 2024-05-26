
import 'package:flutter_ytim/flutter_ytim.dart';

class IMBaseMessage{

  /// status 0发送成功 1发送中 2发送失败
  /// isRead, "0"：未读， "1"：已读
  /// isRecall,"0"：未撤回， "1"：已撤回


  String? type,status,content,filePath,time,isRecall,isRead,uuid,from;
  ChatType chatType;

  IMBaseMessage({
    required this.chatType,
    this.type,
    this.status,
    this.content,
    this.filePath,
    this.time,
    this.isRecall,
    this.isRead,
    this.uuid,
    this.from,
  });

  factory IMBaseMessage.fromJson(Map<String, dynamic> json,ChatType chatType) {
    switch(chatType){
      case ChatType.user:
        return IMMessage.fromJson(json,chatType);
      case ChatType.groups:
        return IMGroupMessage.fromJson(json,chatType);
      case ChatType.store:
        return IMStoreMessage.fromJson(json,chatType);
    }
  }
}