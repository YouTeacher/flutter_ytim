import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_group_message.dart';
import 'package:flutter_ytim/src/model/im_message.dart';
import 'package:flutter_ytim/src/model/im_store_message.dart';
import 'package:flutter_ytim/src/model/im_sys_msg.dart';
import 'package:flutter_ytim/src/model/im_unread_count.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_sp_utils.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:provider/provider.dart';

class IMUtils {
  static String getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 根据全局IM信息 更新IM未读消息。
  static void updateUnreadCount(BuildContext context) {
    int count = 0;
    List<ChatType> typeList = [ChatType.user, ChatType.groups, ChatType.store];
    for(ChatType type in typeList){
      Map<String?, IMLastInfo> map = context.read<IMStore>().getLastInfo(type);
      map.removeWhere((key, value) => key == 'null');
      List<IMLastInfo> values = map.values.toList();
      if (values.isNotEmpty) {
        for (var element in values) {
          count += element.unreadCount;
        }
      }
    }
    if (YTIM().unreadCountCallback != null) {
      YTIM().unreadCountCallback!(count);
    }
  }

  /// 获取最后会话一条消息
  static IMBaseMessage? getLastChatMessage(ChatType chatType, String? id) {
    switch (chatType) {
      case ChatType.user:
        return IMSPUtils.getLastMsg(id);
      case ChatType.groups:
        return IMSPUtils.getGroupLastMsg(id);
      case ChatType.store:
        return IMSPUtils.getStoreLastMsg(id);
    }
  }

  /// 设置最后一条消息
  static void setLastMessage(BuildContext context) {
    List<IMChatModel> chats = context.read<IMStore>().chats;
    var timestamp = IMUtils.getTimestamp();
    for (var i = 0; i < chats.length; i++) {
      IMChatModel chat = chats[i];

      IMBaseMessage? msg = IMUtils.getLastChatMessage(
          chat.chatType,
          chat.chatType == ChatType.user
              ? chat.userId
              : chat.chatType == ChatType.groups
                  ? chat.groupId
                  : chat.storeId);
      if ((chat.unreadMessageList ?? []).isNotEmpty) {
        msg = chat.unreadMessageList!.last;
      }

      Map<String?, IMLastInfo> map =
          context.read<IMStore>().getLastInfo(chat.chatType);

      if (msg != null) {
        switch (chat.chatType) {
          case ChatType.user:
            //有最后一条数据的来源
            map[chat.userId] = IMLastInfo(
                msg: msg, unreadCount: (chat.unreadMessageList ?? []).length);
            break;
          case ChatType.groups:
            //有最后一条数据的来源
            map[chat.groupId] =
                IMLastInfo(msg: msg, unreadCount: chat.unreadMessageCount ?? 0);
            break;
          case ChatType.store:
            //有最后一条数据的来源
            map[chat.storeId] =
                IMLastInfo(msg: msg, unreadCount: chat.unreadMessageCount ?? 0);
            break;
        }
      } else {
        switch (chat.chatType) {
          case ChatType.user:
            //无最后一条数据的来源
            if (map[chat.userId] == null) {
              map[chat.userId] = IMLastInfo(
                  msg: IMMessage(
                      time: chat.lastTalkAt,
                      content: '',
                      chatType: ChatType.user));
            } else {
              map[chat.userId]!.msg = IMMessage(
                  time: chat.lastTalkAt, content: '', chatType: ChatType.user);
            }
            break;
          case ChatType.groups:
            //无最后一条数据的来源
            if (map[chat.groupId] == null) {
              map[chat.groupId] = IMLastInfo(
                  msg: IMGroupMessage(
                      time: chat.lastTalkAt,
                      content: '',
                      chatType: ChatType.groups));
            } else {
              map[chat.groupId]?.msg = IMGroupMessage(
                  time: chat.lastTalkAt,
                  content: '',
                  chatType: ChatType.groups);
            }
            break;
          case ChatType.store:
            //无最后一条数据的来源
            if (map[chat.storeId] == null) {
              map[chat.storeId] = IMLastInfo(
                  msg: IMStoreMessage(
                      time: chat.lastTalkAt,
                      content: '',
                      chatType: ChatType.store));
            } else {
              map[chat.storeId]?.msg = IMStoreMessage(
                  time: chat.lastTalkAt, content: '', chatType: ChatType.store);
            }
            break;
        }
      }

      context.read<IMStore>().updateLastInfo(chat.chatType, map);

      if (msg?.time != null) {
        chat.lastTalkAt = msg?.time;
        chats[i] = chat;
      }
    }
    IMUtils.updateUnreadCount(context);
    chats.sort((a, b) => int.parse(b.lastTalkAt ?? timestamp)
        .compareTo(int.parse(a.lastTalkAt ?? timestamp)));
    context.read<IMStore>().updateChats(chats);
  }

