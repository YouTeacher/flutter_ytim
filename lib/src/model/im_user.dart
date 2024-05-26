import 'dart:convert';

/// IM用户信息
class IMUser {
  /// 注册时返回的用户id。
  String? userId;

  /// 联系人名称
  String? username;

  String? introduction;

  /// 联系人性别
  int? sex;

  /// 联系人头像
  String? avatar;

  /// 本地字段。 未读消息数，用于在聊天历史列表设置未读消息个数。
  int? unreadCount;

  /// "online":"是否在线（0：离线，1：在线）"
  int? online;

  /// 本地字段 好友状态: 0非好友 1审核中 2非好友
  int? firendStatus;

  ///群组成员时模型字段
  String? groupId;

  // 1创建者，2管理员，3普通群员
  String? userType;
  String? nickname;

  IMUser({
    this.userId,
    this.username,
    this.avatar,
    this.sex,
    this.unreadCount,
    this.online,
    this.groupId,
    this.userType,
    this.nickname,
    this.introduction,
  });

  factory IMUser.fromJson(Map<String, dynamic> json) {
    return IMUser(
      userId: (json['userId'] ?? json['imUserId'])?.toString(),
      online: json['online'] ?? 0,
      username: json['username'],
      sex: json['sex'],
      avatar: json['avatar'] ?? '',
      unreadCount: 0,
      groupId: json['groupId'].toString(),
      userType: json['userType'].toString(),
      nickname: json['nickname'],
      introduction: json['introduction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sex': sex,
      'username': username,
      'avatar': avatar,
      'online': online,
      'unreadCount': unreadCount,
      'groupId': groupId,
      'userType': userType,
      'nickname': nickname,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
