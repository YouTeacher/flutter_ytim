import 'dart:convert';

const int pageSize = 15;

///IM 通信指令
class YTIMApi {
  YTIMApi._();

  /// 登录
  static Map? loginApi() {
    return {
      "action": "set",
      "module": "login",
    };
  }

  ///取未读消息
  static String getUnreadMessageListApi() {
    return json.encode({"action": "get", "module": "unreadMessage"});
  }

  /// 获取总数据列表 朋友 群组 会话 系统消息
  static String getTotalListApi() {
    return json.encode({
      "action": "get",
      "module": "userList",
      "getUnreadMessage": 1,
      "getGroupUnreadMessageCount": 1,
      "getStoreUnreadMessageCount": 1
    });
  }

  /// 获取朋友
  static String getFriendListApi() {
    return json.encode({
      "action": "get",
      "module": "userList",
    });
  }

  /// 获取未读消息
  static String unreadMessageApi() {
    return json.encode({"action": "get", "module": "unreadMessage"});
  }

  // 获取系统消息
  static String getSysMessageApi(int nextMessageId) {
    return json.encode({
      "action": "get",
      "module": "systemMessage",
      "pageSize": pageSize,
      "nextMessageId": nextMessageId
    });
  }

  ///设置系统消息已读
  static String readSysMessageApi(String messageId) {
    return json.encode(
        {"action": "set", "module": "systemMessage", "messageId": messageId});
  }

  /// 普通消息已读回执 tid 为用户id
  static String readMessageApi(String tid) {
    return json.encode({"action": "set", "module": "message", "to": tid});
  }

  ///设置已读
  static String readGroupMessageApi(
    String groupId,
  ) {
    return json.encode(
        {"action": "set", "module": "groupMessage", "groupId": groupId});
  }

  //客服消息已读
  static String sendStoreReadMessage(String storeId) {
    return json.encode(
        {"action": "set", "module": "storeMessage", "storeId": storeId});
  }

  ///取用户名片
  static String getUserDataApi(String userId) {
    return json.encode({"action": "get", "module": "card", "userId": userId});
  }

  ///添加好友
  static String addFriendApi(String userId) {
    return json.encode({"action": "add", "module": "friend", "userId": userId});
  }

  // 搜索好友
  static String searchFriendApi(String keyword) {
    return json.encode({
      "action": "get",
      "module": "search",
      "type": "user",
      "keyword": keyword
    });
  }

  // 搜索群
  static String searchGroupApi(String keyword) {
    return json.encode({
      "action": "get",
      "module": "search",
      "type": "group",
      "keyword": keyword
    });
  }

  ///通过好友申请
  static String agreeFriendAddApi(String userId, {String? name}) {
    return json.encode({
      "action": "set",
      "module": "friend",
      "userId": userId,
      "nickname": name
    });
  }

  ///拒绝好友请求
  static String rejectFriendAddApi(String userId) {
    return json.encode({"action": "ref", "module": "friend", "userId": userId});
  }

  ///设置个人信息
  static String setUserDataUrl({String? name, String? avatar, String? sex}) {
    return json.encode({
      "action": "set",
      "module": "profile",
      "username": name,
      "sex": sex,
      "avatar": avatar
    });
  }

  // 设置昵称
  static String setFriendNickNameApi(String userId, {String? nickname}) {
    return json.encode({
      "action": "set",
      "module": "card",
      "userId": userId,
      "nickname": nickname
    });
  }

  ///删除好友 userId  status 0删除 1(双方同时删除）
  static String deleteFriendApi(String userId, String status) {
    return json.encode({
      "action": "del",
      "module": "friend",
      "userId": userId,
      "force": status
    });
  }

  /// 发送消息
  ///type:1文本 2图片 3语音文件 4视频文件 5其他文件 6地图
  static String sendMessage(
      String tid, String? tName, String content, String type) {
    return json.encode({
      "action": "add",
      "module": "message",
      "to": tid,
      "toName": tName,
      "type": type,
      "content": content
    });
  }

  /// 删除会话记录
  static String deleteChatApi(String chatId) {
    return json
        .encode({"action": "del", "module": "sessionDelete", "to": chatId});
  }

  /// 获取历史消息列表
  static String historyMessageApi(String tid, String? nextTime) {
    return json.encode({
      "action": "get",
      "module": "message",
      "userId": tid,
      "time": nextTime,
      "pageSize": pageSize
    });
  }

  /// 撤销消息
  /// [tIMId] 通知对方imid
  /// [timestamp] 消息时间戳
  static String revokeMessageApi(String tIMId, String? timestamp) {
    return json.encode(
        {"action": "cnl", "module": "message", "to": tIMId, "time": timestamp});
  }

  ///创建群组
  static String creatGroupApi(String name, String avatar, {String? desc}) {
    return json.encode({
      "action": "add",
      "module": "group",
      "name": name,
      "desc": desc,
      "avatar": avatar
    });
  }

  ///取群信息
  ///getGroupUser表示是否取群用户，请灵活运用
  static String getGroupDataApi(
    String groupId, {
    int? getGroupUser,
  }) {
    return json.encode({
      "action": "get",
      "module": "group",
      "groupId": groupId,
      "getGroupUser": getGroupUser ?? 0,
    });
  }

