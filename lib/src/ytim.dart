import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/utils/im_sp_utils.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 连接状态
enum IMConnectState {
  /// 初始化状态
  idle,

  /// 连接中
  connecting,

  /// 已连接
  connected,

  /// 无网络
  networkNone
}

/// 发送消息状态
enum IMMessageSendState {
  /// 发送中
  sending,

  /// 发送失败
  sendError,

  /// 发送成功
  sendSuccess
}

/// 聊天分类
enum ChatType {
  /// 群组
  groups,

  /// 单聊
  user,

  /// 店铺客服
  store,
}

/// 设置消息已读
enum MessageTypeRead {
  /// 系统消息
  sysMsg,

  /// 单聊消息
  chatMsg,

  /// 群组消息
  groupMsg,

  /// 店铺客服消息
  storeMsg
}

typedef Callback<T> = void Function(T value);

typedef SendMessageCallback<T> = void Function(
    T value, IMMessageSendState status);

typedef FailCallback<T> = void Function(T error);

/// 被踢下线回调
typedef KickOutCallback = void Function();

/// YTIM 核心类
class YTIM {
  ///########################################私有属性、方法#################################################

  final String _tag = 'IM';
  static YTIM? _singleton;

  /// 重新连接计数器
  int _reconnectCount = 1;

  /// 记录请回调队列到本地
  Map<String, Completer<String>> _pendingRequests = {};

  /// 自己的用户信息
  late IMUser mUser;

  /// 连接状态管理
  IMConnectState _connectState = IMConnectState.idle;

  /// websocket 连接管理句柄
  IOWebSocketChannel? _channel;

  /// 私有构造方法
  YTIM._instance() {}