  /// 将好友更新到通讯录中, 消息更新到会话中
  static void addFriend(
    BuildContext context,
    IMSysMessage model,
  ) {
    // 好友更新到通讯录中
    List<IMUser> firends = context.read<IMStore>().firends;
    IMUser user = IMUser(
      userId: model.from,
      avatar: model.avatar,
      nickname: model.fromName,
    );

    bool isFriends = false;
    for (var item in firends) {
      if (item.userId == model.from) {
        isFriends = true;
        break;
      }
    }
    if (!isFriends) {
      firends.add(user);
    }

    context.read<IMStore>().updateFirends(firends);

    //消息更新到会话中
    List<IMChatModel> chats = context.read<IMStore>().chats;
    var chat = IMChatModel(
      userInfo: user,
      userId: user.userId,
      chatType: ChatType.user,
      lastTalkAt: IMUtils.getTimestamp(),
    );

    bool isChats = false;
    for (var item in chats) {
      if (item.userId == model.from) {
        isChats = true;
        break;
      }
    }
    if (!isChats) {
      chats.add(chat);
    }

    context.read<IMStore>().updateChats(chats);

    // 设置最后一条消息
    IMUtils.setLastMessage(context);
  }

  /// 删除好友，把好友从会话，通讯录，最后一条消息的数据删除，更新消息数量
  static void deleteFriend(BuildContext context, String userId) {
    // 删除通讯录
    List<IMUser> items = context.read<IMStore>().firends;
    items.removeWhere((element) => element.userId == userId);
    context.read<IMStore>().updateFirends(items);

    // 删除会话
    List<IMChatModel> chats = context.read<IMStore>().chats;
    chats.removeWhere((element) => element.userId == userId);
    context.read<IMStore>().updateChats(chats);

    // 删除最后一条消息
    Map<String?, IMLastInfo> map =
        context.read<IMStore>().getLastInfo(ChatType.user);
    map.remove(userId);
    context.read<IMStore>().updateLastInfo(ChatType.user, map);

    // 更新未读数量
    IMUtils.updateUnreadCount(context);

    /// 删除最后一条聊天消息
    IMSPUtils.removeLastMsg(userId);
  }

  /// 删除群，把群从会话，通讯录，最后一条消息的数据删除，更新消息数量
  static void deleteGroup(BuildContext context, String groupId) {
    // 删除会话
    List<IMChatModel> chats = context.read<IMStore>().chats;
    chats.removeWhere((element) => element.groupId == groupId);
    context.read<IMStore>().updateChats(chats);

    // 删除群
    List<IMGroup> groups = context.read<IMStore>().groups;
    groups.removeWhere((element) => element.groupId == groupId);
    context.read<IMStore>().updateGroups(groups);

    // 删除最后一条消息
    Map<String?, IMLastInfo> map =
        context.read<IMStore>().getLastInfo(ChatType.groups);
    map.remove(groupId);
    context.read<IMStore>().updateLastInfo(ChatType.groups, map);

    /// 删除最后一条聊天消息
    IMSPUtils.removeGroupLastMsg(groupId);

    // 更新未读数量
    IMUtils.updateUnreadCount(context);
  }

  /// 添加IM通知消息
  static void addSysMessage(BuildContext context, IMSysMessage event) {
    List<IMSysMessage> sysMessageList = context.read<IMStore>().sysMessages;
    sysMessageList.add(event);
    context.read<IMStore>().updateSysMessages(sysMessageList);
  }

