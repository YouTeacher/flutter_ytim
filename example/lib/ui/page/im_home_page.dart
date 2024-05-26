import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/page/address_book_page.dart';
import 'package:flutter_ytim_example/ui/page/chat_list_page.dart';
import 'package:flutter_ytim_example/ui/page/im_search_page.dart';
import 'package:flutter_ytim_example/ui/page/message_add_manager.dart';
import 'package:flutter_ytim_example/ui/page/message_setting.dart';
import 'package:flutter_ytim_example/ui/page/system_message_list_page.dart';
import 'package:flutter_ytim_example/ui/view/unread_count_view.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_tabbar.dart';
import 'package:flutter_ytim_example/utils/im_event_bus.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

//消息首页
class IMHomePage extends StatefulWidget {
  static const String routeName = '/IMHomePage';

  const IMHomePage({super.key});

  @override
  State<IMHomePage> createState() => _IMHomePageState();
}

class _IMHomePageState extends State<IMHomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver{
  @override
  bool get wantKeepAlive => true;
  late TabController _tabController;

  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    YTIM().init(
        loginToken:
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJrZXkiOiIzNyIsImRhdGEiOnsidXNlclR5cGUiOjIsInVzZXJJZCI6IjM3In0sImV4dCI6MzYwMCwiZXhwIjoxNzE2NjM1OTQ1LCJpc3MiOiJ6eTI3MDEiLCJpYXQiOjE3MTY2MzIzNDV9.G-sUkrEZ_ge9G64_NFdEmqAlzL_FMnNPZEMZ0Oxytpo',
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
          imEventBus.fire(
              IMEventCommand(IMEventCommandType.chatMsg, message: message));
        },
        logEnabled: true);
    YTIM().addKickOutCallback(() {
      /// IM异地登录操作
      YTLog.d('UI','IM 用户异地登录，当前用户被踢出');
    });

    YTIM().addMsgReadCallback((IMCommand command) {
      /// 消息已读
      imEventBus
          .fire(IMEventCommand(IMEventCommandType.readMsg, command: command));
    });
    YTIM().addUnreadCountCallback((value) {
      /// 消息未读数量
      unreadCount = value;
      setState(() {});
    });
  }

  //IM 总数据列表读取 并处理未读显示
  _getIMTotalData() {
    YTIM().getIMTotalData(context, (value) {}, (error) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
      //在程序回到前台时，检查IM连接状态。
        YTIM().checkConnectStatus();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sysCount = context.watch<IMStore>().sysMessages.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(IMLocalizations.of(context).currentLocalization.tabMessage),
        leading: IconButton(
          icon: const ColorFiltered(
              colorFilter: ColorFilter.mode(
                themeColor,
                BlendMode.srcIn,
              ),
              child: Icon(
                Icons.settings,
                size: 21,
                color: Colors.white,
              )),
          onPressed: () {
            // 处理更多按钮点击事件
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return const MessageSettingsPage();
            }));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: themeColor,
              size: 25,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const MessageAddManagerPage();
              }));
            },
          ),
        ],
      ),
      body: YTUtils.generateWidgetOfWideScreen(
        Column(
          children: [
            GestureDetector(
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        IMLocalizations.of(context)
                            .currentLocalization
                            .imSearchPlh,
                        style:
                            const TextStyle(fontSize: 15.0, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return const ImSearchPage();
                }));
              },
            ),
            IMCustomTabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 4),
                        child: Text(IMLocalizations.of(context)
                            .currentLocalization
                            .imTabUserTitle),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: UnreadCountView(count: unreadCount),
                      )
                    ],
                  ),
                ),
                Tab(
                    child: Text(IMLocalizations.of(context)
                        .currentLocalization
                        .imTabAddressBook)),
                Tab(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 4),
                        child: Text(IMLocalizations.of(context)
                            .currentLocalization
                            .imTabNotice),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: UnreadCountView(count: sysCount),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ChatListPage(), //消息列表
                  AddressBookPage(), //通讯录
                  SystemMessageListPage(), //系统消息//公开动态
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
