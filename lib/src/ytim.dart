import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_ytim/src/bean/im_command.dart';
import 'package:flutter_ytim/src/bean/im_history_msg_list.dart';
import 'package:flutter_ytim/src/bean/im_msg.dart';
import 'package:flutter_ytim/src/bean/im_response.dart';
import 'package:flutter_ytim/src/bean/im_unread_msg_list.dart';
import 'package:flutter_ytim/src/bean/im_user.dart';
import 'package:flutter_ytim/src/bean/im_user_list.dart';
import 'package:flutter_ytim/src/utils/yt_http.dart';
import 'package:flutter_ytim/src/utils/yt_log.dart';
import 'package:flutter_ytim/src/utils/yt_sp_utils.dart';
import 'package:flutter_ytim/src/values/urls.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum IMConnectState { IDLE, CONNECTING, CONNECTED }

typedef Callback<T> = void Function(T value);
typedef void KickOutCallback();

/// YTIM 核心类
class YTIM {
  String _tag = 'YTIM';

  YTIM._() {
    _streamController = StreamController.broadcast();
  }

  static YTIM _singleton;

  factory YTIM() {
    if (_singleton == null) {
      _singleton = YTIM._();
      YTSPUtils.init();
    }
    return _singleton;
  }

  StreamController get streamController => _streamController;

  /// 当前正在与之聊天的用户id。
  String currentChatUserId = '';

  /// 自己的用户信息
  IMUser mUser;

  IMConnectState _connectState = IMConnectState.IDLE;
  IOWebSocketChannel _channel;
  StreamController _streamController;

  /// 临时保存发送消息内容。发送消息成功后，服务器成功响应体内没有消息内容，所以临时存一下。
  String _tempContent = '';

  /// keys
  String _appID = '';
  String _appSecret = '';

  /// 登录/注册时使用的账号和用户名。
  String _account = '';
  String _username = '';

  /// 回调
  Callback<IMUser> _onIMUserCreatedCallback;
  Callback<IMUser> _onLoginSuccessCallback;
  KickOutCallback _kickOutCallback;

  Stream<T> on<T>() {
    if (T == dynamic) {
      return _streamController.stream;
    } else {
      return _streamController.stream.where((event) => event is T).cast<T>();
    }
  }

  String get appSecret => _appSecret;

  /// 是否需要重连
  /// 异常断开：需要重连。
  /// release：不需要重连。
  bool _needReconnect = true;

  /// IM初始化。
  void init({
    @required String imAppID,
    @required String imAppSecret,
    @required String imAccount,
    @required Callback<IMUser> imUserCreatedCallback,
    @required Callback<IMUser> imLoginSuccessCallback,
    String imUsername = '',
  }) {
    if (imAppID == null ||
        imAppID.isEmpty ||
        imAppSecret == null ||
        imAppSecret.isEmpty) {
      throw 'appID 或 appSecret 为空！\n'
          '''你可能需要先执行初始化操作：YTIM.instance.init('appID', 'appSecret);\n'''
          '如果没有appID，请登录：https://im.youteacher.asia/admin/login 获取。';
    }
    _appID = imAppID;
    _appSecret = imAppSecret;
    _account = imAccount;
    _username = imUsername;
    _onIMUserCreatedCallback = imUserCreatedCallback;
    _onLoginSuccessCallback = imLoginSuccessCallback;
    _connectServer();
  }

  /// 添加被踢出回调
  void addKickOutCallback(KickOutCallback callback) {
    this._kickOutCallback = callback;
  }

  /// 连接
  void _connectServer() {
    if (_connectState == IMConnectState.IDLE) {
      _connectState = IMConnectState.CONNECTING;
      _streamController.sink.add(IMConnectState.CONNECTING);
      YTLog.d(_tag, 'connect sockets address: ${YTIMUrls.IM_SERVER_ADDRESS}');
      _channel = IOWebSocketChannel.connect(YTIMUrls.IM_SERVER_ADDRESS);
      _needReconnect = true;
      _channel.stream.listen(
        _handleMassage,
        onError: (err) =>
            YTLog.d(_tag, 'IM出错：${(err as WebSocketChannelException).message}'),
        onDone: () {
          YTLog.d(_tag, 'IM断开：${_channel?.closeReason}');
          _connectState = IMConnectState.IDLE;
          _streamController.sink.add(IMConnectState.IDLE);
          if (_needReconnect) {
            _connectServer();
          }
        },
        cancelOnError: false,
      );
    }
  }