  /// 从服务器返回数据过滤掉已经是好友的用户
  static void filterFriends(
      BuildContext context, String str, Callback<List<IMUser>> callback) {
    Map<String, dynamic> obj = json.decode(str);
    if (obj['code'] == 200) {
      List<IMUser> list = List.from(obj['data'].map((e) => IMUser.fromJson(e)));
      List<IMUser> users = context.read<IMStore>().firends;
      //过滤掉已添加的好友
      List<IMUser> filterList = list;
      if (users.isNotEmpty) {
        for (var i = 0; i < list.length; i++) {
          var item = list[i];
          for (var user in users) {
            if (user.userId == item.userId) {
              filterList.removeAt(i);
            }
          }
        }
      }
      list = filterList;
      callback(list);
    }
  }

  /// 从服务器返回数据过滤掉已经是群成员的群
  static void filterGroups(
      BuildContext context, String str, Callback<List<IMGroup>> callback) {
    Map<String, dynamic> obj = json.decode(str);
    if (obj['code'] == 200) {
      List<IMGroup> list =
          List.from(obj['data'].map((e) => IMGroup.fromJson(e)));
      List<IMGroup> groups = context.read<IMStore>().groups;
      //过滤掉已添加的群
      List<IMGroup> filterList = list;
      if (groups.isNotEmpty) {
        for (var i = 0; i < list.length; i++) {
          var item = list[i];
          for (var user in groups) {
            if (user.groupId == item.groupId) {
              filterList.removeAt(i);
            }
          }
        }
      }
      list = filterList;
      callback(list);
    }
  }

  /// 删除某条系统消息
  static void removeSysMsgByMessageId(BuildContext context, String messageId) {
    final list = context.read<IMStore>().sysMessages;
    list.removeWhere((model) => (model.messageId == messageId));
    context.read<IMStore>().updateSysMessages(list);
  }

  /// 处理全部IM总数据或下拉刷新总数据（包括好友、会话、最后一条消息、未读数量）
  static void processTotalData(
      BuildContext context, String str, Callback<IMUserList> callback) {
    Map<String, dynamic> obj = json.decode(str);
    final model = IMUserList.fromJson(obj['data']);

    context.read<IMStore>().updateFirends(model.friendList ?? []);

    List<String> keyList = IMSPUtils.getIMKeys().toList();

    List<String> haveKeyList = [];

    for (int i = 0; i < (model.sessionList ?? []).length; i++) {
      IMChatModel chat = (model.sessionList ?? [])[i];
      if (chat.chatType == ChatType.groups) {
        String? groupId = chat.groupId;
        chat.gourp = (model.groupList ?? []).firstWhere((element) {
          return element.groupId == groupId;
        });
        chat.unreadMessageCount = chat.gourp?.unreadMessageCount ?? 0;
      }
      (model.sessionList ?? [])[i] = chat;

      switch (chat.chatType) {
        case ChatType.user:
          haveKeyList.add('im_${chat.userId}');
          break;
        case ChatType.groups:
          haveKeyList.add('im_group_${chat.groupId}');
          break;
        case ChatType.store:
          haveKeyList.add('im_store_${chat.storeId}');
          break;
      }
    }

    context.read<IMStore>().updateChats(model.sessionList ?? []);

    context.read<IMStore>().updateGroups(model.groupList ?? []);
    context.read<IMStore>().updateSysMessages(model.systemMessageList ?? []);

    for (int i = 0; i < keyList.length; i++) {
      String e = keyList[i];
      if (!haveKeyList.contains(e) &&
          e.startsWith('im_') &&
          !e.endsWith('list')) {
        IMSPUtils.removeByKey(e);
      }
    }
    IMUtils.setLastMessage(context);

    callback(model);
  }

