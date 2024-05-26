import 'dart:convert';

import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_base_message.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';

//{"storeId":1000,"userId":7,"time":"1704943193313","consultationId":4,"isRead":"000","isRecall":"001","from":4,"type":1,"content":"你也好"}/// IM群组消息体
class IMStoreMessage extends IMBaseMessage{
  String? storeId,
      userId,
      consultationId;
  List<int>? at;
  String? lastTalkAt;
  StoreModel? store;
  IMUser? fromUser;

  IMStoreMessage({
    this.storeId,
    this.userId,
    super.isRead,
    super.type,
    super.from,
    this.at,
    super.time,
    super.content,
    super.isRecall,
    super.filePath,
    super.uuid,
    super.status,
    this.fromUser, required super.chatType,
  });

  factory IMStoreMessage.fromJson(Map<String, dynamic> json,ChatType chatType) {
    Map<String, dynamic> fromJson;
    if (json['formUser'] != null) {
      fromJson = json['formUser'];
      fromJson['userId'] = null;
    }

    return IMStoreMessage(
      chatType: chatType,
      storeId: json['storeId']?.toString(),
      userId: json['userId']?.toString(),
      isRead: json['isRead']?.toString(),
      type: json['type']?.toString(),
      from: json['from']?.toString(),
      at: json['at'],
      time: json['time'],
      content: json['content'],
      isRecall: json['isRecall']?.toString(),
      filePath: json['filePath']?.toString(),
      uuid: json['uuid'],
      status: json['status'],
      fromUser: json['fromUser'] == null
          ? null
          : IMUser.fromJson(
              json['fromUser'],
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'userId': userId,
      'isRead': isRead,
      'type': type,
      'from': from,
      'at': at,
      'time': time,
      'content': content,
      'isRecall': isRecall,
      'filePath': filePath,
      'uuid': uuid,
      'status': status,
      'fromUser': fromUser,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
