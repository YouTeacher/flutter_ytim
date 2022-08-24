import 'dart:convert';

import 'package:flutter_ytim/src/bean/im_user.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> data = {
    "id": "1",
    "userId": "1",
    "online": 0,
    "companyId": "1000",
    "account": "and2long",
    "password": "111111",
    "username": "lilong.zhang",
    "headImg": "http://",
  };

  test('the member variable of empty constructor should be null', () {
    final bean = IMUser();
    expect(null, bean.id);
    expect(null, bean.userId);
    expect(null, bean.unreadCount);
    expect(null, bean.online);
    expect(null, bean.companyId);
    expect(null, bean.account);
    expect(null, bean.password);
    expect(null, bean.username);
    expect(null, bean.headImg);
  });

  test('convert entity through json', () {
    final bean = IMUser.fromJson(data);
    expect("1", bean.id);
    expect("1", bean.userId);
    expect(0, bean.online);
    expect("1000", bean.companyId);
    expect("and2long", bean.account);
    expect("111111", bean.password);
    expect("lilong.zhang", bean.username);
    expect("http://", bean.headImg);
  });

  test('convert to json from entity', () {
    IMUser bean = IMUser(
        id: "1",
        userId: "1",
        online: 0,
        companyId: "1000",
        account: "and2long",
        password: "111111",
        username: "lilong.zhang",
        headImg: "http://");
    final data = bean.toJson();
    expect("1", data["id"]);
    expect("1", data["userId"]);
    expect(0, data["online"]);
    expect("1000", data["companyId"]);
    expect("and2long", data["account"]);
    expect("111111", data["password"]);
    expect("lilong.zhang", data["username"]);
    expect("http://", data["headImg"]);
  });

  test('test for function od toString', () {
    expect(json.encode(data), IMUser.fromJson(data).toString());
  });
}