  /// 处理从群用户服务器获取群信息以及判断是否需要添加到通讯录与会话列表中
  static void processGroupInfoAndAddToChatsAndFriends(
      BuildContext context, String str, Callback<IMGroup> callback) {
    Map<String, dynamic> obj = json.decode(str);
    final model = IMGroup.fromJson(obj['data']['groupInfo']);
    var data = obj['data'];
    if (data['userList'] != null) {
      List<IMUser>? userList =
          (data['userList'] as List).map((e) => IMUser.fromJson(e)).toList();
      model.userList = userList;
    }
    // 把组添加到通讯录中
    List<IMGroup> groups = context.read<IMStore>().groups;
    if (!groups.any((element) => element.groupId == model.groupId)) {
      groups.add(model);
      context.read<IMStore>().updateGroups(groups);
    }

    //把群组消息更新到会话中
    List<IMChatModel> chats = context.read<IMStore>().chats;
    var chat = IMChatModel(
      gourp: model,
      groupId: model.groupId,
      chatType: ChatType.groups,
      lastTalkAt: IMUtils.getTimestamp(),
    );
    if (!chats.any((element) => element.groupId == model.groupId)) {
      chats.add(chat);
      context.read<IMStore>().updateChats(chats);
    }
    IMUtils.setLastMessage(context);

    callback(model);
  }

  /// 更新会话以及通讯录中对应的群信息
  static void updateGroupInfoForChatsAndFriends(
      BuildContext context, IMGroup group) {
    // 更新群组信息
    List<IMGroup> groups = context.read<IMStore>().groups;
    int index = 0;
    for (var i = 0; i < groups.length; i++) {
      var item = groups[i];
      if (item.groupId == group.groupId) {
        index = i;
        break;
      }
    }
    groups[index] = group;
    context.read<IMStore>().updateGroups(groups);

    // 更新会话信息
    List<IMChatModel> chats = context.read<IMStore>().chats;
    int index1 = 0;
    for (var i = 0; i < chats.length; i++) {
      var item = chats[i];
      if (item.groupId == group.groupId) {
        index1 = i;
        break;
      }
    }
    chats[index1].gourp = group;
    context.read<IMStore>().updateChats(chats);
  }

  /// 保存聊天会话中最后一条消息
  static void saveLastMsg(ChatType type, String id, String? msg) {
    switch (type) {
      case ChatType.user:
        IMSPUtils.saveLastMsg(id, msg);
        break;
      case ChatType.groups:
        IMSPUtils.saveGroupLastMsg(id, msg);
        break;
      case ChatType.store:
        IMSPUtils.saveStoreLastMsg(id, msg);
        break;
    }
  }

  /// 保存当前聊天到会话列表中
  static void saveChat(BuildContext context, ChatType type, IMChatModel model) {
    List<IMChatModel> chats = context.read<IMStore>().chats;
    switch (type) {
      case ChatType.user:
        if (!chats.any((element) => element.userId == model.userId)) {
          chats.add(model);
          context.read<IMStore>().updateChats(chats);
        }
        break;
      case ChatType.groups:
        if (!chats.any((element) => element.groupId == model.groupId)) {
          chats.add(model);
          context.read<IMStore>().updateChats(chats);
        }
        break;
      case ChatType.store:
        if (!chats.any((element) => element.storeId == model.storeId)) {
          chats.add(model);
          context.read<IMStore>().updateChats(chats);
        }
        break;
    }
  }

