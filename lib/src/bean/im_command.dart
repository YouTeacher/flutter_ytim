import 'dart:convert';

/// 指令消息，已读回执、撤回消息
/// module：readMessage，revokeMessage，
class IMCommand {
  String action, module, from, to, timestamp;

  IMCommand({this.action, this.module, this.from, this.to, this.timestamp});

  factory IMCommand.fromJson(Map<String, dynamic> data) {
    return IMCommand(
      action: data['action'],
      module: data['module'],
      from: data['from'],
      to: data['to'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'module': module,
      'from': from,
      'to': to,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