  /// 释放连接
  void release() {
    if (_channel != null && _channel.sink != null) {
      YTLog.d(_tag, 'close sockets');
      _connectState = IMConnectState.IDLE;
      _streamController.sink.add(IMConnectState.IDLE);
      _needReconnect = false;
      _channel.sink.close();
      _streamController.close();
    }
  }

  /// 检查连接状态
  void checkConnectStatus() {
    if (_connectState == IMConnectState.IDLE) {
      _connectServer();
    } else {
      YTLog.d(_tag, 'IM连接状态：$_connectState');
    }
  }

  /// 创建IM用户
  void _createIMUser() async {
    final data =
        await addUser(_account, _username.isEmpty ? _account : _username);
    if (data == null) {
      YTLog.d(_tag, 'createIMUser：请求出错。');
    } else {
      ImResponse ir = ImResponse.fromJson(json.decode(data));
      if (ir.code == 0 || ir.code == 50010) {
        YTLog.d(_tag,
            '${ir.code == 0 ? 'IM账号创建成功' : 'IM账号已存在'}，IM id：${ir.userInfo.id}');
        _onIMUserCreatedCallback(ir.userInfo);
        _login();
      } else {
        YTLog.d(_tag, 'IM账号创建失败：${ir.msg}');
      }
    }
  }

  /// 给服务器发消息
  void _send(String message) {
    if (_connectState == IMConnectState.CONNECTED && _channel?.sink != null) {
      YTLog.d(_tag, '--> message:$message');
      _channel.sink.add(message);
    }
  }

  /// 处理消息
  void _handleMassage(message) {
    YTLog.d(_tag, '<-- message:$message');
    Map<String, dynamic> obj = json.decode(message);
    if (obj['action'] == 'ack') {
      switch (obj['module']) {
        case 'connect':
          YTLog.d(_tag, 'connect success');
          _connectState = IMConnectState.CONNECTED;
          _streamController.sink.add(IMConnectState.CONNECTED);
          _login();
          break;
        case 'login':
          if (obj['code'] == 10004) {
            YTLog.d(_tag, '账号不存在，自动注册');
            _createIMUser();
          } else {
            YTLog.d(_tag, 'login success.');
            YTLog.d(_tag, 'send heartbeat every 120 seconds.');
            mUser = IMUser.fromJson(obj['userInfo']);
            _onLoginSuccessCallback(mUser);
            _keepBeat();
          }
          break;
        case 'beat':
          _keepBeat();
          break;
        case 'userList':
          _streamController.sink.add(IMUserList.fromJson(obj));
          break;
        case 'history':
          _streamController.sink.add(IMHistoryMsgList.fromJson(obj));
          break;
        case 'userInfo':
          _streamController.sink.add(IMUser.fromJson(obj['userInfo']));
          break;
        case 'message':
          // 发送消息，服务器回应
          if (obj['code'] == 0) {
            _streamController.sink.add(
              IMMessage(
                type: '1',
                from: mUser.userId.toString(),
                to: obj['to'],
                content: _tempContent,
                timestamp: obj['timestamp'],
              ),
            );
          }
          break;
        case 'revokeMessage':
          _streamController.sink.add(IMCommand.fromJson(obj));
          break;
        case 'unreadMessage':
          if (obj['messageList'] is Map) {
            _streamController.sink.add(IMUnreadMsgList.fromJson(obj));
          }
          break;
        default:
          break;
      }
    }
    if (obj['action'] == 'put') {
      switch (obj['module']) {
        case 'kickOut':
          // 如果帐号已经在其它端登录，退出执行重新登陆
          if (_kickOutCallback != null) {
            _kickOutCallback();
          }
          release();
          break;
        case 'message':
          _streamController.sink.add(IMMessage.fromJson(obj));
          break;
        case 'readMessage':
          _streamController.sink.add(IMCommand.fromJson(obj));
          break;
        case 'revokeMessage':
          _streamController.sink.add(IMCommand.fromJson(obj));
          break;
        default:
      }
    }
  }