  /// 处理消息撤回
  static void processRevokeMessage(BuildContext context, IMCommand event) {
    if (event.event == 'cnl') {
      switch (event.chatType) {
        case ChatType.user:
          IMMessage? msg = IMSPUtils.getLastMsg(event.msgData?.from);
          msg?.content = event.msgData?.content;
          // 保存最后一条信息到本地。
          IMUtils.saveLastMsg(
              ChatType.user, event.msgData!.from!, msg.toString());
          Map<String?, IMLastInfo> map =
              context.read<IMStore>().getLastInfo(event.chatType);
          map[event.msgData?.from]?.msg?.content = event.msgData?.content;
          context.read<IMStore>().updateLastInfo(event.chatType, map);
          break;
        case ChatType.groups:
          IMGroupMessage groupMsg = event.msgData as IMGroupMessage;
          IMGroupMessage? msg = IMSPUtils.getGroupLastMsg(groupMsg.groupId);
          msg?.content = event.msgData?.content;
          // 保存最后一条信息到本地。
          IMUtils.saveLastMsg(
              ChatType.groups, groupMsg.groupId!, msg.toString());
          Map<String?, IMLastInfo> map =
              context.read<IMStore>().getLastInfo(event.chatType);
          map[groupMsg.groupId]?.msg?.content = event.msgData?.content;
          context.read<IMStore>().updateLastInfo(event.chatType, map);
          break;
        case ChatType.store:
          IMStoreMessage storeMsg = event.msgData as IMStoreMessage;
          IMStoreMessage? msg = IMSPUtils.getStoreLastMsg(storeMsg.storeId);
          msg?.content = event.msgData?.content;
          // 保存最后一条信息到本地。
          IMUtils.saveLastMsg(
              ChatType.store, storeMsg.storeId!, msg.toString());
          Map<String?, IMLastInfo> map =
              context.read<IMStore>().getLastInfo(event.chatType);
          map[storeMsg.storeId]?.msg?.content = event.msgData?.content;
          context.read<IMStore>().updateLastInfo(event.chatType, map);
          break;
      }
    }
    // 设置最后一条消息
    IMUtils.setLastMessage(context);
  }

  /// 处理群组操作消息
  static void processGroupControlMessage(
      BuildContext context, IMGroupControl event) {
    /// 群变化
    if (event.module == 'group') {
      if (event.event == 'del') {
        IMUtils.deleteGroup(context, event.groupId.toString());
      }
    }

    /// 群成员变化
    if (event.module == 'groupUser') {
      if (event.event == 'add') {
        List<IMGroup> groups = context.read<IMStore>().groups;
        if (groups.any((element) => element.groupId == event.groupId)) {
          /// 本地存在这个群，说明更新的是别的群成员，而不是自己
          /// 更新会话列表中群组里的人员信息
          if (event.userList != null) {
            List<IMChatModel> chats = context.read<IMStore>().chats;
            for (int i = 0; i < chats.length; i++) {
              IMChatModel model = chats[i];
              if (model.groupId == event.groupId) {
                for (IMUser user in event.userList!) {
                  if (model.gourp!.userList != null) {
                    if (!model.gourp!.userList!
                        .any((element) => element.userId == user.userId)) {
                      model.gourp!.userList!.add(user);
                    }
                  } else {
                    model.gourp!.userList = [user];
                  }
                }
                chats[i] = model;
                context.read<IMStore>().updateChats(chats);
                break;
              }
            }

            /// 更新通讯录中群组里的人员信息
            for (int i = 0; i < groups.length; i++) {
              IMGroup group = groups[i];
              if (group.groupId == event.groupId) {
                for (IMUser user in event.userList!) {
                  if (group.userList != null) {
                    if (!group.userList!
                        .any((element) => element.userId == user.userId)) {
                      group.userList!.add(user);
                    }
                  } else {
                    group.userList = [user];
                  }
                }
                groups[i] = group;
                context.read<IMStore>().updateGroups(groups);
                break;
              }
            }
          }
        } else {
          /// 本地不存在这个群，说明更新群成员的是自己
          /// 读取群组详细信息
          YTIM().getGroupInfo(context, event.groupId!, 1, (value) {});
        }
      } else if (event.event == 'del') {
        if (event.userList != null) {
          if (event.userList!
              .any((element) => element.userId == YTIM().mUser.userId)) {
            IMUtils.deleteGroup(context, event.groupId.toString());
          } else {
            /// 更新会话列表中群组里的人员信息
            List<IMChatModel> chats = context.read<IMStore>().chats;
            for (int i = 0; i < chats.length; i++) {
              IMChatModel model = chats[i];
              if (model.groupId == event.groupId) {
                for (IMUser user in event.userList!) {
                  model.gourp!.userList!
                      .removeWhere((element) => element.userId == user.userId);
                }
                chats[i] = model;
                context.read<IMStore>().updateChats(chats);
                break;
              }
            }

            /// 更新通讯录中群组里的人员信息
            List<IMGroup> groups = context.read<IMStore>().groups;
            for (int i = 0; i < groups.length; i++) {
              IMGroup group = groups[i];
              if (group.groupId == event.groupId) {
                for (IMUser user in event.userList!) {
                  group.userList!
                      .removeWhere((element) => element.userId == user.userId);
                }
                groups[i] = group;
                context.read<IMStore>().updateGroups(groups);
                break;
              }
            }
          }
        }
      }
    }
  }

