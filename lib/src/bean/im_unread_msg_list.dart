import 'dart:convert';

/// IM未读消息列表
class IMMsgList {
  String ack, module;
  int code;
  Map<String, dynamic> messageList;

  IMMsgList({this.ack, this.module, this.code, this.messageList});

  factory IMMsgList.fromJson(Map<String, dynamic> data) {
    return IMMsgList(
      code: data['code'],
      ack: data['ack'],
      module: data['module'],
      messageList: data['messageList'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'ack': ack,
      'module': module,
      'messageList': messageList,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
