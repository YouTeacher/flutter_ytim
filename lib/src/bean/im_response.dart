import 'package:flutter_ytim/src/bean/im_user.dart';

/// IM返回值
class ImResponse {
  int? code;
  String? msg;
  IMUser? userInfo;

  ImResponse({this.code, this.msg, this.userInfo});

  factory ImResponse.fromJson(Map<String, dynamic> json) {
    return ImResponse(
      code: json['code'],
      msg: json['msg'],
      userInfo:
          json['userInfo'] == null ? null : IMUser.fromJson(json['userInfo']),
    );
  }
}