  void _keepBeat() {
    Future.delayed(Duration(seconds: 120), () => _beat());
  }

  /// 每隔120秒发送心跳，保持连接。
  void _beat() {
    _send(json.encode({"action": "get", "module": "beat"}));
  }

  /// 登陆IM
  void _login() async {
    if (_account == null || _account.isEmpty) {
      throw '登录操作：IM账号不能为空！';
    }
    _send(json.encode({
      "action": "set",
      "module": "login",
      "appId": _appID,
      "account": _account,
      "password": "000000"
    }));
  }

  /// 返回已读回执
  void sendACK(String tid) {
    _send(json.encode({"action": "set", "module": "readMessage", "to": tid}));
  }

  /// 发送消息
  void send(String tid, String tName, String content) {
    _tempContent = content;
    _send(json.encode({
      "action": "add",
      "module": "message",
      "to": tid,
      "toName": tName,
      "type": "1",
      "content": content
    }));
  }

  /// 获取联系人列表
  /// "order":"排序（1:按会话记录，2:按会话记录(只取有过会话的用户列表)，3:在线状态，4：按用户名称）"
  void getUserList({String order = "2"}) {
    _send(json.encode({"action": "get", "module": "userList", "order": order}));
  }

  /// 获取未读消息
  void getUnreadMessage() {
    _send(json.encode({"action": "get", "module": "unreadMessage"}));
  }

  /// 获取历史消息列表
  void getHistoryMessage(String tid) {
    _send(json.encode({
      "action": "get",
      "module": "history",
      "userId": tid,
      "timestamp": "${DateTime.now().millisecondsSinceEpoch.toString()}",
      "limit": "100"
    }));
  }

  /// 撤销消息
  /// [tIMId] 通知对方imid
  /// [timestamp] 消息时间戳
  void revokeMessage(String tIMId, String timestamp) {
    _send(json.encode({
      "action": "del",
      "module": "revokeMessage",
      "to": tIMId,
      "timestamp": timestamp,
    }));
  }

  /// 获取用户资料
  /// [userId] 对方userId
  void getProfile(String userId) {
    _send(json.encode({
      "action": "get",
      "module": "userInfo",
      "userId": userId,
    }));
  }

  /// 获取未读消息数
  Future<int> getUnreadMessageCount(int userId) async {
    final data = await YTHttp.postFormData(
      YTIMUrls.IM_GET_UNREAD_MESSAGE_COUNT,
      YTHttp.getSignedParams([
        'appId=$_appID',
        'timestamp=${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}',
        'userId=$userId',
      ]),
    );
    if (data != null) {}
    return 0;
  }

  /// 修改IM用户信息
  Future<dynamic> editUser(String userId, String username,
      {int sex, String headImg, String phone, String email}) async {
    var params = [
      'appId=$_appID',
      'timestamp=${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}',
      'userId=$userId',
      'status=1',
    ];
    if (sex != null) {
      params.add('sex=$sex');
    }
    if (headImg != null) {
      params.add('headImg=$headImg');
    }
    if (phone != null) {
      params.add('phone=$phone');
    }
    if (email != null) {
      params.add('email=$email');
    }
    return await YTHttp.postFormData(
      YTIMUrls.IM_USER_EDIT,
      YTHttp.getSignedParams(params),
    );
  }

  /// 删除用户
  Future<dynamic> deleteUser(int userId) async {
    return await YTHttp.postFormData(
      YTIMUrls.IM_USER_DELETE,
      YTHttp.getSignedParams([
        'appId=$_appID',
        'timestamp=${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}',
        'userId=$userId',
      ]),
    );
  }

  /// 创建用户
  Future<dynamic> addUser(String account, String username) async {
    return await YTHttp.postFormData(
      YTIMUrls.IM_USER_ADD,
      YTHttp.getSignedParams([
        'appId=$_appID',
        'timestamp=${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}',
        'account=$account',
        'password=000000',
        'status=1',
        'username=$username}',
      ]),
    );
  }
}
