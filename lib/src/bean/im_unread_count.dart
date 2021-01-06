import 'dart:convert';

class IMUnreadCount {
  int count;

  IMUnreadCount({this.count});

  factory IMUnreadCount.fromJson(Map<String, dynamic> data) {
    return IMUnreadCount(
      count: data['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