  ///修改群信息
  static String setGroupDataApi(String groupId, String name, String avatar,
      {String? desc}) {
    return json.encode({
      "action": "set",
      "module": "group",
      "groupId": groupId,
      "name": name,
      "avatar": avatar,
      "desc": desc
    });
  }

  ///删除群
  static String deleteGroupApi(String groupId) {
    return json
        .encode({"action": "del", "module": "group", "groupId": groupId});
  }

  ///添加群成员
  static String setGroupUsersApi(String groupId, List<String> userIds) {
    return json.encode({
      "action": "add",
      "module": "groupUser",
      "groupId": groupId,
      "userIdList": userIds
    });
  }

  ///修改群成员信息
  ///userType 1、创建者，2、管理员，3、普通群成员
  ///nickname，userType选填
  ///注：创建者可以修改群成员昵称和设置成群管理员（userType=2）
  ///注：管理员可以修改群成员昵称
  static String setGroupUserRoleApi(String groupId, String userId,
      {String? nickname, String? userType}) {
    return json.encode({
      "action": "set",
      "module": "groupUser",
      "groupId": groupId,
      "userId": userId,
      "nickname": nickname,
      "userType": userType
    });
  }

  ///群成员编辑自己信息
  static String setGroupMineUserDataApi(
    String groupId,
    String nickname,
  ) {
    return json.encode({
      "action": "set",
      "module": "groupUser",
      "groupId": groupId,
      "nickname": nickname
    });
  }

  ///删除群成员
  ///
  static String deleteGroupUserApi(
    String groupId,
    List<String> userIds,
  ) {
    return json.encode({
      "action": "del",
      "module": "groupUser",
      "groupId": groupId,
      "userIdList": userIds
    });
  }

  ///申请入群
  ///
  static String joinGroupApi(String groupId) {
    return json
        .encode({"action": "set", "module": "joinGroup", "groupId": groupId});
  }

  ///同意入群申请
  ///messageId 系统消息id
  static String agreeJoinGroupApi(
    String groupId,
    String messageId,
  ) {
    return json.encode({
      "action": "add",
      "module": "joinGroup",
      "groupId": groupId,
      "messageId": messageId
    });
  }

  ///拒绝入群申请
  ///messageId 系统消息id
  static String rejectJoinGroupApi(
    String groupId,
    String messageId,
  ) {
    return json.encode({
      "action": "ref",
      "module": "joinGroup",
      "groupId": groupId,
      "messageId": messageId
    });
  }

  ///退出群组
  static String exitGroupApi(
    String groupId,
  ) {
    return json
        .encode({"action": "del", "module": "joinGroup", "groupId": groupId});
  }

  ///发送群消息
  ///注：参数to值为数组时，表示@相应的人（0表示全部，其它值表示用户id），为字符串或空时，表示只是在群里说话
  ///注：消息体里的time字段，是时间戳，也是一个类似于消息id一样的东西
  ///type:1文本 2图片 3语音文件 4视频文件 5其他文件 6地图
  static String sendGroupMessageApi(String groupId, String type, String content,
      {List<String>? atUserIds}) {
    return json.encode({
      "action": "add",
      "module": "groupMessage",
      "groupId": groupId,
      "to": atUserIds,
      "type": type,
      "content": content
    });
  }

  ///群组历史聊天记录
  ///注：参数time("13位时间戳")，确定之后就不要改变值，服务器会取比该数值小的数据，因为群消息可能是一直有人说话的，如果没有一个参照，取到的数据可能会重复.进入群组会话页面出是一个值
  ///注：isRecall参数表示消息是否撤回
  static String getGroupMessageListApi(String groupId, String? nextTime) {
    return json.encode({
      "action": "get",
      "module": "groupMessage",
      "groupId": groupId,
      "time": nextTime,
      "pageSize": pageSize
    });
  }

  ///撤回群组消息
  ///time 群消息时间（"1700465977534"）
  static String revokeGroupMessageApi(
    String groupId,
    String time,
  ) {
    return json.encode({
      "action": "cnl",
      "module": "groupMessage",
      "groupId": groupId,
      "time": time
    });
  }

  ///取个人资料
  static String getMineUserDataApi() {
    return json.encode({"action": "get", "module": "profile"});
  }

  //发送客服消息
  static String sendStoreMessage(String storeId, String content, String type) {
    return json.encode({
      "action": "add",
      "module": "storeMessage",
      "storeId": storeId,
      "type": type,
      "content": content
    });
  }

  //客服消息撤回
  static String revokeStoreMessageApi(
    String storeId,
    String? time,
  ) {
    return json.encode({
      "action": "cnl",
      "module": "storeMessage",
      "storeId": storeId,
      "time": time
    });
  }

  //取客服历史消息
  static String historyStoreMessageApi(String storeId, String? nextTime) {
    return json.encode({
      "action": "get",
      "module": "storeMessage",
      "storeId": storeId,
      "time": nextTime,
      "pageSize": pageSize,
    });
  }
}