  /// 连接IM服务器
  void _connectServer() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (networkErrorCallback != null) {
        networkErrorCallback!();
      }
      YTLog.d(_tag, '网络错误');
      return;
    }
    if (_connectState == IMConnectState.idle) {
      _connectState = IMConnectState.connecting;
      YTLog.d(_tag, '连接socket地址: $websocketUrl');
      _channel = IOWebSocketChannel.connect(websocketUrl);
      _channel!.stream.listen(
        _handleMassage,
        onError: (err) {
          YTLog.d(_tag, 'IM出错：${(err as WebSocketChannelException).message}');
          onConnectErrorCallback(err);
        },
        onDone: () {
          YTLog.d(_tag, 'IM断开：${_channel?.closeReason}');
          _connectState = IMConnectState.idle;
          if (connectLoseCallback != null) {
            connectLoseCallback!();
          }
          if (needReconnect) {
            if (_reconnectCount > 6) {
              YTLog.d(_tag, 'IM彻底断开：已重连超过5次');
              if (reconnectFailCallback != null) {
                reconnectFailCallback!();
              }
              return;
            }
            if (reconnectCountCallback != null) {
              reconnectCountCallback!(_reconnectCount);
            }
            _reconnectCount++;
            _connectServer();
          }
        },
        cancelOnError: false,
      );
    }
  }

  /// 登陆IM
  void _loginIM() {
    YTLog.d(_tag, 'IM login');
    Map? map = YTIMApi.loginApi();
    map?['token'] = loginToken;
    String? url = json.encode(map);
    YTLog.d(_tag, url);
    _sendMessageAndReceive(url).then((message) {
      _reconnectCount = 1;
      Map<String, dynamic> obj = json.decode(message);
      mUser = IMUser.fromJson(obj['data']);
      imLoginSuccessCallback(mUser);
    }).onError((error, stackTrace) {
      YTLog.d(_tag, error);
      if (error != null) {
        final res = error as Map<String, dynamic>;
        if (res['code'] == 412) {
          // token失效 刷新token
          loginFailCallback(412);
        }
        if (res['code'] == 4002) {
          // 解决账号删除导致IM登录不上，刷新token一直循环请求问题，退出登录
          loginFailCallback(4002);
        }
      }
    });
  }

  /// 处理接收消息
  _handleMassage(message) {
    YTLog.d(_tag, '<-- message:$message');
    Map<String, dynamic> obj = json.decode(message);
    if (obj['action'] == 'ack') {
      //处理服务器请求回应的消息
      try {
        //UUID 为标记请求的requestID
        final requestId = obj['uuid'].toString();
        if (requestId != "null") {
          final completer =
              _pendingRequests.remove(requestId); //取出对应回调队列 并删除队列数据源防止数据泄漏
          if (completer != null) {
            if (obj['code'] == 200) {
              completer.complete(message);
            } else {
              if (obj['code'] != 412) {
                loginFailCallback(412);
              }
              completer.completeError(
                  {'code': obj['code'], 'uuid': obj['uuid'].toString()});
            }
          }
        }
      } catch (e) {
        YTLog.d('IM请求消息', '错误处理响应: $e');
      }
    } else if (obj['action'] == 'put') {
      //处理服务器主动发来的消息
      _putHandleMassage(obj);
    }
  }

  _putHandleMassage(Map<String, dynamic> obj) {
    switch (obj['module']) {
      case 'connect':
        YTLog.d(_tag, 'connect success');
        _connectState = IMConnectState.connected;
        _loginIM();
        break;
      case 'kickOut':
        // 如果帐号已经在其它端登录，退出执行重新登陆
        if (kickOutCallback != null) {
          kickOutCallback!();
        }
        release();
        break;
      case 'message':
        if (obj['event'] == 'add') {
          //收到新消息
          IMMessage msg = IMMessage.fromJson(obj['data'], ChatType.user);
          if (msg.from != null) {
            if (IMSPUtils.getBlockList().contains(msg.from)) {
              YTLog.d(_tag, ' ${msg.from}:${msg.fromName} 在屏蔽列表中，忽略此消息');
              // 直接返回已读指令，不然会刷新到对方的未读消息。
              _sendMessageAndReceive(YTIMApi.readMessageApi(msg.from!))
                  .then((value) {});
            } else {
              if (msg.to == null || msg.to == '') {
                //收到的消息 返回值不带to
                msg.to = mUser.userId;
              }
              chatMessageCallback(msg);
            }
          }
        } else if (obj['event'] == "cnl") {
          //撤回消息 消息已撤回
          revokeMsgCallback(IMCommand.fromJson(obj, ChatType.user));
        } else if (obj['event'] == 'set') {
          //消息已读
          if (readMsgCallback != null) {
            readMsgCallback!(IMCommand.fromJson(obj, ChatType.user));
          }
        }
        break;
      case 'groupMessage':
        if (obj['event'] == 'add') {
          //收到新群组消息
          IMGroupMessage msg =
              IMGroupMessage.fromJson(obj['data'], ChatType.groups);
          if (msg.groupId != null) {
            chatMessageCallback(msg);
          }
        } else if (obj['event'] == "cnl") {
          //撤回消息 消息已撤回
          revokeMsgCallback(IMCommand.fromJson(obj, ChatType.groups));
        }
        break;
      case 'storeMessage':
        if (obj['event'] == 'add') {
          //收到新群组消息
          IMStoreMessage msg =
              IMStoreMessage.fromJson(obj['data'], ChatType.store);
          if (msg.storeId != null) {
            chatMessageCallback(msg);
          }
        } else if (obj['event'] == "cnl") {
          //撤回消息 消息已撤回
          revokeMsgCallback(IMCommand.fromJson(obj, ChatType.store));
        } else if (obj['event'] == 'set') {
          //消息已读
          if (readMsgCallback != null) {
            readMsgCallback!(IMCommand.fromJson(obj, ChatType.store));
          }
        }
        break;
      case 'friend':

        /// 收到好友添加请求
        if (obj['event'] == 'add') {
          IMSysMessage msg = IMSysMessage.fromJson(obj['data']);
          msg.event = 'add';
          sysMsgCallback(msg);
        }
        // 同意
        if (obj['event'] == 'set') {
          IMSysMessage msg = IMSysMessage.fromJson(obj['data']);
          msg.event = 'set';
          sysMsgCallback(msg);
        }
        //拒绝
        if (obj['event'] == 'ref') {
          IMSysMessage msg = IMSysMessage.fromJson(obj['data']);
          msg.event = 'ref';
          sysMsgCallback(msg);
        }
        // 删除
        if (obj['event'] == 'del') {
          IMSysMessage msg = IMSysMessage.fromJson(obj['data']);
          msg.event = 'del';
          sysMsgCallback(msg);
        }
        break;
      case 'groupUser':

        /// 邀请加入群聊
        if (obj['event'] == 'add') {
          IMGroupControl msg = IMGroupControl.fromJson(obj['data']);
          msg.module = 'groupUser';
          msg.event = 'add';
          groupControlCallback(msg);
        }

        /// 群成员退出或者被踢出
        if (obj['event'] == 'del') {
          IMGroupControl msg = IMGroupControl.fromJson(obj['data']);
          msg.module = 'groupUser';
          msg.event = 'del';
          groupControlCallback(msg);
        }
        break;
      case 'group':

        /// 群聊解散
        if (obj['event'] == 'del') {
          IMGroupControl msg = IMGroupControl.fromJson(obj['data']);
          msg.module = 'group';
          msg.event = 'del';
          groupControlCallback(msg);
        }
        break;
      case 'joinGroup':

        /// 收到申请入群通知
        if (obj['event'] == 'set') {
          IMSysMessage msg = IMSysMessage.fromJson(obj['data']);
          msg.event = 'add';
          sysMsgCallback(msg);
        }

        /// 同意入群的通知
        if (obj['event'] == 'add') {
          IMSysMessage msg = IMSysMessage.fromJson(obj['data']);
          msg.event = 'add';
          sysMsgCallback(msg);

          IMGroupControl msg1 = IMGroupControl.fromJson(obj['data']);
          msg1.module = 'groupUser';
          msg1.event = 'add';
          groupControlCallback(msg1);
        }

        /// 拒绝入群的通知
        if (obj['event'] == 'ref') {
          IMSysMessage msg = IMSysMessage.fromJson(obj['data']);
          msg.event = 'ref';
          sysMsgCallback(msg);
        }
        break;
      default:
    }
  }

  /// 发送请求到服务器
  Future<String> _sendMessageAndReceive(String command, {String? uuid}) async {
    //发出请求
    var requestId = IMUtils.getTimestamp();

    if (_pendingRequests[requestId] != null) {
      var now = DateTime.now();
      now = now.add(const Duration(seconds: 1));
      requestId = now.millisecondsSinceEpoch.toString();
    }
    final map = jsonDecode(command);
    map['uuid'] = uuid ?? requestId;
    final body = json.encode(map);
    YTLog.d(_tag, '--> message:$body');

    _channel?.sink.add(body);

    // 使用Completer等待响应
    final completer = Completer<String>();
    _pendingRequests[uuid ?? requestId] = completer; //记录到本地数据源 接收到请求回调后使用

    // 设置超时，防止长时间没有响应导致死锁
    Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        completer.completeError('请求超时');
      }
    });

    return completer.future;
  }

  ///########################################公有方法、外部调用#################################################

  /// 登录IM需要的token
  late String loginToken;

  /// 登录IM的地址
  late String websocketUrl;

  /// 连接错误的回调
  late Callback<WebSocketChannelException> onConnectErrorCallback;

  /// IM登录成功的回调，返回用户信息
  late Callback<IMUser> imLoginSuccessCallback;

  /// 登录失败的回调----412--token失效，4002--账号被删除
  late Callback<int> loginFailCallback;

  /// 未读消息数量的回调
  Callback<int>? unreadCountCallback;

  /// IM踢出用户回调
  KickOutCallback? kickOutCallback;

  /// 重连次数的回掉
  Callback<int>? reconnectCountCallback;

  /// 重连失败的回调
  void Function()? reconnectFailCallback;

  /// 网络错误的回调
  void Function()? networkErrorCallback;

  /// 连接中断的回调
  void Function()? connectLoseCallback;

  /// 消息已读的回调
  Callback<IMCommand>? readMsgCallback;

  /// 消息撤回的回调
  late Callback<IMCommand> revokeMsgCallback;

  /// 系统消息的回调
  late Callback<IMSysMessage> sysMsgCallback;

  /// 群操作消息的回调
  late Callback<IMGroupControl> groupControlCallback;

  /// 聊天消息的回调
  late Callback<IMBaseMessage> chatMessageCallback;

  /// 是否需要重连
  bool needReconnect = true;

  /// 是否开启log
  bool logEnabled = false;

  /// 当前正在与之聊天的用户id。
  String currentChatUserId = '';
  String currentGroupId = '';
  String currentStoreId = '';

  /// 工厂方法
  factory YTIM() {
    if (_singleton == null) {
      _singleton = YTIM._instance();
      IMSPUtils.init();
    }
    return _singleton!;
  }

  /// IM初始化。
  void init({
    required String loginToken,
    required String websocketUrl,
    required Callback<WebSocketChannelException> onConnectErrorCallback,
    required Callback<IMUser> imLoginSuccessCallback,
    required Callback<int> loginFailCallback,
    required Callback<IMCommand> revokeMsgCallback,
    required Callback<IMSysMessage> sysMsgCallback,
    required Callback<IMGroupControl> groupControlCallback,
    required Callback<IMBaseMessage> chatMessageCallback,
    Callback<int>? reconnectCountCallback,
    void Function()? reconnectFailCallback,
    void Function()? networkErrorCallback,
    void Function()? connectLoseCallback,
    bool? needReconnect,
    bool? logEnabled,
  }) {
    YTLog.d(_tag, 'IM.init');

    this.loginToken = loginToken;
    this.websocketUrl = websocketUrl;
    this.onConnectErrorCallback = onConnectErrorCallback;
    this.imLoginSuccessCallback = imLoginSuccessCallback;
    this.loginFailCallback = loginFailCallback;
    this.revokeMsgCallback = revokeMsgCallback;
    this.sysMsgCallback = sysMsgCallback;
    this.groupControlCallback = groupControlCallback;
    this.chatMessageCallback = chatMessageCallback;
    this.reconnectCountCallback = reconnectCountCallback;
    this.reconnectFailCallback = reconnectFailCallback;
    this.networkErrorCallback = networkErrorCallback;
    this.connectLoseCallback = connectLoseCallback;
    this.needReconnect = needReconnect ?? true;
    this.logEnabled = logEnabled ?? false;

    _connectServer();
    // 网络监听
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      YTLog.d(_tag, '网络状态变化：$result');
      _connectServer();
    });
  }

  /// 添加被踢出回调
  void addKickOutCallback(KickOutCallback callback) {
    kickOutCallback = callback;
  }

  /// 添加未读数量的回调
  void addUnreadCountCallback(Callback<int> callback) {
    unreadCountCallback = callback;
  }

  /// 添加消息已读的回调
  void addMsgReadCallback(Callback<IMCommand> callback) {
    readMsgCallback = callback;
  }

  /// 获取IM总数据，包括会话、好友、群组、系统消息
  /// 成功回调中返回全部数据 类型为IMUserList
  /// 失败回调中返回error 类型为Map
  void getIMTotalData(BuildContext context, Callback<IMUserList> resultCallback,
      FailCallback<Map> failCallback) async {
    _sendMessageAndReceive(YTIMApi.getTotalListApi()).then((value) {
      IMUtils.processTotalData(context, value, (value) {
        resultCallback(value);
      });
    }).onError<Map>((error, stackTrace) {
      failCallback(error);
    });
  }

  /// 获取某个会话的聊天记录
  /// chatType 会话类型
  /// id  用户ID、群组ID、店铺ID
  /// nextTime 获取截止时间 可为空，为空表示获取最近的
  /// 成功回调 数据格式为 IMHistoryMsgList
  void getChatHistoryMessage(ChatType chatType, String id, String? nextTime,
      Callback<IMHistoryMsgList> resultCallback) async {
    switch (chatType) {
      case ChatType.user:
        _sendMessageAndReceive(YTIMApi.historyMessageApi(id, nextTime))
            .then((value) {
          Map<String, dynamic> obj = json.decode(value);
          final model = IMHistoryMsgList.fromJson(obj['data'], ChatType.user);
          List<IMBaseMessage> msgList = model.messageList ?? [];
          msgList.sort((a, b) => b.time!.compareTo(a.time!));
          model.messageList = msgList;
          resultCallback(model);
        });
        break;
      case ChatType.groups:
        _sendMessageAndReceive(YTIMApi.getGroupMessageListApi(id, nextTime))
            .then((value) {
          Map<String, dynamic> obj = json.decode(value);
          final model = IMHistoryMsgList.fromJson(obj['data'], ChatType.groups);
          List<IMBaseMessage> msgList = model.messageList ?? [];
          msgList.sort((a, b) => b.time!.compareTo(a.time!));
          model.messageList = msgList;
          resultCallback(model);
        });
        break;
      case ChatType.store:
        _sendMessageAndReceive(YTIMApi.historyStoreMessageApi(id, nextTime))
            .then((value) {
          Map<String, dynamic> obj = json.decode(value);
          final model = IMHistoryMsgList.fromJson(obj['data'], ChatType.store);
          List<IMBaseMessage> msgList = model.messageList ?? [];
          msgList.sort((a, b) => b.time!.compareTo(a.time!));
          model.messageList = msgList;
          resultCallback(model);
        });
        break;
    }
  }

  /// 创建群组
  /// name 群组名称
  /// headUrl 头像URL
  /// desc 群描述 可为空
  /// 成功回调中返回 IMGroup
  void createGroup(String name, String headUrl,
      Callback<IMGroup> resultCallback, FailCallback<Map> failCallback,
      {String? desc}) async {
    _sendMessageAndReceive(YTIMApi.creatGroupApi(name, headUrl, desc: desc))
        .then((value) {
      Map<String, dynamic> creatGroupObj = json.decode(value);
      if (creatGroupObj['code'] == 200) {
        final model = IMGroup.fromJson(creatGroupObj['data']);
        resultCallback(model);
      } else {
        failCallback({});
      }
    }).onError<Map>((error, stackTrace) {
      failCallback(error);
    });
  }

  /// 设置群信息
  /// group 群数据
  /// name 群名称
  /// headUrl 群头像URL
  /// desc 群描述 可为空
  /// 成功回调中返回 IMGroup
  void setGroupInfo(
      BuildContext context,
      IMGroup group,
      String name,
      String headUrl,
      Callback<IMGroup> resultCallback,
      FailCallback<Map> failCallback,
      {String? desc}) async {
    _sendMessageAndReceive(YTIMApi.setGroupDataApi(
      group.groupId!,
      name,
      headUrl,
      desc: desc,
    )).then((value) {
      Map<String, dynamic> obj = json.decode(value);
      if (obj['code'] == 200) {
        // 修改成功
        group.name = obj['data']['data']['name'];
        group.avatar = obj['data']['data']['avatar'];
        group.desc = obj['data']['data']['desc'];

        IMUtils.updateGroupInfoForChatsAndFriends(context, group);

        resultCallback(group);
      } else {
        failCallback({});
      }
    }).onError<Map>((error, stackTrace) {
      failCallback(error);
    });
  }

  /// 删除或者退出群组
  /// groupID 群ID
  /// type 0----删除  1---退出
  /// 成功回调中返回 json str
  void deleteOrExitGroup(
      String groupId, int type, Callback<String> resultCallback) {
    if (type == 0) {
      _sendMessageAndReceive(YTIMApi.deleteGroupApi(groupId.toString()))
          .then((value) => resultCallback(value));
    } else {
      _sendMessageAndReceive(YTIMApi.exitGroupApi(groupId.toString()))
          .then((value) => resultCallback(value));
    }
  }

  /// 群成员操作
  /// groupId 群ID
  /// userIds 用户ID列表
  /// type 0--添加  1--删除
  /// 成功回调中返回json string
  void groupUsersOperations(String groupId, List<String> userIds, int type,
      Callback<String> resultCallback) async {
    if (type == 0) {
      _sendMessageAndReceive(YTIMApi.setGroupUsersApi(groupId, userIds))
          .then((value) => resultCallback(value));
    } else {
      _sendMessageAndReceive(YTIMApi.deleteGroupUserApi(groupId, userIds))
          .then((value) => resultCallback(value));
    }
  }

  /// 获取群数据
  /// groupId 群ID
  /// getGroupUser 表示是否取群用户，请灵活运用
  /// 成功回调中返回 IMGroup
  void getGroupInfo(BuildContext context, String groupId, int getGroupUser,
      Callback<IMGroup> resultCallback) async {
    _sendMessageAndReceive(
            YTIMApi.getGroupDataApi(groupId, getGroupUser: getGroupUser))
        .then((value) {
      IMUtils.processGroupInfoAndAddToChatsAndFriends(context, value, (value) {
        resultCallback(value);
      });
    });
  }

  /// 发送聊天消息
  /// chatType  会话类型
  /// userid    用户ID/群组ID
  /// content   内容
  /// contentType 内容类型 1文本 2图片 3语音文件 4视频文件 5其他文件 6地图
  /// 成功回调中返回数据 类型为json string
  /// 失败回调中返回error 类型为Map
  void sendChatMessage(
      ChatType chatType,
      String userId,
      String content,
      String contentType,
      String uuid,
      Callback<String> resultCallback,
      FailCallback<Map> failCallback,
      {String? userName}) async {
    switch (chatType) {
      case ChatType.user:
        _sendMessageAndReceive(
                YTIMApi.sendMessage(userId, userName, content, contentType),
                uuid: uuid)
            .then((value) => resultCallback(value))
            .onError<Map>((error, stackTrace) => failCallback(error));
        break;
      case ChatType.groups:
        _sendMessageAndReceive(
                YTIMApi.sendGroupMessageApi(userId, contentType, content),
                uuid: uuid)
            .then((value) => resultCallback(value))
            .onError<Map>((error, stackTrace) => failCallback(error));
        break;
      case ChatType.store:
        _sendMessageAndReceive(
                YTIMApi.sendStoreMessage(userId, content, contentType),
                uuid: uuid)
            .then((value) => resultCallback(value))
            .onError<Map>((error, stackTrace) => failCallback(error));
        break;
      default:
        break;
    }
  }

  /// 搜索好友
  /// keyword 关键词
  /// 成功回调中返回数据 类型为List<IMUser>
  void searchFriend(String keyword, BuildContext context,
      Callback<List<IMUser>> resultCallback) async {
    _sendMessageAndReceive(YTIMApi.searchFriendApi(keyword)).then((value) {
      IMUtils.filterFriends(context, value, (value) {
        resultCallback(value);
      });
    });
  }

  /// 添加好友
  /// userid 好友ID
  /// 成功回调中返回数据 类型为json string
  void addFriend(String userid, Callback<String> resultCallback) async {
    _sendMessageAndReceive(YTIMApi.addFriendApi(userid))
        .then((value) => resultCallback(value));
  }

  /// 删除好友
  /// userid 用户ID
  /// status 0删除 1双方同时删除
  /// 成功回调中返回数据 类型为json string
  void deleteFriend(BuildContext context, String userId, String status,
      Callback<String> resultCallback) async {
    _sendMessageAndReceive(YTIMApi.deleteFriendApi(userId, status))
        .then((value) {
      resultCallback(value);
    });
  }

  /// 获取用户信息
  /// userid 用户ID
  /// 成功回调中返回数据 类型为IMUser
  void getUserInfoByUserId(
      String userId, Callback<IMUser> resultCallback) async {
    _sendMessageAndReceive(YTIMApi.getUserDataApi(userId)).then((value) {
      Map<String, dynamic> obj = json.decode(value);
      var data = obj['data'];
      if (obj['code'] == 200) {
        resultCallback(IMUser.fromJson(data));
      }
    });
  }

  /// 搜索群
  /// keyword 关键词
  /// 成功回调中返回数据 类型为List<IMGroup>
  void searchGroup(String keyword, BuildContext context,
      Callback<List<IMGroup>> resultCallback) async {
    _sendMessageAndReceive(YTIMApi.searchGroupApi(keyword)).then((value) {
      IMUtils.filterGroups(context, value, (value) {
        resultCallback(value);
      });
    });
  }

  /// 申请入群
  /// groupId 群ID
  /// 成功回调中返回数据 类型为json string
  void addGroup(String groupId, Callback<String> resultCallback) async {
    _sendMessageAndReceive(YTIMApi.joinGroupApi(groupId))
        .then((value) => resultCallback(value));
  }

  /// 设置好友备注
  /// userId 用户ID
  /// nickName  昵称
  /// 成功回调中返回数据 类型为json string
  void setFriendNickName(
      String userId, String? nickName, Callback<String> resultCallback) async {
    _sendMessageAndReceive(YTIMApi.setFriendNickNameApi(
      userId,
      nickname: nickName,
    )).then((value) => resultCallback(value));
  }

  /// 设置消息已读
  /// messageType 消息类型
  /// id 消息ID 或者是用户ID
  /// 成功回调中返回数据 类型为json string
  void setMessageRead(MessageTypeRead typeRead, String id,
      Callback<String> resultCallback) async {
    switch (typeRead) {
      case MessageTypeRead.sysMsg:
        _sendMessageAndReceive(YTIMApi.readSysMessageApi(id))
            .then((value) => resultCallback(value));
        break;
      case MessageTypeRead.chatMsg:
        _sendMessageAndReceive(YTIMApi.readMessageApi(id))
            .then((value) => resultCallback(value));
        break;
      case MessageTypeRead.groupMsg:
        _sendMessageAndReceive(YTIMApi.readGroupMessageApi(id))
            .then((value) => resultCallback(value));
        break;
      case MessageTypeRead.storeMsg:
        _sendMessageAndReceive(YTIMApi.sendStoreReadMessage(id))
            .then((value) => resultCallback(value));
        break;
    }
  }

  /// 撤回消息
  /// chatType 会话类型
  /// id 对应的用户ID、群组ID、店铺ID
  /// timestamp 该消息的时间戳
  /// 成功回调中返回 IMCommand
  void revokeMessage(ChatType chatType, String id, String timestamp,
      Callback<IMCommand> resultCallback) async {
    switch (chatType) {
      case ChatType.user:
        _sendMessageAndReceive(YTIMApi.revokeMessageApi(id, timestamp))
            .then((value) {
          Map<String, dynamic> obj = json.decode(value);
          //消息撤回成功
          IMCommand msg = IMCommand.fromJson(obj, ChatType.user);
          resultCallback(msg);
        });
        break;
      case ChatType.groups:
        _sendMessageAndReceive(YTIMApi.revokeGroupMessageApi(id, timestamp))
            .then((value) {
          Map<String, dynamic> obj = json.decode(value);
          //消息撤回成功
          IMCommand msg = IMCommand.fromJson(obj, ChatType.groups);
          resultCallback(msg);
        });
        break;
      case ChatType.store:
        _sendMessageAndReceive(YTIMApi.revokeStoreMessageApi(id, timestamp))
            .then((value) {
          Map<String, dynamic> obj = json.decode(value);
          //消息撤回成功
          IMCommand msg = IMCommand.fromJson(obj, ChatType.store);
          resultCallback(msg);
        });
        break;
    }
  }

  /// 同意或者拒绝好友请求
  /// userId 用户ID
  /// type 0---拒绝  1---同意
  /// nickName 好友备注，可空，同意好友申请时，可能有值
  /// 成功回调中返回数据 类型为json string
  /// 失败回调中返回error 类型为Map
  void operationFriendRequest(String userId, int type,
      Callback<String> resultCallback, FailCallback<Map> failCallback,
      {String? nickName}) async {
    if (type == 1) {
      _sendMessageAndReceive(YTIMApi.agreeFriendAddApi(userId, name: nickName))
          .then((value) => resultCallback(value))
          .onError<Map>((error, stackTrace) => failCallback(error));
    } else {
      _sendMessageAndReceive(YTIMApi.rejectFriendAddApi(userId))
          .then((value) => resultCallback(value))
          .onError<Map>((error, stackTrace) => failCallback(error));
    }
  }

  /// 同意或者拒绝用户入群
  /// groupId 群ID
  /// messageId 系统消息ID
  /// type 0---拒绝  1---同意
  /// 成功回调中返回数据 类型为json string
  /// 失败回调中返回error 类型为Map
  void operationGroupRequest(String groupId, String messageId, int type,
      Callback<String> resultCallback, FailCallback<Map> failCallback) async {
    if (type == 1) {
      _sendMessageAndReceive(YTIMApi.agreeJoinGroupApi(groupId, messageId))
          .then((value) => resultCallback(value))
          .onError<Map>((error, stackTrace) => failCallback(error));
    } else {
      _sendMessageAndReceive(YTIMApi.rejectJoinGroupApi(groupId, messageId))
          .then((value) => resultCallback(value))
          .onError<Map>((error, stackTrace) => failCallback(error));
    }
  }

  /// 检查连接状态，应用生命周期方法中调用，在应用重新回到前台调度中调用以重连IM
  void checkConnectStatus() {
    if (_connectState == IMConnectState.idle) {
      _connectServer();
    } else if (_connectState == IMConnectState.idle) {
    } else if (_connectState == IMConnectState.idle) {
      YTLog.d(_tag, 'IM连接状态：$_connectState');
    }
  }

  /// 释放IM连接
  release() {
    YTLog.d(_tag, 'IM.release');
    mUser = IMUser();
    _connectState = IMConnectState.idle;
    needReconnect = false;
    _channel?.sink.close();
  }
}
