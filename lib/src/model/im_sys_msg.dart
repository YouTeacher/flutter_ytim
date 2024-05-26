import 'dart:convert';

/// IM系统信息
class IMSysMessage {
  /// 消息id。
  String? messageId;

  ///单聊
  String? from, fromName, avatar;

  ///群组
  String? groupId, groupName, groupAvatar;

  /// 类型 10、加好友，11、通过好友，12、拒绝好，20、申请入群，21、同意入群，22、拒绝入群）
  String? type, content;

  String? module;
  String? event;

  IMSysMessage({
    this.messageId,
    this.from,
    this.fromName,
    this.groupId,
    this.groupName,
    this.type,
    this.avatar,
    this.groupAvatar,
    this.content,
    this.event,
    this.module,
  });

  factory IMSysMessage.fromJson(Map<String, dynamic> json) {
    return IMSysMessage(
      messageId: json['messageId']?.toString(),
      from: json['from'].toString(),
      fromName: json['fromName'].toString(),
      groupId: json['groupId'].toString(),
      groupName: json['groupName'].toString(),
      content: json['content'].toString(),
      type: json['type'].toString(),
      avatar: json['avatar'],
      groupAvatar: json['groupAvatar'],
      event: json['event'],
      module: json['module'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'from': from,
      'fromName': fromName,
      'groupId': groupId,
      'groupName': groupName,
      'content': content,
      'type': type,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
