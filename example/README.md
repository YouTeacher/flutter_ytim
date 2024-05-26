# flutter_ytim_example

Demonstrates how to use the flutter_ytim plugin.

## 概要
YouTeacher IM 快速开发SDK。
支持两种集成方式：
1. 快速集成。几行代码完成所有功能接入，使用内置UI界面。
2. 自定义集成。使用核心功能API，自定义联系人列表和聊天界面。

## 功能
- IM账号自动注册/登陆
- 联系人列表
- 未读消息红点显示
- 最后一条消息展示
- 1v1聊天
- 群组聊天
- 未读/已读状态显示
- 自己的消息撤回
- 被踢下线回调
- 内置UI组件国际化支持

## init YTIM 快速集成

## 在应用顶层集成provide，用于界面更新
```
    MultiProvider(
    providers: [
    ChangeNotifierProvider(
    create: (context) => IMStore({}, {}, {}, [], [], [], [])),
        ],
    child: HomePage()
    )
```

## 初始化YTIM插件

    YTIM().init(
        loginToken:'',
        websocketUrl: 'wss://preim.rentalbike.shop:18081',
        onConnectErrorCallback: (WebSocketChannelException error) {},
        imLoginSuccessCallback: (IMUser user) {
          /// 获取IM总数据
          _getIMTotalData();
        },
        loginFailCallback: (int code) {
          /// 登录失败
          /// code = 412 时，token失效，需要刷新token重新登录
        },
        revokeMsgCallback: (IMCommand command) {
          /// 消息撤回
          if (mounted) {
            IMUtils.processRevokeMessage(context, command);
          }
          imEventBus.fire(
              IMEventCommand(IMEventCommandType.revokeMsg, command: command));
        },
        sysMsgCallback: (IMSysMessage msg) {
          /// 系统消息
          if (mounted) {
            IMUtils.processSysMessage(context, msg);
          }
        },
        groupControlCallback: (IMGroupControl msg) {
          /// 群组操作的消息
          if (mounted) {
            IMUtils.processGroupControlMessage(context, msg);
          }
        },
        chatMessageCallback: (IMBaseMessage message) {
          /// 聊天消息的回调，包括群组、单聊、客服  用message.chatType判断
          if (mounted) {
            IMUtils.processChatMessage(context, message);
          }
        /// demo中消息发送
          imEventBus.fire(
              IMEventCommand(IMEventCommandType.chatMsg, message: message));
        },
        logEnabled: true);

## 添加回调

    YTIM().addKickOutCallback(() {
      /// IM异地登录操作
      YTLog.d('UI','IM 用户异地登录，当前用户被踢出');
    });

    YTIM().addMsgReadCallback((IMCommand command) {
      /// 消息已读
      /// demo中消息发送
    imEventBus
          .fire(IMEventCommand(IMEventCommandType.readMsg, command: command));
    });
    YTIM().addUnreadCountCallback((value) {
      /// 消息未读数量
      unreadCount = value;
      setState(() {});
    });

## 拉取IM总数据

    YTIM().getIMTotalData(context, (value) {}, (error) {});

## 在程序回到前台时，检查IM连接状态。
    ```
    YTIM().checkConnectStatus();
    ```
## 断开连接，释放资源。
    ```
    YTIM().release();
    ```
## 一些事件类型
    事件 | 类名
    --- | ---
    消息基类 | IMBaseMessage
    用户信息 | IMUser
    用户列表 | IMUserList
    历史消息列表 | IMHistoryMsgList
    未读消息个数 | IMUnreadCount
    IM指令类型 | IMCommand

## 可用的全局变量
    功能 | 方法
    --- | ---
    自己的IM用户信息 | YTIM().mUser
    当前正在与之聊天的用户id | YTIM().currentChatUserId
    当前正在与之聊天的群组id | YTIM().currentGroupId


## 示例代码
[example project](https://github.com/and2long/flutter_ytim/tree/v3.0/example)

## author 陈凯  
## phone  15001052296   
## email  ck525087135@163.com
