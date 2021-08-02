import 'dart:convert';

import 'package:flutter_ytim/src/bean/im_user.dart';

/// IM用户列表
class IMUserList {
  String? action, module;
  int? code;
  List<IMUser>? userList;

  IMUserList({this.action, this.module, this.code, this.userList});

  factory IMUserList.fromJson(Map<String, dynamic> data) {
    return IMUserList(
      action: data['action'],
      module: data['module'],
      code: data['code'],
      userList: data['userList'] == null
          ? null
          : (data['userList'] as List).map((e) => IMUser.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'module': module,
      'code': code,
      'userList': userList,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
