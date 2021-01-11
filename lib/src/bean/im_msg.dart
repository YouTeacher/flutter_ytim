import 'dart:convert';

/// IM消息体
class IMMessage {
  String type,
      read, // "0"：未读， "1"：已读
      from,
      to,
      timestamp,
      time,
      content;

  // 本地保存的最后一条消息主键：对方的im_id
  String pk;

  IMMessage({
    this.type,
    this.from,
    this.to,
    this.timestamp,
    this.time,
    this.content,
    this.read,
    this.pk,
  });

  factory IMMessage.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return IMMessage(
      type: json['type'],
      from: json['from'],
      to: json['to'],
      timestamp: json['timestamp'],
      time: json['time'],
      content: json['content'],
      read: json['read'],
      pk: json['pk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'from': from,
      'to': to,
      'timestamp': timestamp,
      'time': time,
      'content': content,
      'read': read,
      'pk': pk,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