  /// 处理系统消息
  static void processSysMessage(BuildContext context, IMSysMessage event) {
    /// 收到好友删除的消息，删除好友，把好友从会话，通讯录，最后一条消息的数据删除
    if (event.event == 'del') {
      IMUtils.deleteFriend(context, event.from!);
    }

    /// 收到请求添加好友的消息
    if (event.event == 'add') {
      IMUtils.addSysMessage(context, event);
    }

    // 收到同意请求添加好友的消息
    if (event.event == 'set') {
      IMUtils.addFriend(context, event);
      IMUtils.addSysMessage(context, event);
    }

    /// 收到拒绝请求添加好友的消息
    if (event.event == 'ref') {
      IMUtils.addSysMessage(context, event);
    }
  }

  /// 处理聊天消息
  static void processChatMessage(
      BuildContext context, IMBaseMessage chatMessage) {
    switch (chatMessage.chatType) {
      case ChatType.user:
        IMMessage event = chatMessage as IMMessage;
        // 保存最后一条信息到本地。
        IMUtils.saveLastMsg(
            chatMessage.chatType, event.from!, event.toString());

        Map<String?, IMLastInfo> map =
            context.read<IMStore>().getLastInfo(chatMessage.chatType);
        if (!IMSPUtils.getMuteList().contains(event.from)) {
          //判定免打扰
          if (map.keys.contains(event.from)) {
            if (YTIM().currentChatUserId != event.from) {
              map[event.from]?.unreadCount += 1;
            }
            map[event.from]!.msg = event;
          } else {
            if (event.from != YTIM().mUser.userId) {
              map[event.from] = IMLastInfo(
                  msg: event,
                  unreadCount: YTIM().currentChatUserId != event.from ? 1 : 0);
            }
          }
        }
        context.read<IMStore>().updateLastInfo(chatMessage.chatType, map);

        //消息更新到会话中
        List<IMChatModel> chats = context.read<IMStore>().chats;
        bool isChats = false;
        for (var item in chats) {
          if (item.userId == event.from) {
            isChats = true;
            if (YTIM().currentChatUserId != event.from) {
              if (item.unreadMessageList != null) {
                item.unreadMessageList!.add(event);
              } else {
                item.unreadMessageList = [event];
              }
              item.unreadMessageCount = item.unreadMessageCount != null
                  ? item.unreadMessageCount! + 1
                  : 1;
            }
            break;
          }
        }
        if (!isChats) {
          List<IMUser> friends = context.read<IMStore>().firends;
          IMUser? user;
          for (IMUser u in friends) {
            if (u.userId == event.from) {
              user = u;
              break;
            }
          }

          var chat = IMChatModel(
            userInfo: user,
            userId: event.from,
            chatType: ChatType.user,
            lastTalkAt: IMUtils.getTimestamp(),
          );
          chats.add(chat);
        }

        context.read<IMStore>().updateChats(chats);
        break;
      case ChatType.groups:
        IMGroupMessage event = chatMessage as IMGroupMessage;
        // 保存最后一条信息到本地。
        IMUtils.saveLastMsg(
            chatMessage.chatType, event.groupId!, event.toString());

        Map<String?, IMLastInfo> map =
            context.read<IMStore>().getLastInfo(chatMessage.chatType);
        if (!IMSPUtils.getGroupMuteList().contains(event.groupId)) {
          //判断不在免打扰中
          if (map.keys.contains(event.groupId)) {
            if (YTIM().currentGroupId != event.groupId) {
              map[event.groupId]!.unreadCount += 1;
            }
            map[event.groupId]!.msg = event;
          } else {
            map[event.groupId] = IMLastInfo(
                msg: event,
                unreadCount: YTIM().currentGroupId != event.groupId ? 1 : 0);
          }
        }
        context.read<IMStore>().updateLastInfo(chatMessage.chatType, map);

        //消息更新到会话中
        List<IMChatModel> chats = context.read<IMStore>().chats;

        bool isChats = false;
        for (var item in chats) {
          if (item.groupId == event.groupId) {
            isChats = true;
            if (YTIM().currentGroupId != event.groupId) {
              item.unreadMessageCount = item.unreadMessageCount != null
                  ? item.unreadMessageCount! + 1
                  : 1;
            }
            break;
          }
        }
        if (!isChats) {
          List<IMGroup> groups = context.read<IMStore>().groups;

          IMGroup? group;
          for (IMGroup g in groups) {
            if (g.groupId == event.groupId) {
              group = g;
              break;
            }
          }

          var chat = IMChatModel(
            groupId: event.groupId,
            gourp: group,
            chatType: ChatType.groups,
            lastTalkAt: IMUtils.getTimestamp(),
          );
          chats.add(chat);
        }

        context.read<IMStore>().updateChats(chats);
        break;
      case ChatType.store:
        IMStoreMessage event = chatMessage as IMStoreMessage;
        // 保存最后一条信息到本地。
        IMUtils.saveLastMsg(
            chatMessage.chatType, event.storeId!, event.toString());

        // 更新全局IM信息。
        Map<String?, IMLastInfo> map =
            context.read<IMStore>().getLastInfo(chatMessage.chatType);
        if (!IMSPUtils.getStoreMuteList().contains(event.storeId)) {
          //判断是否免打扰
          if (map.keys.contains(event.storeId)) {
            if (YTIM().currentStoreId != event.storeId) {
              map[event.storeId]!.unreadCount += 1;
            }
            map[event.storeId]!.msg = event;
          } else {
            map[event.from] = IMLastInfo(
                msg: event,
                unreadCount: YTIM().currentStoreId != event.storeId ? 1 : 0);
          }
        }
        context.read<IMStore>().updateLastInfo(chatMessage.chatType, map);

        //消息更新到会话中
        List<IMChatModel> chats = context.read<IMStore>().chats;

        bool isChats = false;
        for (var item in chats) {
          if (item.storeId == event.storeId) {
            isChats = true;
            item.unreadMessageCount = item.unreadMessageCount != null
                ? item.unreadMessageCount! + 1
                : 1;
            break;
          }
        }
        if (!isChats) {
          var chat = IMChatModel(
            storeId: event.storeId,
            store: event.store,
            chatType: ChatType.store,
            lastTalkAt: IMUtils.getTimestamp(),
          );
          chats.add(chat);
        }

        context.read<IMStore>().updateChats(chats);
        break;
    }
    // 设置最后一条消息
    IMUtils.setLastMessage(context);
  }

  /// 获取最后一条消息，用于展示列表
  static Map<String?, IMLastInfo> getLastInfo(BuildContext context,ChatType chatType){
    return context.read<IMStore>().getLastInfo(chatType);
  }

  /// 清除某个会话的未读数量
  static void clearSingleChatUnreadCount(
      BuildContext context, ChatType chatType, String id) {
    Map<String?, IMLastInfo> map =
        context.read<IMStore>().getLastInfo(chatType);
    if (map.keys.contains(id)) {
      map[id]!.unreadCount = 0;
      context.read<IMStore>().updateLastInfo(chatType, map);
    }

    //未读数据 chat模型 本地也计算了
    List<IMChatModel> chats = context.read<IMStore>().chats;
    for (int i = 0; i < chats.length; i++) {
      IMChatModel chat = chats[i];
      if (chat.userId == id || chat.groupId == id || chat.storeId == id) {
        chat.unreadMessageList = [];
        chat.unreadMessageCount = 0;
        chats[i] = chat;
      }
      context.read<IMStore>().updateChats(chats);
    }
    IMUtils.updateUnreadCount(context);
  }
}
